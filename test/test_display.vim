" Description: test sharefix display method

let s:tc = unittest#testcase#new('Display', sharefix#__context__())

function! s:tc.SETUP()
    " get current jump first setting and disable it
    call self.set('s:old_jump_first', g:sharefix_jump_first)
    let g:sharefix_jump_first = 0
endfunction

function! s:tc.setup()
    " close quickfix
    cclose

    " create sharefix stub
    let s:sharefix_test_list = SharefixStub('test')
endfunction

function! s:tc.test_not_opened()
    " assert sharefix is not opened when empty
    call self.call('s:Display', [[], 'test'])
    call self.assert_not(QuickbufExists())
endfunction

function! s:tc.test_opened()
    " assert sharefix opened when not empty
    call self.call('s:Display', [s:sharefix_test_list, 'test'])
    call self.assert(QuickbufExists())
endfunction

function! s:tc.test_close_empty_sharefix()
    " assert sharefix is closed when empty results
    call self.call('s:Display', [s:sharefix_test_list, 'test'])
    call self.call('s:Display', [[], 'test'])
    call self.assert_not(QuickbufExists())
endfunction

function! s:tc.teardown()
    " close quickfix
    cclose

    " clear quickfix list
    call setqflist([])
    let s:sharefix_test_list = []
endfunction

function! s:tc.TEARDOWN()
    " reset jump first
    let g:sharefix_jump_first = self.get('s:old_jump_first')
endfunction
