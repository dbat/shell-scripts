" ==============================================
"  VI WAS BORN DECADES AGO, SO IF IT LOOKS LIKE
"  A STUPID (AND ARCHAIC) MORON, IT IS, INDEED.
" ==============================================

" ==============================================
" *** IMPORTANT! FIRST MAP IS ALWAYS WIN *** "
" ==============================================

" these ctrl stuffs did not work
" map  :q!
" map  :w!
" map  :wq!

" the most dazzling new vi users is how to quit :)
" i found that the easiest key was CTRL-BACKSLASH,
" *press it twice*, the first will bring you ex,
" the second one will terminate it (sure, it will
" then coredumped, but who cares? :))
"
map #10 :q!
map! #10 :q!

"F1=help, F2=save, F3=quit? ENTER to confirm, F4=save and quit
"using ESC first to evade any pending command effects

map #1 :viusage
map #2 :w!
map #3 :q!
map #3 :q!
map #4 :wq!

" Stupid changes in FreeBSD-9+
map OP :viusage
map [23~ :exusage
map OQ :w!
map OR :q!
map OS :wq!

map! OP :viusage
map! [23~ :exusage
map! OQ :w!
map! OR :q!
map! OS :wq!


" ==============================================
" *** IMPORTANT! FIRST MAP IS ALWAYS WIN *** "
" ==============================================

"Same as above, within edit mode (using DOUBLE-ESC)
map! #1 :viusage
map! #2 :w!
map! #3 :q!
map! #3 :q!
map! #4 :wq!

" comment/uncomment section + space
map #5 !}sed s/^/\#\ /}
map #6 !}sed s/^\#\ //}

" comment/uncomment section
map #5 !}sed s/^/\#\ /}
map #6 !}sed s/^\#\ //}

" change spaces to a tab on a commented line on kernel config
map #7 !}sed s/"  *\(\#\#*[^\#]*\)$"/"	\1"/g
map #8 !}sed s/"^\([\# ]*\)options   *"/"\1options 	"/g

" F9, trim trailing spaces
map #9 :%s/[	 ]+$//g
map! #9 :%s/[	 ]+$//g

" ==============================================
" *** IMPORTANT! FIRST MAP IS ALWAYS WIN *** "
" ==============================================

" Shift-F1
map [Y :exusage
map! [Y :exusage

" F8, join lines
map #8 A;J
map! [T A;J

set cedit=
" no longer valid: set escapetime=0
"stupid vim set nowrap here
set matchtime=10
set scroll=1
set shiftwidth=2
set sidescroll=8
set ruler

" wrap setting was (intentionally?) hidden in "leftright" setting
" noleftright means wrap long lines
" there was severe bug which eats 90+ cpu when scrolling right
" failed on (usually) commented line containing tabs
" to avoid many of this, make sure to set sidescroll not less than 8
" it is practically impossible to set sidescroll=1 (as i'd love to),
" but we cannot expect too much to granny editor, could we?

" using: !}sort -t "" +0.7
"
"vim-incompatible-BEGIN:
set   extended
set filec=
set   iclower
set keytime=5
set   leftright
set noaltwerase
set nosearchincr
set recdir=/tmp/vi.recover
"vim-incompatible-END:
"
set noeb
set   edcompatible
set noexrc
" set nomesg
set noreadonly
set   redraw
set noshowmatch
set   showmode
set noterse
set   tildeop
""" set   verbose
"better be on?:
set nowrapscan
set tabstop=4
set tabstop=8
" set recdir=/var/tmp/vi.recover

" ==============================================
" *** IMPORTANT! FIRST MAP IS ALWAYS WIN *** "
" ==============================================

"map [31~ :%s/``/"/g:%s/''/"/g:%s/`/'/g
"map [23~ :exusage

" -------------------------------------------------
" my keyboard map, yours might be different!
" -------------------------------------------------
" ESCAPE				
" KEY:BACKSPACE				
" (note: CTRL-BACKSPACE is equal with: DEL, but not
"        necessary did so on the otherway around)	IDIOT TOSHIBA KEYS
" -------------------------------------------------
" NAME		KEY	SHIFT	CTRL	CTRL-SHIFT	KEY	SHIFT	CTRL	CTRL-SHIFT
" -------------------------------------------------
" F1		[Y	[k	[w	[w		OP	[23~	OP	[23~
" F2		[N	[Y	[l	[x		OQ	[24~	OQ	[24~
" F3		[O	[a	[m	[y		OR	[25~	OR	[25~
" F4		[P	[b	[n	[z		OS	[26~	OS	[26~
" F5		[Q	[c	[o	[@		[15~	[28~	[15~	[28~
" F6		[R	[d	[p	[[		[17~	[29~	[17~	[29~
" F7		[S	[e	[q	[\		[18~	[31~	[18~	[31~
" F8		[T	[f	[r	[]		[19~	[32~	[19~	[32~
" F9		[U	[g	[s	[^		[20~	[33~	[20~	[33~
" F10		[V	[h	[t	[_		[21~	[34~	[21~	[34~
" F11		[W	[i	[u	[`		[23~	[23~	[23~	[23~
" F12		[X	[j	[v	[{		[24~	[24~	[24~	[24~
" -------------------------------------------
" UP		[A	[A	[A	[A		[5~
" DOWN		[B	[A	[B	[B		OB
" RIGHT		[C	[C	[C	[C		OC
" LEFT		[D	[D	[D	[D		OD
" END		[F	[F	[F	[F		[4~
" HOME		[H	[H	[H	[H		[1~
" PGDN		[G	[G	[G	[G		[6~
" PGUP		[I	[I	[I	[I		[5~
" INS		[L	[L	[L	[L		[2~
" DEL							[3~
" MENU		[}	[}	[}	[}		
" -------------------------------------------
" TWO		2	@	 	 		2	@	 	 
" SIX		6	^				6	^		
" DASH		-	_				-	_		
" -------------------------------------------
" OPENBRACKET	[	{		
" CLOSEBRACKET	]	}		
" BACKSLASH	\	|		
" -------------------------------------------------

"" stupid vi doesn't even understands PGUP/PGDN
"" on my braindamage-designed laptop TOSHIBA
"map [5~ 
"map [6~ 
"

" ==============================================
" *** IMPORTANT! FIRST MAP IS ALWAYS WIN *** "
" ==============================================

"" this is for fucking idiot toshiba xterm key END and HOME (xterm)
map [4~ $
map! [4~ $a
map [1~ 0
map! [1~ 0i

"F1=help, F2=save, F3=quit? ENTER to confirm, F4=save and quit
"using ESC first to evade any pending command effects
"for stupid toshiba keyboard with silly putty

map [11~ :viusage
map [12~ :w!
map [13~ :q!
map [13~ :q!
map [14~ :wq!

"Same as above, within edit mode (using DOUBLE-ESC)
map! [11~ :viusage
map! [12~ :w!
map! [13~ :q!
map! [13~ :q!
map! [14~ :wq!

"" this is for another fucking idiot toshiba xterm key END and HOME (cons50)
"map Ow $
"map! Ow $a
"map [H 0
"map! [H 0i
"
""F1..F4 in my braindamaged TOSHIBA laptop (conss50)
"map OP :viusage
"map OQ :w!
"map OR :q!
"map OS :wq!
"
"
""Escaped edit mode
"map! OP :viusage
"map! OQ :w!
"map! OR :q!
"map! OS :wq!
"

" ==============================================
" *** IMPORTANT! FIRST MAP IS ALWAYS WIN *** "
" ==============================================

"OpenBSD's std console also rather stupid; no matter how she
"looks smart to everyshit, stubborn pig is inherently stupid
"
"this is Home & End key for idiot default keymap vt220
map [7~ 0
map [8~ $
map! [7~ 0i
map! [8~ $a

"*nix means server, its hard to imagine that the costly server,
"(say, a 10000 bucks), equiped with a low quality monitor.
"fine if there's none at all, but never a $25's CGA 80x25 monitor
"(that's a quarter of my *low-end, out-of-date* pda display resolution)
"
"set ts=4

