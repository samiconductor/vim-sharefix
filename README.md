## Description

Sharefix addresses the pain point of your quickfix list being wiped out
between running different commands or functions that update the list.

For example, you run your unit tests and get a list of tests that
failed. Then when you make some changes, write the file, and your linter
auto command kicks off and clears the list of tests. Now to fix the
other failed tests you have to rerun all your tests.

Sharefix lets you easily make your quickfix commands or functions play
nicely together and share the list with each other.

## Install

Unzip
[sharefix.zip](http://www.vim.org/scripts/script.php?script_id=4098)
into your vim runtime or if you have
[pathogen](https://github.com/tpope/vim-pathogen) installed you can
clone the project into your runtime.

## Example Usage

I use sharefix to share the quickfix list between running unit tests
with [nose](https://github.com/lambdalisue/nose.vim.git) and linting my
code with [flake8](https://github.com/nvie/vim-flake8.git) each write.
Here are a set of mappings you might use:

    " run nose tests
    nnoremap <silent> <Leader>pt :compiler nose \| call Sharefix('nosetests', 'All tests passed', 'silent make')<CR>
    " call flake8 on write
    au BufWritePost *.py call Sharefix('flake8', '', function('Flake8'))

## Help

See `:h sharefix` or
[doc/sharefix.txt](https://github.com/samiconductor/vim-sharefix/blob/master/doc/sharefix.txt)

## Companion Plugins

I recommend installing the vimerable Tim Pope's
[unimpaired](https://github.com/tpope/vim-unimpaired) plugin for
quickfix shortcuts.

## Tests

If you are contributing, you will need the
[unittest](https://github.com/h1mesuke/vim-unittest) plugin to run the
tests. Use the following command to run the tests when you're at the
root of the project:

`:UnitTest test/test_suite.vim`

## Requirements

* vim7.3+
