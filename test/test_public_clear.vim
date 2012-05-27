" Description: test public clear command

let s:tc = unittest#testcase#new('Public Clear', sharefix#__context__())

function! s:tc.setup()
    " create sharefix stub apply it to plugin's internal sharefix list
    let s:owners = ['test']
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
    call SharefixClear()
    call self.assert(empty(self.get('s:sharefix_list')))
endfunction
