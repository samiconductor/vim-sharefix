" Description: test setting and getting owned sharefix

let s:tc = unittest#testcase#new('Owned', sharefix#__context__())

function! s:tc.setup()
    " create quickfix stub to own
    call setqflist([{'filename': 'own', 'pattern': 'own'}])
    let s:quickfix_list = getqflist()

    " create sharefix stub
    let s:sharefix_test_list = SharefixStub('test', 'own', 'spaces allowed')
endfunction

function! s:tc.test_nothing_owned()
    " assert nothing owned yet
    let owned = self.call('s:Owned', [s:quickfix_list, 'own'])
    call self.assert(empty(owned))
endfunction

function! s:tc.test_own()
    " assert owner assigned
    let owner = 'own'
    let owned = self.call('s:Own', [s:quickfix_list, owner])
    call self.assert_not(empty(owned))
    call self.assert_has_key('owner', owned[0])
    call self.assert_is(owner, owned[0]['owner'])
endfunction

function! s:tc.test_owned()
    " make sure getting owned works
    let owned = self.call('s:Owned', [s:sharefix_test_list, 'own'])
    call self.assert_not(empty(owned))
    call self.assert_has_key('owner', owned[0])
    call self.assert_is('own', owned[0]['owner'])
endfunction

function! s:tc.test_owner_with_spaces()
    " make sure getting owner with spaces works
    let owner = 'spaces allowed'
    let owned = self.call('s:Owned', [s:sharefix_test_list, owner])
    call self.assert_not(empty(owned))
    call self.assert_has_key('owner', owned[0])
    call self.assert_is(owner, owned[0]['owner'])
endfunction

function! s:tc.test_own_error_text()
    " assert error text prepended with owner
    let owned_errors = self.call('s:OwnErrorText', [s:sharefix_test_list])
    for owned_error in owned_errors
        call self.assert_match('^'.owned_error['owner'], owned_error['text'])
    endfor
endfunction

function! s:tc.test_own_error_text_once()
    " assert error text not prepended more than once
    let owned_errors = self.call('s:OwnErrorText', [s:sharefix_test_list])
    let owned_errors = self.call('s:OwnErrorText', [owned_errors])
    for owned_error in owned_errors
        call self.assert_not_match('^\('.owned_error['owner'].': \)\{2}', owned_error['text'])
    endfor
endfunction

function! s:tc.teardown()
    " clear quickfix list
    call setqflist([])
endfunction
