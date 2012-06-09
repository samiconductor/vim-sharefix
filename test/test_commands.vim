" Description: test public owned command

let s:tc = unittest#testcase#new('Commands', sharefix#__context__())

function! s:tc.setup()
    " create sharefix stub apply it to plugin's internal sharefix list
    let s:owners = ['test', 'tester', 'own', 'unown', 'spaces allowed']
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
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert(empty(self.get('s:sharefix_list')))
    call self.assert_equal([], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_filter()
    " filter quickfixes by owner
    SharefixFilter own
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len, len(sharefix_list))
    call self.assert_equal(['own'], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_filter_with_spaces()
    " filter quickfixes by owner with spaces
    SharefixFilter spaces allowed
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len, len(sharefix_list))
    call self.assert_equal(['spaces allowed'], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_filter_all()
    " match all
    SharefixFilter *
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * len(s:owners), len(sharefix_list))
    call self.assert_equal(['own', 'spaces allowed', 'test', 'tester', 'unown'],
                \ s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_filter_nothing()
    " nothing changes when no match
    SharefixFilter nothing
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * len(s:owners), len(sharefix_list))
    call self.assert_equal(['own', 'spaces allowed', 'test', 'tester', 'unown'],
                \ s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_filter_when_empty()
    " nothings changes when filtering an empty sharefix list
    SharefixClear
    SharefixFilter nothing
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(0, len(sharefix_list))
    call self.assert_equal([], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_filter_prefix_glob()
    " filter down to two that match prefix glob
    SharefixFilter *own
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * 2, len(sharefix_list))
    call self.assert_equal(['own', 'unown'], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_filter_suffix_glob()
    " filter down to two that match suffix glob
    SharefixFilter test*
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * 2, len(sharefix_list))
    call self.assert_equal(['test', 'tester'], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_filter_both_ends_glob()
    " filter down to two that match glob at both ends
    SharefixFilter *est*
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * 2, len(sharefix_list))
    call self.assert_equal(['test', 'tester'], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_filter_bad_glob()
    " assert nothing changed when passing in bad wildcards
    SharefixFilter te*st
    SharefixFilter te*st*
    SharefixFilter *te*st
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * len(s:owners), len(sharefix_list))
    call self.assert_equal(['own', 'spaces allowed', 'test', 'tester', 'unown'],
                \ s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_remove()
    " remove quickfixes match owner
    SharefixRemove own
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * (len(s:owners) - 1), len(sharefix_list))
    call self.assert_equal(['spaces allowed', 'test', 'tester', 'unown'],
                \ s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_remove_with_spaces()
    " assert owner with spaces can be removed
    SharefixRemove spaces allowed
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * (len(s:owners) - 1), len(sharefix_list))
    call self.assert_equal(['own', 'test', 'tester', 'unown'],
                \ s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_remove_all()
    " remove all quickfixes
    SharefixRemove *
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(0, len(sharefix_list))
    call self.assert_equal([], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_remove_nothing()
    " nothing changes when no match
    SharefixRemove nothing
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * len(s:owners), len(sharefix_list))
    call self.assert_equal(['own', 'spaces allowed', 'test', 'tester', 'unown'],
                \ s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_remove_when_emtpy()
    " nothings changes when removing from an empty sharefix list
    SharefixClear
    SharefixRemove nothing
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(0, len(sharefix_list))
    call self.assert_equal([], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_remove_prefix_glob()
    " remove two that match prefix glob
    SharefixRemove *own
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * (len(s:owners) - 2), len(sharefix_list))
    call self.assert_equal(['spaces allowed', 'test', 'tester'], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_remove_suffix_glob()
    " remove two that match suffix glob
    SharefixRemove test*
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * (len(s:owners) - 2), len(sharefix_list))
    call self.assert_equal(['own', 'spaces allowed', 'unown'], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_remove_both_ends_glob()
    " remove two that match glob at both ends
    SharefixRemove *st*
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * (len(s:owners) - 2), len(sharefix_list))
    call self.assert_equal(['own', 'spaces allowed', 'unown'], s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.test_remove_bad_glob()
    " assert nothing changed when passing in bad wildcards
    SharefixRemove te*st
    SharefixRemove te*st*
    SharefixRemove *te*st
    let sharefix_list = self.get('s:sharefix_list')
    call self.assert_equal(g:sharefix_stub_len * len(s:owners), len(sharefix_list))
    call self.assert_equal(['own', 'spaces allowed', 'test', 'tester', 'unown'],
                \ s:sorted_unique_owners(sharefix_list))
endfunction

function! s:tc.teardown()
    " clear quickfix list and plugin's internal sharefix list
    SharefixClear
endfunction

function! s:sorted_unique_owners(sharefix_list)
    let sorted = sort(map(a:sharefix_list, "v:val['owner']"))
    let unique = []
    for owner in sorted
        if ' '.join(unique).' ' !~ ' '.owner.' '
            call add(unique, owner)
        endif
    endfor
    return unique
endfunction
