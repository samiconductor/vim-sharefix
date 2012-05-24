" Description: test filtering sharefix

let s:tc = unittest#testcase#new('Unowned', sharefix#__context__())

function! s:tc.setup()
    " create sharefix stub
    let s:sharefix_test_list = SharefixStub('test', 'unown')
endfunction

function! s:tc.test_has_unowned()
    " make sure filter owns some quickfixes
    let unowned_fixes = filter(copy(s:sharefix_test_list), "v:val['owner'] == 'unown'")
    call self.assert_not(empty(unowned_fixes))
endfunction

function! s:tc.test_unowned()
    " filter out unowned owner
    let unowned = self.call('s:Unowned', [s:sharefix_test_list, 'unown'])
    let unowned_fixes = filter(copy(unowned), "v:val['owner'] == 'unown'")
    call self.assert_not(empty(unowned))
    call self.assert(empty(unowned_fixes))
endfunction

function! s:tc.teardown()
    " clear quickfix list
    call setqflist([])
    let s:sharefix_test_list = []
endfunction
