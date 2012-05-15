" Description: test filtering sharefix

let s:tc = unittest#testcase#new('Filtered', sharefix#__context__())

function! s:tc.setup()
    " create sharefix stub
    call self.set('s:sharefix', SharefixStub(['test', 'filter']))
endfunction

function! s:tc.test_has_filter()
    " make sure filter owns some quickfixes
    let filter_fixes = filter(copy(self.get('s:sharefix')), "v:val['owner'] == 'filter'")
    call self.assert_not(empty(filter_fixes))
endfunction

function! s:tc.test_filtered()
    " filter out filter owner
    let filtered = self.call('s:Filtered', [self.get('s:sharefix'), 'filter'])
    let filter_fixes = filter(copy(filtered), "v:val['owner'] == 'filter'")
    call self.assert_not(empty(filtered))
    call self.assert(empty(filter_fixes))
endfunction
