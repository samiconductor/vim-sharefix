" Description: quickfix helper functions

" get quickfix buffer number
function! QuickbufNumber()
    " look for quickfix buffer type
    for i in range(1, winnr('$'))
        let bufnr = winbufnr(i)
        if getbufvar(bufnr, '&buftype') == 'quickfix'
            return bufnr
        endif
    endfor

    " return negative on not found
    return -1
endfunction

" test if quickfix buffer exists
function! QuickbufExists()
    return bufexists(QuickbufNumber())
endfunction
