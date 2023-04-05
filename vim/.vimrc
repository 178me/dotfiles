" 设置leader键位为空格
let mapleader=" "
" 识别不同文件格式
set nocompatible
filetype on
filetype indent on
filetype plugin on
filetype plugin indent on
" 鼠标开关
set mouse=a
" 字符编码
set encoding=utf-8
" 配色标准
let &t_ut=''
" 设置透明背景
if executable("vimtweak.dll")
autocmd guienter * call libcallnr("vimtweak","SetAlpha",222)
endif
" 高亮开
syntax on
" Tab缩进设置
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set tw=0
set indentexpr=
" 显示空格
set list
set listchars=tab:▸\ ,trail:▫
" 光标固定在上5行和下5行
set scrolloff=8
" 退格键能从下一行删除到上一行
set backspace=indent,eol,start
" 收起代码
set foldmethod=indent
set foldlevel=99
" 修改普通模式下的光标和插入模式的光标 
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"
" 状态栏调整
set laststatus=2
" 在当前目录下执行命令
set autochdir
" 保存修改时的位置
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
" 设置行号
set nu
" 显示行的效果
set relativenumber
" 在当前行显示有一条线
set cursorline
" 自动换行
set wrap
" 显示输入的字符
set showcmd
" 补全命令
set wildmenu
" 搜索的设置
set hlsearch
exec "nohlsearch"
set incsearch
set ignorecase
set smartcase

" 使用系统剪贴板
set clipboard=unnamedplus
" 重载配置文件
" 快速保存
" 快速退出
" 强制退出
" 可读文件保存
map <leader>fr :source ~/.config/nvim/init.vim<CR>
map S :w<CR>
map Q :q!<CR>
map <LEADER>fw :w !sudo tee %<CR>
map <leader>fs :r !figlet

" 上下左右分屏
noremap <leader>wK :set nosplitbelow<CR>:split<CR>
noremap <leader>wJ :set splitbelow<CR>:split<CR>
noremap <leader>wH :set nosplitright<CR>:vsplit<CR>
noremap <leader>wL :set splitright<CR>:vsplit<CR>

" 上下左右交换位置
map <leader>wv <C-w>t<C-w>K
map <leader>wb <C-w>t<C-w>H

" 切换窗口焦点
map <LEADER>wk <C-w>k
map <LEADER>wj <C-w>j
map <LEADER>wh <C-w>h
map <LEADER>wl <C-w>l

" 修改窗口大小
map <up> :res +5<CR>
map <down> :res -5<CR>
map <left> :vertical resize-5<CR>
map <right> :vertical resize+5<CR>

" 新建标签
" 向前切换标签
" 向后切换标签
map <leader>tt :tabe<CR>
map <leader>t, :-tabnext<CR>
map <leader>t. :+tabnext<CR>


" 禁用J
" 用于分屏
map J <nop>
map s <nop>

" 代替home end
map z <nop>
map z $
map Z 0

"插入模式下 使用 emacs 的移动方式
fun! Exec(cmd)
    exe a:cmd
    return ''
endf
map <silent><C-e> $
" map <silent><C-a> ^
inoremap <C-p>  <up>
inoremap <C-n>  <down>
inoremap <C-b>  <left>
inoremap <C-f>  <right>
inoremap <silent><C-a> <c-r>=Exec('norm! I')<cr><right>
inoremap <silent><C-e> <c-r>=Exec('norm! A')<cr><right>
inoremap <silent><A-f> <c-r>=Exec('norm! e')<cr><right>
inoremap <silent><A-B> <c-r>=Exec('norm! b')<cr>

" 快速跳到单词结尾
inoremap <silent><C-j> <Esc>/\w\><cr>:noh<cr>a
inoremap <silent><C-k> <Esc>?\w\><cr>:noh<cr>a

" 快速删除
inoremap <silent> `` `
inoremap <silent> `p <C-r>"
inoremap <silent> `' <c-r>=Exec("norm! di'")<cr>
inoremap <silent> `" <c-r>=Exec('norm! di"')<cr>
inoremap <silent> `) <c-r>=Exec("norm! di)")<cr>
inoremap <silent> `] <c-r>=Exec("norm! di]")<cr>
inoremap <silent> `} <c-r>=Exec("norm! di}")<cr>
inoremap <silent> `> <c-r>=Exec("norm! di>")<cr>

