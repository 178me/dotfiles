" use your plugin manager, here is `vim-plug`
call plug#begin('~/.config/nvim/plugged')
Plug 'kevinhwang91/rnvimr'
let g:rnvimr_vanilla = 1
tnoremap <silent> <M-i> <C-\><C-n>:RnvimrResize<CR>
nnoremap <silent> <space>jr :RnvimrToggle<CR>
tnoremap <silent> <M-o> <C-\><C-n>:RnvimrToggle<CR>
call plug#end()
