#!/bin/sh

help() {
  echo "allow shits to be floating up and around"
  echo "argument: on = allow, off = stfu"
#   echo "you can give any variance of true/false as argument"
#   echo "or even as prefix and/or suffix of this script name"
#   echo "together they will be logically calculated"
  echo "version: 2014.01.04"
}

JUNKS=

ICONV="
/usr/local/bin/iconv
/usr/local/lib/libiconv.so.3
/usr/local/lib/libiconv.a
"

GETTEXT="
/usr/local
/usr/local/bin
/usr/local/bin/autopoint
/usr/local/bin/envsubst
/usr/local/bin/gettext
/usr/local/bin/gettext.sh
/usr/local/bin/gettextize
/usr/local/bin/msgattrib
/usr/local/bin/msgcat
/usr/local/bin/msgcmp
/usr/local/bin/msgcomm
/usr/local/bin/msgconv
/usr/local/bin/msgen
/usr/local/bin/msgexec
/usr/local/bin/msgfilter
/usr/local/bin/msgfmt
/usr/local/bin/msggrep
/usr/local/bin/msginit
/usr/local/bin/msgmerge
/usr/local/bin/msgunfmt
/usr/local/bin/msguniq
/usr/local/bin/ngettext
/usr/local/bin/recode-sr-latin
/usr/local/bin/xgettext
/usr/local/lib
/usr/local/lib/libasprintf.a
/usr/local/lib/-libasprintf.so
/usr/local/lib/libasprintf.so.0
/usr/local/lib/libgettextlib-0.18.3.so
/usr/local/lib/-libgettextlib.so
/usr/local/lib/libgettextpo.a
/usr/local/lib/-libgettextpo.so
/usr/local/lib/libgettextpo.so.5
/usr/local/lib/-libgettextsrc.so
/usr/local/lib/libgettextsrc-0.18.3.so
/usr/local/lib/libintl.a
/usr/local/lib/libintl.so.9
/usr/local/include/libintl.h
/usr/local/include/gettext-po.h
/usr/local/include/autosprintf.h
"

JUNK_LIST=
## code below is okay, but i don't think we need it that hard
## (it scans the whole main filesystem in order to get filelists of craps)
# 
# JUNK_names="[Sh][Ii][Tt] [Cc][Rr][Aa][Pp] [Jj][Uu][Nn][Kk] [Ss][PpCc][Aa][Mm]"
# 
# JUNK_scandirs=
# for root0 in . "" /usr /usr/local ; do
#   for root1 in etc etc/rc.d include share; do
#     for root2 in $JUNK_names; do
#       JUNK_scandirs="$JUNK_scandirs $root0/$root1 $root0/$root1/$root2"
#       JUNK_scandirs="$JUNK_scandirs $root0/$root1/${root2}s"
#     done
#   done
# done
# #echo JUNK_scandirs="$JUNK_scandirs"
# 
# JUNK_scanfix=
# for dir in $JUNK_scandirs; do test -d "$dir" && JUNK_scanfix="$JUNK_scanfix $dir"; done
# #echo JUNK_scanfix="$JUNK_scanfix"
# 
# JUNK_exts="[lL][Ss][Tt] [Ll][Ii][Ss][Tt]"
# for dirs in $JUNK_scanfix; do
#   for names in $JUNK_names; do
#     for dups in "" [Ss]; do
#       for exts in $JUNK_exts; do
#         testlist="`echo $dirs/$names$dups.$exts`"
#         test -f "$testlist" -a -r "$testlist" && JUNK_LIST="$JUNK_LIST $testlist"
#       done
#     done
#   done
# done
# #echo JUNK_LIST="$JUNK_LIST"

[ -n "$JUNK_LIST" ] && JUNKS="$JUNKS `cat "$JUNK_LIST"`"

get_bool() {
  case "$1" in
    0|N|n|F|f|[Nn][Oo]|[Dd][Oo][Nn][Tt]|[Nn][Oo][Tt]|[Oo][Ff][Ff]|[Ff][Aa][Ll][Ss][Ee]|[Dd][Ii][Ss]*|[Ss][Tt][Oo][Pp]) echo "0";;
    1|Y|y|T|t|[Oo][Kk]|[Dd][Oo]|[Yy][Ee][Ss]|[Oo][Nn]|[Tt]|[Tt][Rr][Uu][Ee]|[Ee][Nn][Aa]*|[Ss][Tt][Aa][Rr][Tt]|[Aa][Ll][Ll][Oo][Ww]) echo "1";;
  esac
}

unset MAY_JUNK
#first, get primary toggle command from prefix
this_script="$0"
this_script="${this_script##*/}"
case $this_script in
  no[-_]*|no*|dont*|dis*|stop*|*[-_]off) MAY_JUNK=0;;
  do[-_]*|do*|allow*|ena*|start*|*[-_]on) MAY_JUNK=1;;
esac

#then get toggle command from suffix
opt="`get_bool ${this_script##*_}`"
if test -n "$opt"; then
  [ -z "$MAY_JUNK" ] && MAY_JUNK="$opt" || \
    { [ "$opt" = "0" ] && MAY_JUNK="$((! $MAY_JUNK))"; }
fi

#third, get it from supplied argument
[ "$1" ] && arg="`get_bool "$1"`"
if test -n "$arg"; then
  [ -z "$MAY_JUNK" ] && MAY_JUNK="$arg" || \
    { [ "$arg" = "0" ] && MAY_JUNK="$((! $MAY_JUNK))"; }
fi

test  "$VERBOSE" = "1" && VERBOSE="-v" || VERBOSE=
JUNKS="$ICONV $GETTEXT"
JUNK_PREFIX=JUNK
for name in $JUNKS; do
  dir="${name%/*}"
  test -w "$dir" || continue

  orig=${name##*/}
  junk="${JUNK_PREFIX}_$orig"

  fn_orig="$name"
  fn_junk="$dir/$junk"

  case $MAY_JUNK in
    0) test -f "$fn_orig" -a -w "$fn_orig" && { mv $VERBOSE "$fn_orig" "$fn_junk"; } ;;
    1) test -f "$fn_junk" -a -w "$fn_junk" && { mv $VERBOSE "$fn_junk" "$fn_orig"; } ;;
    *) help; return 2;;
  esac
done

case $MAY_JUNK in
	0) echo "done cleanup craps.";;
	1) echo "going dirty now..";;
esac

