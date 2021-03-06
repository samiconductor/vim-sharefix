" Description: run all sharefix tests

let test_dir = expand('<sfile>:p:h')
let project_dir = expand('<sfile>:p:h:h')

" reload plugin
unlet g:loaded_sharefix
exec 'source '.project_dir.'/plugin/sharefix.vim'

" source helpers
for helper in glob(test_dir.'/helper/*', 0, 1)
    exec 'source '.helper
endfor

" source each test
for test in glob(test_dir.'/test_*', 0, 1)
    " skip test suite script
    if test != expand('<sfile>:p')
        exec 'source '.test
    endif
endfor
