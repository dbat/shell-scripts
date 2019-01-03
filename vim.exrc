" The MOST important option in vi
set noeb

" Vim loves beeping so much its harder and somewhat
" unobvious to be shuted off. I had to *physically*
" remove the internal pc speaker before eventually
" found that buried-ref about how to do it :)
set vb t_vb=

" Second next important
" F3 is quit all
map #3 :qa!
map #10 :qa!
set history=256
set mouse=nvch
set ignorecase
set smartcase
"set virtualedit=

"set altwerase
"set escapetime=0
"set keytime=2
set scroll=1
"set leftright

set sidescroll=4
"set iclower
set noterse
set showmatch
set matchtime=1
set showmode
set redraw
"FUCKset searchinc
set tildeop
"set cedit=
"set filec=

set verbose=0
set noreadonly
set more

"better on: set nowrapscan
"set extended
set nowrap
set nomesg
set sw=2
set ruler

"map gembel adoh
"map idiot lontong
"
"map bego! mapping yang paling duluan yang menang
"map bego! mapping yang paling duluan yang menang
"map bego! gimana sih tolol mapping yang paling duluan yang menang

"map  :q!
"map  :w!

"map #1 :viusage
"map! #1 :viusage
"map [Y :exusage
"map! [Y :exusage

map #2 :w!
map #3 :q!
map #4 :wqa!
map #5 !}sed s/^/\#\ /}
map #6 !}sed s/^\#\ //}
map #8 :%s/ +//

"map #8 A;J
"map! [T A;J

map <F10> :qa!
map! <F10> :qa!

"map [S :%s/_//g:%s/.//g	F7
"unmap [S
"
"map! #1 :viusage
"map! [Y :exusage

map! #2 :w!i
map! #3 :q!
map! #4 :wqa!
map! #8 :%s/ +//

"map [23~ :exusage
"map [31~ :%s/``/"/g:%s/''/"/g:%s/`/'/g
"
"map #: this is for fucking idiot toshiba xterm key END and HOME
"map [4~ $
"map! [4~ $a
"map [1~ 0
"map! [1~ 0i
"
"map # this is for fucking idiot toshiba xterm key END and HOME
"map Ow $
"map! Ow $a
"map [H 0
"map! [H 0i
"unmap #
