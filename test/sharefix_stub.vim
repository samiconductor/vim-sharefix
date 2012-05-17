" Description: sharefix stub generator for testing

if exists('g:loaded_sharefix_stub')
    finish
endif
let g:loaded_sharefix_stub = 1

let s:save_cpo = &cpo
set cpo&vim

" create test quickfix list for each owner
function! SharefixStub(owners)
    " temporary sharefix
    let sharefix = []

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
        call extend(sharefix, map(getqflist(), "extend(v:val, {'owner': owner}, 'error')"))
    endfor

    " return sharefix to test
    return copy(sharefix)
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

let &cpo = s:save_cpo
unlet s:save_cpo
