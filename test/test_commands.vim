" Description: test public owned command

let s:tc = unittest#testcase#new('Commands', sharefix#__context__())

function! s:tc.setup()
    " create sharefix stub apply it to plugin's internal sharefix list
    let s:owners = ['test', 'tester', 'own', 'unown']
    for owner in s:owners
        call SharefixStub(owner)
        call self.call('s:Extended', [owner])
    endfor
endfunction

function! s:tc.test_not_cleared()
    " assert sharefix list is not empty
    call self.assert_not(empty(self.get('s:sharefix_list')))
endfunction

function! s:tc.test_clear()
    " assert sharefix list is cleared
    SharefixClear
    call self.assert(empty(self.get('s:sharefix_list')))
endfunction

function! s:tc.test_filter()
    " filter quickfixes by owner
    SharefixFilter own
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len, len(sharefix_list))
    call self.assert_equal('own', sharefix_list[0]['owner'])
endfunction

function! s:tc.test_filter_all()
    " match all
    SharefixFilter *
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * len(s:owners), len(sharefix_list))
endfunction

function! s:tc.test_filter_nothing()
    " nothing changes when no match
    SharefixFilter nothing
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * len(s:owners), len(sharefix_list))
endfunction

function! s:tc.test_filter_cleared()
    " nothings changes when filtering an empty sharefix list
    SharefixClear
    SharefixFilter nothing
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(0, len(sharefix_list))
endfunction

function! s:tc.test_filter_prefix_glob()
    " filter down to two that match prefix glob
    SharefixFilter *own
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(2 * g:sharefix_stub_len, len(sharefix_list))
    call self.assert_equal('unown', sharefix_list[0]['owner'])
endfunction

function! s:tc.test_filter_suffix_glob()
    " filter down to two that match suffix glob
    SharefixFilter test*
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(2 * g:sharefix_stub_len, len(sharefix_list))
    call self.assert_equal('tester', sharefix_list[0]['owner'])
endfunction

function! s:tc.test_filter_bad_glob()
    " assert nothing changed when passing in bad wildcards
    SharefixFilter te*st
    SharefixFilter *test*
    SharefixFilter te*st*
    SharefixFilter *te*st
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * len(s:owners), len(sharefix_list))
endfunction

function! s:tc.test_remove()
    " remove quickfixes match owner
    SharefixRemove own
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * (len(s:owners) - 1), len(sharefix_list))
endfunction

function! s:tc.test_remove_all()
    " remove all quickfixes
    SharefixRemove *
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(0, len(sharefix_list))
endfunction

function! s:tc.test_remove_nothing()
    " nothing changes when no match
    SharefixRemove nothing
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * len(s:owners), len(sharefix_list))
endfunction

function! s:tc.test_remove_cleared()
    " nothings changes when removing from an empty sharefix list
    SharefixClear
    SharefixRemove nothing
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(0, len(sharefix_list))
endfunction

function! s:tc.test_remove_prefix_glob()
    " remove two that match prefix glob
    SharefixRemove *own
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(2 * g:sharefix_stub_len, len(sharefix_list))
    call self.assert_equal('tester', sharefix_list[0]['owner'])
endfunction

function! s:tc.test_remove_suffix_glob()
    " remove two that match suffix glob
    SharefixRemove test*
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(2 * g:sharefix_stub_len, len(sharefix_list))
    call self.assert_equal('unown', sharefix_list[0]['owner'])
endfunction

function! s:tc.test_remove_bad_glob()
    " assert nothing changed when passing in bad wildcards
    SharefixRemove te*st
    SharefixRemove *test*
    SharefixRemove te*st*
    SharefixRemove *te*st
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * len(s:owners), len(sharefix_list))
endfunction

function! s:tc.teardown()
    " clear quickfix list and plugin's internal sharefix list
    SharefixClear
endfunction
