" Description: test extending sharefix

let s:tc = unittest#testcase#new('Extended', sharefix#__context__())

function! s:tc.setup()
    " create sharefix stub
    call self.set('s:sharefix', SharefixStub('test'))

    " setup initial test quickfix
    call self.call('s:Extended', ['test'])
endfunction

function! s:tc.test_extended()
    " assert extended length is old plus new
    let extend_fix = SharefixStub('extend')
    let extended = self.call('s:Extended', ['extend'])
    let total_len = len(self.get('s:sharefix')) + len(extend_fix)
    call self.assert_equal(len(extended), total_len)
endfunction

function! s:tc.test_unowned_remain()
    " make sure other quickfix errors remain
    call setqflist([])
    let unowned = self.call('s:Extended', ['other'])
    call self.assert_equal(self.get('s:sharefix'), unowned)
endfunction

function! s:tc.teardown()
    " clear quickfix list
    call SharefixClear('*')
endfunction