" 简化操作
noremap <silent><C-j> o<Esc>
noremap <silent><C-k> O<Esc>
noremap <silent><C-l> {
noremap <silent><C-h> }
inoremap jj <Esc><Esc>


" 简化操作
nnoremap < <<
nnoremap > >>
noremap H 5j
noremap L 5k
noremap D dw

" Symbol renaming.
vnoremap <leader>rc "hy<Esc><Esc>:%s/<C-r>h//g<left><left>
nmap <leader>rv <Plug>(coc-rename)
vnoremap <leader>rr :s/<C-r>a/<C-r>b/g
noremap <LEADER>rg :%s//g<left><left>

" 复制 <leader>y
noremap <leader>ya viw"ay
noremap <leader>yb viw"by
noremap <leader>yj viw"jy
noremap <leader>yw yi"
noremap <leader>ye yi)
vnoremap <leader>ya "ay
vnoremap <leader>yb "by
vnoremap <leader>yj "jy
vnoremap <leader>yy "+y

" 复制 <leader>y
noremap <leader>va ggVG
noremap <leader>vf {v}
noremap <leader>vw vi"
noremap <leader>ve vi)

""" other
" 大字体
" 关闭高亮
" markdown表格
" Copy to system clipboard
" 寻找并修改
" 打开一个终端
noremap <LEADER><CR> :nohlsearch<CR>
noremap <LEADER>mt :TableModeToggle<CR>
noremap  <LEADER><LEADER> <Esc>/<CR>:nohlsearch<CR>c4l
noremap <LEADER>s :set splitbelow<CR>:sp<CR>:term<CR>
" Auto change directory to current dir
autocmd BufEnter * silent! lcd %:p:h
" 识别文件格式，然后执行相对应的命令
func! CompileRunGcc()
	exec "w"
	if &filetype == 'c'
		exec "!g++ % -o %<"
		exec "!time ./%<"
	elseif &filetype == 'sh'
		:!time bash %
	elseif &filetype == 'markdown'
		exec "MarkdownPreview"
	endif
endfunc
"   取消注释安装插件工具plug
"   call plug#begin('~/.vim/plugged')
"
"   " Make sure you use single quotes
"
"   " Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
"   Plug 'junegunn/vim-easy-align'
"
"   " Any valid git URL is allowed
"   Plug 'https://github.com/junegunn/vim-github-dashboard.git'
"
"   " Multiple Plug commands can be written in a single line using | separators
"   Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
"
"   " On-demand loading
"   Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
"   Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
"
"   " Using a non-master branch
"   Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
"
"   " Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
"   Plug 'fatih/vim-go', { 'tag': '*' }
"
"   " Plugin options
"   Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }
"
"   " Plugin outside ~/.vim/plugged with post-update hook
"   Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"
"   " Unmanaged plugin (manually installed and updated)
"   Plug '~/my-prototype-plugin'
"
"   " Initialize plugin system
"   call plug#end()

" ----------------------------------------
" 插件安装 " 
call plug#begin('~/.vim/plugged')
" 状态栏和配色
Plug 'vim-airline/vim-airline'
Plug 'connorholyday/vim-snazzy'
" markdown网页浏览
Plug 'iamcco/markdown-preview.vim'
" markdown表格
Plug 'dhruvasagar/vim-table-mode', { 'on': 'TableModeToggle' }
Plug 'liuchengxu/vim-which-key'

"Plug 'gabrielelana/vim-markdown'

call plug#end()
" ===
" === MarkdownPreview
" ===
let g:mkdp_path_to_chrome = "chromium"
let g:mkdp_auto_start = 0
let g:mkdp_browser = 'chrome'
source ~/.vim/Markdown.vim
" ------------------------------------------------
" 配色
let g:SnazzyTransparent = 1
color snazzy


" which-key
set timeoutlen=0
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
let g:which_key_position = 'botright'
let g:which_key_map =  {}
