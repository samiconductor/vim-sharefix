" Description: sharefix stub generator for testing

let s:sharefix = []

" create test quickfix list for each owner
function! SharefixStub(owners)
    for owner in a:owners
        " generate random amount of stubs
        let stublist = []
        for index in range(1, s:RandomInt(1,9))
            " fill in the required properties for quickfix
            let filler = 'test'.index
            let stub = {'filename': filler, 'pattern': filler}
            call extend(stublist, [copy(stub)])
        endfor

        " set quickfix to generate the rest of the quickfix properties
        call setqflist(stublist)

        " add owner to each quickfix and store in sharefix
        call extend(s:sharefix, map(getqflist(), "extend(v:val, {'owner': owner}, 'error')"))
    endfor

    " return sharefix to test
    return copy(s:sharefix)
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
