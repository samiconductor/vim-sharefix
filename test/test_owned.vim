" Description: test setting and getting owned sharefix

let s:tc = unittest#testcase#new('Owned', sharefix#__context__())

function! s:tc.setup()
    " create quickfix stub to own
    call setqflist([{'filename': 'own', 'pattern': 'own'}])
    call self.set('s:quickfix', getqflist())

    " create sharefix stub
    call self.set('s:sharefix', SharefixStub(['test', 'own']))
endfunction

function! s:tc.test_nothing_owned()
    " assert nothing owned yet
    let owned = self.call('s:Owned', [self.get('s:quickfix'), 'own'])
    call self.assert(empty(owned))
endfunction

function! s:tc.test_own()
    " assert owner assigned
    let owned = self.call('s:Own', [self.get('s:quickfix'), 'own'])
    call self.assert_not(empty(owned))
    call self.assert_has_key('owner', owned[0])
    call self.assert_is('own', owned[0]['owner'])
endfunction

function! s:tc.test_owned()
    " make sure getting owned works
    let owned = self.call('s:Owned', [self.get('s:sharefix'), 'own'])
    call self.assert_not(empty(owned))
    call self.assert_has_key('owner', owned[0])
    call self.assert_is('own', owned[0]['owner'])
endfunction

function! s:tc.teardown()
    " clear quickfix list
    call setqflist([])
endfunction
