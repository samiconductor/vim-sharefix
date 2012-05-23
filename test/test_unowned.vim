" Description: test filtering sharefix

let s:tc = unittest#testcase#new('Unowned', sharefix#__context__())

function! s:tc.setup()
    " create sharefix stub
    call self.set('s:sharefix', SharefixStub('test', 'unown'))
endfunction

function! s:tc.test_has_unowned()
    " make sure filter owns some quickfixes
    let unowned_fixes = filter(copy(self.get('s:sharefix')), "v:val['owner'] == 'unown'")
    call self.assert_not(empty(unowned_fixes))
endfunction

function! s:tc.test_unowned()
    " filter out unowned owner
    let unowned = self.call('s:Unowned', [self.get('s:sharefix'), 'unown'])
    let unowned_fixes = filter(copy(unowned), "v:val['owner'] == 'unown'")
    call self.assert_not(empty(unowned))
    call self.assert(empty(unowned_fixes))
endfunction

function! s:tc.teardown()
    " clear quickfix list
    call setqflist([])
endfunction
