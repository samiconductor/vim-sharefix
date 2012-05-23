" Purpose: share quickfix between commands

if exists('g:loaded_sharefix_test')
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

" store quickfixes with owners
let s:sharefix_list = []

" run a quickfix method and display errors or succes
function! Sharefix(owner, success, method, ...)
    " delay redrawing screen
    setlocal lazyredraw

    " if method is string execute expression
    if type(a:method) == type('')
        exec a:method

    " if method is a function reference call it
    elseif type(a:method) == type(function('type'))
        call call(a:method, a:000)
    endif

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

" get quickfixes by owner
" get multiple owners with a wildcard glob
function! SharefixOwned(owner)
    return s:Owned(s:sharefix_list, a:owner)
endfunction

" get quickfix list with owner filtered out
" filter out multiple owners with a wildcard glob
function! SharefixUnowned(owner)
    return s:Unowned(s:sharefix_list, a:owner)
endfunction

" remove owner from sharefix list and close if empty
" remove multiple with a wildcard glob
function! SharefixClear(owner)
    if a:owner == '*'
        let s:sharefix_list = []
    else
        call filter(s:sharefix_list, s:unowned_filter)
    endif

    " update the quickfix list
    call setqflist(s:sharefix_list)

    if empty(s:sharefix_list)
        cclose
    endif

    return copy(s:sharefix_list)
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

" get quickfixes by owner
function! s:Owned(sharefix_list, owner)
    return filter(copy(a:sharefix_list), s:owned_filter)
endfunction

" get quickfixes that do not match owner
function! s:Unowned(sharefix_list, owner)
    return filter(copy(a:sharefix_list), s:unowned_filter)
endfunction

" add owner to each quickfix in list
function! s:Own(quickfix_list, owner)
    return map(copy(a:quickfix_list), "extend(v:val, {'owner': a:owner}, 'error')")
endfunction

" prepend owner to error text
function! s:OwnErrorText(sharefix_list)
    let sharefix_list = copy(a:sharefix_list)
    for sharefix in sharefix_list
        let sharefix['text'] = sharefix['owner'].': '.sharefix['text']
    endfor
    return sharefix_list
endfunction

" display quickfix list
function! s:Display(sharefix_list, owner)
    " show list if it contains errors
    if !empty(a:sharefix_list)
        " pad quickfix height
        let height = len(a:sharefix_list) + g:sharefix_padding

        " prepend owner to each error text
        call setqflist(s:OwnErrorText(a:sharefix_list))

        " open it
        exec 'cclose | copen '.height

        " jump to first error if has owned errors
        if g:sharefix_jump_first && !empty(s:Owned(a:sharefix_list, a:owner))
            cc
        endif

    " else close quickfix list
    else
        cclose
    endif
endfunction

" filter strings
let s:filter = "has_key(v:val, 'owner') && v:val['owner'] {compare} a:owner"
let s:owned_filter = substitute(s:filter, '{compare}', '==', '')
let s:unowned_filter = substitute(s:filter, '{compare}', '!=', '')

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
