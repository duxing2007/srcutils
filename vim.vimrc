" Remeber to add below line in ~/.vimrc
" source ~/srcutils/vim.vimrc

set number
set hlsearch
set ignorecase
set nowrapscan
set listchars=trail:-,tab:>-
set list
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent
set cscopequickfix=s-,c-,d-,i-,t-,e-
set modeline

filetype plugin on

" gnu global map
map <C-N> :GtagsCursor<CR>

let Tlist_Show_One_File = 1
set statusline=%<%f%=%([%{Tlist_Get_Tagname_By_Line()}]%)

let MRU_Max_Menu_Entries = 100

runtime! ftplugin/man.vim
" Search options quickly
autocmd Filetype man noremap <buffer> s 	<ESC>/^\s\+-

" python begin
autocmd BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufWritePre *.py normal m`:%s/\s\+$//e``
autocmd FileType python set omnifunc=pythoncomplete#Complete
