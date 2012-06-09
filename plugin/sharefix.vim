" File: sharefix.vim
" Author: Sam Simmons <sam@samiconductor.com>
" Description:  Share quickfix list between commands and functions
" Last Modified: June 09, 2012
" Version: 1.0.0
" License: MIT License
"
" Copyright (c) 2012 Sam Simmons
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.

if exists('g:loaded_sharefix')
    finish
endif
let g:loaded_sharefix = 1

let s:save_cpo = &cpo
set cpo&vim

" pad quickfix list height when displayed
if !exists('g:sharefix_padding')
    let g:sharefix_padding = 3
endif

" option to open quickfix list when not empty
if !exists('g:sharefix_auto_open')
    let g:sharefix_auto_open = 1
endif

" option to jump to first owned quickfix
if !exists('g:sharefix_jump_first')
    let g:sharefix_jump_first = 1
endif

" option to show warning messages
if !exists('g:sharefix_show_warnings')
    let g:sharefix_show_warnings = 1
endif

" store quickfixes with owners
let s:sharefix_list = []

" run a quickfix method and display errors or succes
function! Sharefix(owner, success, method, ...)
    if type(a:owner) != type('') || !len(a:owner)
        return s:ErrorMsg('sharefix owner must be a non-empty string')
    endif

    " make sure passed in owner does not contain special characters
    if a:owner =~ '[^-_[:alnum:][:space:]]\+\m'
        return s:ErrorMsg('sharefix owner may only contain letters,
                    \ numbers, spaces, hyphens, and underscores')
    endif

    " delay redrawing screen
    setlocal lazyredraw

    " if method is string execute expression
    try
        if type(a:method) == type('')
            exec a:method.' '.join(a:000)
        " if method is a function reference call it
        elseif type(a:method) == type(function('type'))
            call call(a:method, a:000)
        endif
    catch
        call s:ErrorMsg(v:exception)
        return
    endtry

    " extend filtered quickfixes with new ones
    let sharefix_list = s:Extended(a:owner)

    " display quicklist
    if g:sharefix_auto_open
        call s:Display(sharefix_list, a:owner)
    endif

    " redraw screen
    setlocal nolazyredraw
    redraw!

    " skip success message if empty string
    let show = type(a:success) == type('') && len(a:success)
                \ || type(a:success) != type('')

    " display success message if no quickfixes for this owner
    if show && empty(s:Owned(sharefix_list, a:owner))
        highlight Passed ctermfg=green guifg=green
        echohl Passed | echon a:success | echohl None
    endif

    return sharefix_list
endfunction

" user commands
if !exists(':SharefixFilter')
    command -nargs=1 -complete=customlist,s:SharefixComplete SharefixFilter :call s:SharefixFilter(<q-args>)
endif

if !exists(':SharefixRemove')
    command -nargs=1 -complete=customlist,s:SharefixComplete SharefixRemove :call s:SharefixRemove(<q-args>)
endif

if !exists(':SharefixClear')
    command -nargs=0 SharefixClear :call s:SharefixRemove('*')
endif

" filter quickfixes down to matching owner
" filter down to multiple owners with a wildcard glob
function! s:SharefixFilter(owner)
    let test = 'empty(l:sharefix_list)'
    call s:SharefixModify(function('s:Owned'), test, a:owner, 'filtered')
endfunction

" remove quickfixes that match owner
" remove multiple owners with a wildcard glob
function! s:SharefixRemove(owner)
    let test = 'len(l:sharefix_list) == len(s:sharefix_list)'
    call s:SharefixModify(function('s:Unowned'), test, a:owner, 'removed')
endfunction

" modify sharefix method helper
function! s:SharefixModify(method, match_found, owner, done)
    if empty(s:sharefix_list)
        " warn attempt to filter an empty sharefix list
        return s:WarningMsg('nothing '.a:done.' since sharefix list is empty')
    endif

    try
        let l:sharefix_list = call(a:method, [s:sharefix_list, a:owner])
    catch /wildcard/
        return s:ErrorMsg(v:exception)
    endtry

    if eval(a:match_found)
        " warn no matching owner found
        return s:WarningMsg('no matching owner found for '.a:owner)
    endif

    call s:SetSharefix(l:sharefix_list)
endfunction

" get old quickfix list extended with new quickfix list
function! s:Extended(owner)
    " add owner to each quickfix
    let sharefix_list = s:Own(getqflist(), a:owner)

    " append previous errors to new errors
    let s:sharefix_list = sharefix_list + s:Unowned(s:sharefix_list, a:owner)

    " set quickfix list to old plus new
    call setqflist(s:sharefix_list)

    return copy(s:sharefix_list)
endfunction

" add owner to each quickfix in list
function! s:Own(quickfix_list, owner)
    return map(copy(a:quickfix_list), "extend(v:val, {'owner': a:owner}, 'error')")
endfunction

" get quickfixes by owner
function! s:Owned(sharefix_list, owner)
    return s:Filter(a:sharefix_list, a:owner, s:owned_filter, s:match_owned_filter, 1)
endfunction

" get quickfixes that do not match owner
function! s:Unowned(sharefix_list, owner)
    return s:Filter(a:sharefix_list, a:owner, s:unowned_filter, s:match_unowned_filter, 0)
endfunction

" filter list by owner
function! s:Filter(sharefix_list, owner, exact_filter, match_filter, all_filter)
    let owner = a:owner

    " get position of first wildcard
    let glob1_pos = match(owner, '*')

    " remove the first wildcard
    let owner = substitute(owner, '*', '', '')

    " get position of second wildcard
    let glob2_pos = match(owner, '*')

    " remove second wildcard
    let owner = substitute(owner, '*', '', '')

    " display error if more than two wildcard
    if match(owner, '*') >= 0
        throw 'use at most two wildcards'
    endif

    if glob1_pos < 0
        " no glob found
        let filter = a:exact_filter.'owner'
    elseif glob1_pos == 0 && len(owner) == 0
        " match all - '*'
        let filter = a:all_filter
    elseif glob1_pos == 0 && glob2_pos == -1
        " match end - '*owner'
        let filter = a:match_filter.'"'.owner.'$"'
    elseif glob1_pos == len(owner) && glob2_pos == -1
        " match beginning - 'owner*'
        let filter = a:match_filter.'"^'.owner.'"'
    elseif glob1_pos == 0 && glob2_pos == len(owner)
        " match both ends - '*owner*'
        let filter = a:match_filter.'owner'
    else
        " wildcard was in the middle
        throw 'wildcard must be at the beginning and/or end'
    endif

    return filter(copy(a:sharefix_list), filter)
endfunction

" display quickfix list
function! s:Display(sharefix_list, owner)
    " show list if it contains errors
    if !empty(a:sharefix_list)
        " pad quickfix height if padding >= 0
        if g:sharefix_padding >= 0
            let height = len(a:sharefix_list) + g:sharefix_padding
        endif

        " prepend owner to each error text
        call setqflist(s:OwnErrorText(a:sharefix_list))

        " open it
        if exists('height')
            exec 'cclose | copen '.height
        else
            exec 'cclose | copen'
        endif

        " jump to first error if has owned errors
        if g:sharefix_jump_first && !empty(s:Owned(a:sharefix_list, a:owner))
            cc
        endif

    " else close quickfix list
    else
        cclose
    endif
endfunction

" complete sharefix commands with matching owners
function! s:SharefixComplete(arg_lead, cmd_line, cursor_pos)
    let owner = a:arg_lead

    " append suffix glob if none to show all completions
    if owner !~ '*$'
        let owner = owner.'*'
    endif

    try
        let owned = s:Owned(s:sharefix_list, owner)
    catch /wildcard/
        let owned = []
    endtry

    return s:GetOwners(owned)
endfunction

" get list of unique owners
function! s:GetOwners(sharefix_list)
    let owners = []
    for sharefix in a:sharefix_list
        if empty(filter(copy(owners), "v:val == sharefix['owner']"))
            call add(owners, sharefix['owner'])
        endif
    endfor
    return owners
endfunction

" set sharefix list
function! s:SetSharefix(sharefix_list)
    let s:sharefix_list = a:sharefix_list

    if !empty(s:sharefix_list)
        " set quickfixes with owner names
        call setqflist(s:OwnErrorText(s:sharefix_list))
    else
        " clear and close quickfix list if sharefix empty
        call setqflist([])
        cclose
    endif
endfunction

" prepend owner to error text
function! s:OwnErrorText(sharefix_list)
    let sharefix_list = copy(a:sharefix_list)
    for sharefix in sharefix_list
        let owner_prefix = sharefix['owner'].': '
        if sharefix['text'] !~ '^'.owner_prefix
            let sharefix['text'] = owner_prefix.sharefix['text']
        endif
    endfor
    return sharefix_list
endfunction

" print errors
function! s:ErrorMsg(message)
    echohl ErrorMsg | echon a:message | echohl None
endfunction

" print warnings
function! s:WarningMsg(message)
    if g:sharefix_show_warnings
        echohl WarningMsg | echon a:message | echohl None
    endif
endfunction

" filter strings
let owner_filter = "has_key(v:val, 'owner') && v:val['owner'] {compare} "
let s:owned_filter = substitute(owner_filter, '{compare}', '==', '')
let s:unowned_filter = substitute(owner_filter, '{compare}', '!=', '')
let s:match_owned_filter = substitute(owner_filter, '{compare}', '=~', '')
let s:match_unowned_filter = substitute(owner_filter, '{compare}', '!~', '')

" export script scoped variables to unittest
function! sharefix#__context__()
  return { 'sid': s:SID, 'scope': s: }
endfunction

function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

let &cpo = s:save_cpo
unlet s:save_cpo
