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
  swap shell script's magic header between /bin/ and /rescue/

Usage:
  [sh] ${0##*/}
ÿ
::
}; case "$1" in -[?hH]|--help|[?]) showbanner; exit 0;; esac
printerr() { showbanner; echo -e "Error - $*\nProgram aborted.\n"; exit 1; }

this="${0##*/}"; this="${this%.sh}"
case "$this" in
  b2r|bin2rescue) search=bin; replace=rescue;;
  r2b|rescue2bin) search=rescue; replace=bin;;
  *) printerr invalid script name "$0";;
esac; #search="\/$search\/"; replace="\/$replace\/"

read -p "
replace header: /$search/ with /$replace/
caution:
  this will modify ALL files in current dir
  are you sure want to continue [Y]?" ans
case "$ans" in ""|[yY]);; *) printerr;; esac
echo

n=0; resvname=":$this:b2r|r2b:bin2rescue:rescue2bin:"
for sh in *; do
  sh0="${sh%.sh}"
  test -z "${resvname##*:$sh0:*}" && continue
  echo -n "- $sh "
  magic=`sed -n 1p $sh`
  test "$magic" = "#!/${search}/sh" || { echo skipped; continue; }
  sed -i "" 1s/"^[#][!]\/$search\/"/"#!\/$replace\/"/ "$sh" && n=$(($n+1))
  echo OK
done

test "$n" = "0" && n=no
echo; echo $n files modified


