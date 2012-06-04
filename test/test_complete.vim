" Description: test completion for commands

let s:tc = unittest#testcase#new('Complete', sharefix#__context__())

function! s:tc.setup()
    " create sharefix stub apply it to plugin's internal sharefix list
    let s:owners = ['test', 'tester', 'own', 'unown']
    for owner in s:owners
        call SharefixStub(owner)
        call self.call('s:Extended', [owner])
    endfor
endfunction

function! s:tc.test_get_owners()
    " assert getting owners works
    let owners = self.call('s:GetOwners', [self.get('s:sharefix_list')])
    call self.assert_equal(sort(copy(s:owners)), sort(owners))
endfunction

function! s:tc.test_complete_nothing()
    " assert completing nothing returns all owners
    let owners = self.call('s:SharefixComplete', ['', '', 0])
    call self.assert_equal(sort(copy(s:owners)), sort(owners))
endfunction

function! s:tc.test_complete_match()
    " assert completing beginning returns all matches
    let arg = 'te'
    let owners = self.call('s:SharefixComplete', [arg, '', 0])
    let expected_owners = filter(copy(s:owners), 'v:val =~ arg')
    call self.assert_equal(sort(expected_owners), sort(owners))
endfunction

function! s:tc.test_complete_exact()
    " assert completing beginning returns all matches
    let arg = 'tester'
    let owners = self.call('s:SharefixComplete', [arg, '', 0])
    call self.assert_equal([arg], owners)
endfunction

function! s:tc.teardown()
    " clear quickfix list and plugin's internal sharefix list
    SharefixClear
endfunction
