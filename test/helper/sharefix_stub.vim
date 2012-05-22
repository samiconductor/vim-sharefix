" Description: sharefix stub generator for testing

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
    for index in range(1, s:RandomInt(1,9))
        " fill in the required properties for quickfix
        let filler = 'test'.index.': '.a:owner
        let stub = {'filename': filler, 'pattern': filler}
        call extend(stubs, [copy(stub)])
    endfor
    return stubs
endfunction

" generate a random number
function! s:RandomInt(low, high)
python << endpython
import vim, random

low, high = map(lambda s: int(s), vim.eval('[a:low, a:high]'))
rnum = random.randint(low, high)
vim.command('return {:d}'.format(rnum))
endpython
endfunction
