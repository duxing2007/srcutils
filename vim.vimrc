" Remeber to add below line in ~/.vimrc
" source ~/srcutils/vim.vimrc

" Vundle.vim begin..

syntax off
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'


Plugin 'mru.vim'
Plugin 'klen/python-mode'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Vundle.vim end...
set number
set hlsearch
set ignorecase
set nowrapscan
set listchars=trail:-,tab:>-
set nolist
set tabstop=2
set softtabstop=2
set shiftwidth=2
set smarttab
set autoindent
set cscopequickfix=s-,c-,d-,i-,t-,e-
set modeline
set fileencodings=ucs-bom,utf-8,cp936,gb2312,latin1
set autoindent

set background=dark
colorscheme desert


" gnu global map
map <C-N> :GtagsCursor<CR>

let Tlist_Show_One_File = 1
set statusline=%<%f%=%([%{Tlist_Get_Tag_Prototype_By_Line()}]%)

let MRU_Max_Menu_Entries = 100

runtime! ftplugin/man.vim
" Search options quickly
autocmd Filetype man noremap <buffer> s 	<ESC>/^\s\+-
autocmd FileType c,cpp setlocal equalprg=clang-format


" python begin
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

" RunFind()

function! s:RunFind(filename)
    botright copen
    let efm_org = &efm
    let &efm="%f"
    let cmd ='find . -name .git -prune -o -name .svn -prune -o -name .repo  -prune -o  -type f -iname ' . '"*' . a:filename . '*" -print'
    let result = system(cmd)
    cexpr! result
    let &efm = efm_org
endfunction

command! -nargs=1 Find call s:RunFind(<f-args>)

" Cgrep
command! -nargs=1 Cgrep :vimgrep "<args>\c" **/*.c **/*.h **/*.cpp **/*.hh **/*.cc **/*.hpp   | copen

" Jgrep
command! -nargs=1 Jgrep :vimgrep "<args>\C" **/*.java  | copen

" M4grep
command! -nargs=1 M4grep :vimgrep "<args>\C" **/*.m4 **/*.am configure.ac  | copen

" Pgrep
command! -nargs=1 Pgrep :vimgrep "<args>\c" **/*.php  | copen
