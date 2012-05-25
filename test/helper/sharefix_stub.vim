" Description: sharefix stub generator for testing

let g:sharefix_stub_len = 3

" create test quickfix list for each owner
function! SharefixStub(...)
    " temporary sharefix
    let sharefix = []
    let owners = a:000

    for owner in owners
        " get random amount of stubs
        let stubs = s:GenerateStubs(owner)

        " set quickfix to generate the rest of the quickfix properties
        call setqflist(stubs)

        " add owner to each quickfix and store in sharefix
        call extend(sharefix, map(getqflist(), "extend(v:val, {'owner': owner}, 'error')"))
    endfor

    " return sharefix to test
    return copy(sharefix)
endfunction

" generate random amount of stubs for owner
function! s:GenerateStubs(owner)
    let stubs = []
    for index in range(1, g:sharefix_stub_len)
        " fill in the quickfix properties
        let filler = 'test'.index.': '.a:owner
        let stub = {'filename': filler, 'pattern': filler, 'text': filler}
        call extend(stubs, [copy(stub)])
    endfor
    return stubs
endfunction
