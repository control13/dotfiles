set listchars=tab:>·,trail:~,extends:>,precedes:<,space:·
set list
lua << EOF
  return require('packer').startup(function(use)
    --use 'patstockwell/vim-monokai-tasty'
    use 'tanvirtin/monokai.nvim'
  end)
EOF
" colorscheme vim-monokai-tasty
colorscheme monokai
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59
highlight Whitespace guifg=#4a4a59
nnoremap <C-n> :NvimTreeToggle<CR>
set termguicolors
set showmatch
set hlsearch
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
set autoindent
set number
set noshowmode
" set rnu
filetype plugin indent on
syntax on
set guicursor&
set cursorline
hi CursorLine cterm=NONE guibg=Grey19 ctermbg=236
hi Visual guifg=#000000 guibg=#bbbbbb gui=none
command Sudow w ! sudo tee %
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
nmap <leader>ff <Plug>SnipRun
vmap <leader>f <Plug>SnipRun
autocmd TermOpen * setlocal norelativenumber nonumber
