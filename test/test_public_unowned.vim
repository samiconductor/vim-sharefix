" Description: test public unowned command

let s:tc = unittest#testcase#new('Public Unowned', sharefix#__context__())

function! s:tc.setup()
    " create sharefix stub apply it to plugin's internal sharefix list
    let s:owners = ['test', 'tester', 'own', 'unown']
    for owner in s:owners
        call SharefixStub(owner)
        call self.call('s:Extended', [owner])
    endfor
endfunction

function! s:tc.test_unowned()
    " return quickfixes for exact match
    let unowned = SharefixUnowned('own')
    call self.assert_equal((len(s:owners) - 1) * g:sharefix_stub_len, len(unowned))
endfunction

function! s:tc.test_all_unowned()
    " return all quickfixes
    let all_unowned = SharefixUnowned('*')
    call self.assert_equal(len(s:owners) * g:sharefix_stub_len, len(all_unowned))
endfunction

function! s:tc.test_prefix_glob()
    " return two that match prefix glob
    let two_unowned = SharefixUnowned('*own')
    call self.assert_equal(2 * g:sharefix_stub_len, len(two_unowned))
    call self.assert_equal('tester', two_unowned[0]['owner'])
endfunction

function! s:tc.test_suffix_glob()
    " return two that match suffix glob
    let two_unowned = SharefixUnowned('test*')
    call self.assert_equal(2 * g:sharefix_stub_len, len(two_unowned))
    call self.assert_equal('unown', two_unowned[0]['owner'])
endfunction

function! s:tc.test_odd_glob()
    " pass in bad wildcards
    call self.assert_throw('wildcard', "call SharefixUnowned('te*st')")
    call self.assert_throw('wildcard', "call SharefixUnowned('*test*')")
    call self.assert_throw('wildcard', "call SharefixUnowned('te*st*')")
    call self.assert_throw('wildcard', "call SharefixUnowned('*te*st')")
endfunction

function! s:tc.test_empty_glob()
    " search for an owner that does not exist
    let nothing_unowned = SharefixUnowned('nothing')
    call self.assert_equal(len(s:owners) * g:sharefix_stub_len, len(nothing_unowned))
endfunction

function! s:tc.teardown()
    " clear quickfix list and plugin's internal sharefix list
    call setqflist([])
    call SharefixClear()
endfunction
