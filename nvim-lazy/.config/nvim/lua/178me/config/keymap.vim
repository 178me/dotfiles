nmap ; :
nmap < <<
nmap > >>
nmap J <nop>
nmap <silent> <Esc> :nohlsearch<cr>

nmap dv ^v$
imap jj <Esc>

cnoremap <C-v> <C-f>
tmap <C-q> <C-\><C-n>
nmap <C-j> }
vmap <C-j> }
nmap <C-k> {
vmap <C-k> {
nmap <C-b> <left>
imap <silent> <C-b> <left>
cmap <C-b> <left>
nmap <C-f> <right>
imap <silent> <C-f> <right>
cmap <C-f> <right>
nmap <C-a> ^
vmap <C-a> ^
imap <silent> <C-a> <C-o>^
cmap <C-a> <home>
nmap <C-e> <end>
vmap <C-e> <end><left>
imap <silent> <C-e> <end>
cmap <C-e> <end>

nmap <silent> <space>jq :bd!<CR>
nmap <silent> <space>jQ :qa!<CR>
nmap <silent> <space>jw :w!<CR>
