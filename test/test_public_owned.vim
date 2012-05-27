" Description: test public owned command

let s:tc = unittest#testcase#new('Public Owned', sharefix#__context__())

function! s:tc.setup()
    " create sharefix stub apply it to plugin's internal sharefix list
    let s:owners = ['test', 'tester', 'own', 'unown']
    for owner in s:owners
        call SharefixStub(owner)
        call self.call('s:Extended', [owner])
    endfor
endfunction

function! s:tc.test_owned()
    " return quickfixes for exact match
    let owned = SharefixOwned('own')
    call self.assert_equal(g:sharefix_stub_len, len(owned))
endfunction

function! s:tc.test_all_owned()
    " return all quickfixes
    let all_owned = SharefixOwned('*')
    call self.assert_equal(len(s:owners) * g:sharefix_stub_len, len(all_owned))
endfunction

function! s:tc.test_prefix_glob()
    " return two that match prefix glob
    let two_owned = SharefixOwned('*own')
    call self.assert_equal(2 * g:sharefix_stub_len, len(two_owned))
    call self.assert_equal('unown', two_owned[0]['owner'])
endfunction

function! s:tc.test_suffix_glob()
    " return two that match suffix glob
    let two_owned = SharefixOwned('test*')
    call self.assert_equal(2 * g:sharefix_stub_len, len(two_owned))
    call self.assert_equal('tester', two_owned[0]['owner'])
endfunction

function! s:tc.test_odd_glob()
    " pass in bad wildcards
    call self.assert_throw('wildcard', "call SharefixOwned('te*st')")
    call self.assert_throw('wildcard', "call SharefixOwned('*test*')")
    call self.assert_throw('wildcard', "call SharefixOwned('te*st*')")
    call self.assert_throw('wildcard', "call SharefixOwned('*te*st')")
endfunction

function! s:tc.test_empty_glob()
    " search for an owner that does not exist
    let nothing_owned = SharefixOwned('nothing')
    call self.assert_equal(0, len(nothing_owned))
endfunction

function! s:tc.teardown()
    " clear quickfix list and plugin's internal sharefix list
    call setqflist([])
    call SharefixClear()
endfunction
