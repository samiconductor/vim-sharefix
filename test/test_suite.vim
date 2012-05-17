" Description: run all sharefix tests

let test_dir = expand('<sfile>:p:h')

" source sharefix stub helper
exec 'source'.test_dir.'/sharefix_stub.vim'

" source each test in test directory
for test in glob(test_dir.'/test_*', 0, 1)
    " skip test suite script
    if test != expand('<sfile>:p')
        exec 'source '.test
    endif
endfor
