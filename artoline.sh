#!/bin/sh
showbanner(){
cat <<::
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
º   Copyright (C) 2003-08, Adrian H, Ray AF & Raisa NF	º
º							º
º	     Private property of PT SoftIndo		º
º	Jl. Mampang Prapatan X No.7, JAKARTA - 12790 	º
º							º
º		http://www.softindo.net			º
ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Synopsys:
  Change $OPDESC and vice versa
  Version 1.0.1, 2008.10.00

Usage:
  [sh] ${0##*/} [ -i ] [ -r ] [ files.. ] 
  where
    -i   : in-place edit, write/apply change to file.
    -r   : reverse operation (convert from $OP1 to $OP2)
    file : file(s) to be converted

art box:
$ARTBOX

line box:
$LINEBOX

::
}; # case "$1" in -[?hH]|--help|[?]) showbanner; exit 0;; esac
printerr() { showbanner; echo -e "Error - $*\nProgram aborted.\n" >&2; exit 1; }

art_dbl1="Ü"
art_dbl2="ß"
art_Top="Í"
art_TopLeft="É"
art_TopRight="»"
art_Bottom="Í"
art_BottomLeft="È"
art_BottomRight="¼"
art_Left="º"
art_Right="º"

art0="$art_dbl1"
art1="$art_TopLeft"
art2="$art_Top"
art3="$art_TopRight"
art4="$art_Left"
art5="$art_Right"
art6="$art_BottomLeft"
art7="$art_Bottom"
art8="$art_BottomRight"
art9="$art_dbl2"

art1_="$art1$art2"
art2_="$art2$art3"
art6_="$art6$art7"
art7_="$art7$art8"

# you may specify any character as line frame including SLASH "/",
# except double colon ":" (it is used as delimiter) or BACKSLASH "\"
# (which is too subtle to be replaced) and of course, NULL char.

line_dbl1="_"
line_dbl2="="
line_Top="-"
line_TopLeft="/"
line_TopRight="+"
line_Bottom="-"
line_BottomLeft="+"
line_BottomRight="/"
line_Left="|"
line_Right="|"

line0="$line_dbl1"
line1="$line_TopLeft"
line2="$line_Top"
line3="$line_TopRight"
line4="$line_Left"
line5="$line_Right"
line6="$line_BottomLeft"
line7="$line_Bottom"
line8="$line_BottomRight"
line9="$line_dbl2"

line1_="$line1$line2"
line2_="$line2$line3"
line6_="$line6$line7"
line7_="$line7$line8"

DEF_WIDTH=48
DEF_HEIGHT=6

makebox() {
  WIDTH="${1:-$DEF_WIDTH}"
  HEIGHT="${2:-$DEF_HEIGHT}"
  BLANK="${3:- }"
  LEFTMARGIN="    "

  echo -n "$LEFTMARGIN"
  w="$(($WIDTH + 2))"; while test "$w" -gt 0; do w="$(($w - 1))"; echo -n "$src0"; done
  echo

  echo -n "$LEFTMARGIN"
  echo -n "$src1"
  w="$WIDTH"; while test "$w" -gt 0; do w="$(($w - 1))"; echo -n "$src2"; done
  echo "$src3"

  i="$HEIGHT"
  while test "$i" -gt 0; do i="$(($i - 1))"
    echo -n "$LEFTMARGIN"
    echo -n "$src4"
    w="$WIDTH"; while test "$w" -gt 0; do w="$(($w - 1))"; echo -n "$BLANK"; done
    echo "$src5"
  done

  echo -n "$LEFTMARGIN"
  echo -n "$src6"
  w="$WIDTH"; while test "$w" -gt 0; do w="$(($w - 1))"; echo -n "$src7"; done
  echo "$src8"

  echo -n "$LEFTMARGIN"
  w="$(($WIDTH +2))"; while test "$w" -gt 0; do w="$(($w - 1))"; echo -n "$src9"; done
  echo
}

setsrcto_art() {
  src0="$art0"; src9="$art9";
  src1="$art1"; src2="$art2"; src3="$art3"; src4="$art4";
  src5="$art5"; src6="$art6"; src7="$art7"; src8="$art8";
  src1_="$art1_"; src2_="$art2_"; src6_="$art6_"; src7_="$art7_";
}

setsrcto_line() {
  src0="$line0"; src9="$line9";
  src1="$line1"; src2="$line2"; src3="$line3"; src4="$line4";
  src5="$line5"; src6="$line6"; src7="$line7"; src8="$line8";
  src1_="$line1_"; src2_="$line2_"; src6_="$line6_"; src7_="$line7_";
}

setrepto_art() {
  rep0="$art0"; rep9="$art9";
  rep1="$art1"; rep2="$art2"; rep3="$art3"; rep4="$art4";
  rep5="$art5"; rep6="$art6"; rep7="$art7"; rep8="$art8";
  rep1_="$art1_"; rep2_="$art2_"; rep6_="$art6_"; rep7_="$art7_";
}

setrepto_line() {
  rep0="$line0"; rep9="$line9";
  rep1="$line1"; rep2="$line2"; rep3="$line3"; rep4="$line4";
  rep5="$line5"; rep6="$line6"; rep7="$line7"; rep8="$line8";
  rep1_="$line1_"; rep2_="$line2_"; rep6_="$line6_"; rep7_="$line7_";
}

case "${0##*/}" in art2*|arto*|artto*|art_*) OP=0;; *) OP=1;; esac

