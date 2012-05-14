" Purpose: share quickfix between commands

if exists('g:loaded_sharedquickfix')
    finish
endif
let g:loaded_sharedquickfix = 1

" pad quickfix list height when displayed
if !exists('g:sharedquickfix_padding')
    let g:sharedquickfix_padding = 3
endif

" option to open quickfix list when not empty
if !exists('g:sharedquickfix_auto_open')
    let g:sharedquickfix_auto_open = 1
endif

" option to jump to first owned quickfix
if !exists('g:sharedquickfix_jump_first')
    let g:sharedquickfix_jump_first = 1
endif

let s:save_cpo = &cpo
set cpo&vim

" store quickfixes with owners
let s:qflist = []

" run a quickfix method and display errors or succes
function! SharedQuickfix(owner, success, method, ...)
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
    let qflist = s:Extended(a:owner)

    " display quicklist
    if g:sharedquickfix_auto_open
        call s:Display(qflist, a:owner)
    endif

    " redraw screen
    setlocal nolazyredraw
    redraw!

    " skip success message if empty string
    let show = type(a:success) == type('') && len(a:success)
                \ || type(a:success) != type('')

    " display success message if no quickfixes for this owner
    if show && empty(s:Owned(qflist, a:owner))
        highlight Passed ctermfg=green guifg=green
        echohl Passed | echon a:success | echohl None
    endif

    return qflist
endfunction

" get quickfixes by owner
" get all quickfixes with wildcard
function! SharedQuickfixOwned(owner)
    if a:owner == '*'
        return deepcopy(s:qflist)
    endif

    return s:Owned(s:qflist, a:owner)
endfunction

" get quickfix list and filter out owner and close if empty
" clear all with wildcard
function! SharedQuickfixFiltered(owner)
    if a:owner == '*'
        let s:qflist = []
    else
        call filter(s:qflist, s:unowned_filter)
    endif

    " update the quickfix list
    call setqflist(s:qflist)

    if empty(s:qflist)
        cclose
    endif

    return deepcopy(s:qflist)
endfunction

" get old quickfix list extended with new quickfix list
function! s:Extended(owner)
    " get current quickfix list
    let qflist = getqflist()

    " add owner to each error
    call s:Own(qflist, a:owner)

    " append previous errors to new errors
    let s:qflist = qflist + s:Filtered(s:qflist, a:owner)

    " set quickfix list to old plus new
    call setqflist(s:qflist)

    return deepcopy(s:qflist)
endfunction

" get quickfix list with errors for this owner and
" quickfixes without an owner filtered out
function! s:Filtered(qflist, owner)
    return filter(deepcopy(a:qflist), s:unowned_filter)
endfunction

" get quickfixes by owner
function! s:Owned(qflist, owner)
    return filter(deepcopy(a:qflist), s:owned_filter)
endfunction

" add owner to each quickfix in list
function! s:Own(qflist, owner)
    for qf in a:qflist
        call extend(qf, {'owner': a:owner}, 'error')
    endfor
endfunction

" display quickfix list
function! s:Display(qflist, owner)
    " show list if it contains errors
    if !empty(a:qflist)
        " pad quickfix height
        let height = len(a:qflist) + g:sharedquickfix_padding

        " open it
        exec 'cclose | copen '.height

        " jump to first error if has owned errors
        if g:sharedquickfix_jump_first && !empty(s:Owned(a:qflist, a:owner))
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