OPREVERSE=
INPLACE_EDIT=

for n in 1 2; do
  case "$1" in
    -r) OP=$((!$OP)); shift;;
    -i) INPLACE_EDIT="-i"; shift;;
  esac
done

case "$1" in -[?hH]|--help|[?]|"")
  case "$OP" in
    0) OPDESC="line art to simple frame"; OP1="art"; OP2="line";;
    1) OPDESC="simple frame to line art"; OP1="line"; OP2="art";;
  esac
  setsrcto_art; ARTBOX=`makebox`; 
  setsrcto_line; LINEBOX=`makebox`; 
  showbanner; exit 0;;
esac

case "$OP" in
  0) setsrcto_art; setrepto_line;;
  1) setsrcto_line; setrepto_art;;
esac

TAB="	"
MINTABS=6
MINWIDE=24

# for file; do
#   sed \
#     -e "/^$src0\{$MINWIDE,\}/s/$src0/$rep0/g" -e "/^$src9\{$MINWIDE,\}/s/$src9/$rep9/g" \
#     -e "/^$src1_$src2\{$MINWIDE,\}$src2_/{s/$src1/$rep1/;s/$src2/$rep2/g;s/$src3/$rep3/;}" \
#     -e "/^$src4.\{$MINWIDE,\}$src5/{s/$src4/$rep4/;s/$src5/$rep5/;}" \
#     -e "/^$src4$TAB\{$MINTABS,\}$src5/{s/$src4/$rep4/;s/$src5/$rep5/;}" \
#     -e "/^$src6_$src7\{$MINWIDE,\}$src7_/{s/$src6/$rep6/;s/$src7/$rep7/g;s/$src8/$rep8/;}" \
#   "$file"
# done

for file; do
  sed $INPLACE_EDIT "" \
    -e "\:^$src0\{$MINWIDE,\}:s:$src0:$rep0:g" -e "\:^$src9\{$MINWIDE,\}:s:$src9:$rep9:g" \
    -e "\:^$src1_$src2\{$MINWIDE,\}$src2_:{s:$src1:$rep1:;s:$src2:$rep2:g;s:$src3:$rep3:;}" \
    -e "\:^$src4.\{$MINWIDE,\}$src5:{s:$src4:$rep4:;s:$src5:$rep5:;}" \
    -e "\:^$src4$TAB\{$MINTABS,\}$src5:{s:$src4:$rep4:;s:$src5:$rep5:;}" \
    -e "\:^$src6_$src7\{$MINWIDE,\}$src7_:{s:$src6:$rep6:;s:$src7:$rep7:g;s:$src8:$rep8:;}" \
  "$file"
done
