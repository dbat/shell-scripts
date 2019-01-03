#!/bin/sh
showbanner(){
cat <<::
_________________________________________________________
/-------------------------------------------------------+
|   Copyright (C) 2003-08, Adrian H, Ray AF & Raisa NF	|
|							|
|	     Private property of PT SoftIndo		|
|	Jl. Mampang Prapatan X No.7, JAKARTA - 12790 	|
|							|
|		http://www.softindo.net			|
+-------------------------------------------------------/
=========================================================

Synopsys:
  Package check dependencies, against INDEX file (based on pkg_dep 1.0.3)

  Version: 1.0.1e
  Created: 170801
  Updated: 170901

Usage:
  [sh] ${0##*/} [ -i INDEX ] [ -b | -r ] [ -s | -x ] [ -l | -t ] [ PACKAGES... ]

Where:
  -b | -r   : scan for build or runtime dependencies. DEFAULT: -b
  -l | -t   : simple list or pretty (tree) format. DEFAULT: -l
  -s | -x   : skip or include noisy x11 port, DEFAULT: -s (skip)
  -i INDEX  : index file, required. make, fetch or download it.

  Those options above (-b/r, -i, -l/t, -s/x) should be given first.
  Order and count is not important, the last option given will
  override the previous ones.

  PACKAGE can be typed as:
    [ package ] (no switch) : full package name as in package tarball
    [ -p port ]             : port name, may result in many packages
    [ -p category/port ]    : port specified with category
    [ -g partial-name ]     : match glob started with the specified name

Requires:
	grep, sed

Notes:
  Options/switches MUST be given each by itself, separated by spaces
  or tabs. They may NOT be combined (for example: "-rt", is invalid)

::
}; case "$1" in ""|-[?hH]|--help|[?]) showbanner; exit 0;; esac
printerr() { showbanner; echo -e "Error - $*\nProgram aborted.\n" 1>&2; exit 1; }
dumper() { echo " [ $@ ]" 1>&2; }


INDEX="${INDEX:-INDEX}"
PKGDEPS=""
unset RUNDEPS PRETTY XSCAN
DEPSFIELD=7
Checkfor="Build"

for arg; do
  case "$arg" in
    -b) unset RUNDEPS; Checkfor="Build"; shift;;
    -i) INDEX="$2"; shift 2;;
    -l) unset PRETTY; shift;;
    -r) RUNDEPS=1; Checkfor="Run-time"; shift;;
    -s) unset XSCAN; shift;;
    -t) PRETTY=1; shift;;
    -x) XSCAN=1; shift;;
     *) break;;
  esac
done

test -r "$INDEX" || printerr "Invalid INDEX: \"$INDEX\""

# Variables used
FOUND_MSG=""
NOTFOUND_MSG="! not found"
X11SKIP_MSG="x11 port skipped"

## ALL of these chars below MUST NOT be used for package-name string
MARK="="	# package_name and dep_list token separator
CSEP=":"	# list separator
MISS="#"	# mark for missing package
X11="X" 	# mark for x11

leaves="$CSEP"
pklist="$CSEP"
pkgdeps=""

isleaves() { [ -z "$1" ] || [ -z "${leaves##*$CSEP$1$CSEP*}" ]; }
islisted() { [ -n "$1" ] && [ -z "${pklist##*$CSEP$1$CSEP*}" ]; }
isnotlisted() { [ -z "$1" ] || [ -n "${pklist##*$CSEP$1$CSEP*}" ]; }

# MD5s="`dd if=/dev/random count=1 2>/dev/null | md5`"
# TMPDIR="/tmp/${0##*/}"
# [ -d "$TMPDIR" ] || mkdir "$TMPDIR" 

dn="`date +%d`"
sn="`date +%s`"
#sn="$(($sn%0xfffff))" ## 12+ days
sn="${sn#????}" ## 11.5 days

expname="${0##*/}/${0##*/}-$(($dn*10/31))"
tempbase="${TMPDIR:-/tmp}/${expname}"

[ -d "$tempbase" ] || mkdir -pm 777 "$tempbase" 

tmpdir="`mktemp -dt "${expname}/$sn"`" || printerr can not create temp workarea

PKGDEPS="$tmpdir/pkgdeps"
PKINDEX="$tmpdir/pkindex"
echo -n "" > "$PKGDEPS"

# 1. NAME: accerciser-3.14.0_1|
# 2. CATEGORY: /usr/ports/accessibility/accerciser|
# 3. INSTALL: /usr/local|
# 4. SHORTDESC: Interactive Python accessibility explorer for GNOME|
# 5. DESCFILE: /usr/ports/accessibility/accerciser/pkg-descr|
# 6. MAINTAINER: gnome@FreeBSD.org|
# 7. GROUP: accessibility gnome|
# 8. BUILDDEPS: adwaita-icon-theme-3.22.0 argyllcms-1.9.2_1 at-spi2-atk-2.24.0 at-spi2-core-2.24.0
# 9. RUNDEPS: adwaita-icon-theme-3.22.0 argyllcms-1.9.2_1 at-spi2-atk-2.24.0 at-spi2-core-2.24.0 a
# 10. HOMEPAGE|
# 11. EXTDEPS1|
# 12. EXTDEPS2|
# awk 'BEGIN {FS="|"} {print ($1 "=" $2 ":" $7 "| " $8 " " )}' INDEX-10 > field8=dep-build
# awk 'BEGIN {FS="|"} {print ($1 "=" $2 ":" $7 "| " $9 " " )}' INDEX-10 > field9=dep-run

[ "$RUNDEPS" ] && fieldno=9 || fieldno=8
awk 'BEGIN {FS="|"} {print ($1 "=" $2 ":" $7 "| " $'$fieldno' " " )}' "$INDEX" > "$PKINDEX"

recursed() { #args [ child ] [ parent ]
  # echo "$LM$INDEN: chkr [ child: $1 ] [ parent: $2 ]" 

  [ "$2" ] || return
  islisted "$1" || return
  [ -n "${leaves##*$CSEP$1$CSEP*}" ] || return # is-not-leaf?
  local items="`grep -m1 "^$1$MARK" "$PKGDEPS" 2>/dev/null`" || return
  [ -n "$items" ] && items=" ${items#*$MARK} " || return
  if [ -z "${items##* $2 *}" ]; then
    return
  else 
    [ -n "$items" ] || return
    local k
    for k in $items; 
      { recursed "$k" "$2" && return; }
  fi
}

get_deplist() { #arg: [ pkgname ]
# $ASSERT dumper "--getdeplist $@"
  isleaves "$1" && return 1
  if islisted "$1"; then
    deplist=`grep -m1 "^$1$MARK" "$PKGDEPS" 2>/dev/null`
    [ "$deplist" ] && deplist="${deplist#*$MARK}"
  else
    local line=`grep -m1 "^$1|" "$INDEX" 2>/dev/null`
    deplist="$MISS" cuts=7
    if [ -n "$line" ]; then
      ## x11-skipper ------------
      local fx="${line#*|}"
      # echo -n " [fx = ${fx%%|*}]"
      # fx="${fx%%|*}"
      if [ -z "$XSCAN" ]; then
        if [ -z "${fx%%/usr/ports/x11*}" ]; then
          echo -n " - $X11SKIP_MSG"
          echo "$1$MARK$deplist" >> "$PKGDEPS"
          return 1
          pklist="$pklist$1$CSEP"
          echo  "$pklist" >> "$tmpdir/debug_pklist"
          echo "$1$MARK$deplist" >> "$PKGDEPS"
          return 1
        fi
      fi
      #--------------------------
      [ "$RUNDEPS" ] && cuts=8
      deplists=`echo "$line" | sed "s/^\([^|]*|\)\{$cuts\}//"`
      [ "$deplist" ] && deplist="${deplists%%|*}"
    fi
    if [ -n "$deplist" ]; then
      pklist="$pklist$1$CSEP"
      echo  "$pklist" >> "$tmpdir/debug_pklist"
      echo "$1$MARK$deplist" >> "$PKGDEPS"
    else
      leaves="$leaves$1$CSEP"
      echo  "$leaves" >> "$tmpdir/debug_leaves"
    fi
  fi
}

if [ "$PRETTY" ]; then 
  INDEN=" |--"
  INEND=" \--"
  INDER="****"
  LEFT_MARGIN=" |  ";
else 
  INDEN="- "
  INEND="- "
  INDER="****"
  LEFT_MARGIN="  "
fi

CR="
"

LEMAR1="$LEFT_MARGIN"
LEMAR2="$LEMAR1$LEMAR1"
LEMAR4="$LEMAR2$LEMAR2"
LEMAR8="$LEMAR4$LEMAR4"
LEMAR16="$LEMAR8$LEMAR8"
LEMAR32="$LEMAR16$LEMAR16"
LEMAR64="$LEMAR32$LEMAR32"
LEMAR128="$LEMAR64$LEMAR64"

makeLEFTMARGIN() { #arg: [ count ]
  [ $(($1 + 0)) -gt 0 ] || return
  local result=""
  [ $(($1 & 1)) -gt 0 ] && result="$LEMAR1"
  [ $(($1 & 2)) -gt 0 ] && result="$result$LEMAR2"
  [ $(($1 & 4)) -gt 0 ] && result="$result$LEMAR4"
  [ $(($1 & 8)) -gt 0 ] && result="$result$LEMAR8"
  [ $(($1 & 16)) -gt 0 ] && result="$result$LEMAR16"
  [ $(($1 & 32)) -gt 0 ] && result="$result$LEMAR32"
  [ $(($1 & 64)) -gt 0 ] && result="$result$LEMAR64"
  [ $(($1 & 128)) -gt 0 ] && result="$result$LEMAR128"
  echo -n "$result"
}

#OK# for dynamic spacing, but consequently, also slower#
# makebar() { #args: [ string ] [ count ]
#   [ "$2" ] || return
#   local result="" bar="$1$1"
#   [ $(($2 & 1)) -gt 0  ] && result="$1"
#   [ $(($2 & 2)) -gt 0  ] && result="$result$bar"
#   bar="$bar$bar"; [ $(($2 & 4)) -gt 0  ] && result="$result$bar"
#   bar="$bar$bar"; [ $(($2 & 8)) -gt 0  ] && result="$result$bar"
#   bar="$bar$bar"; [ $(($2 & 16)) -gt 0  ] && result="$result$bar"
#   bar="$bar$bar"; [ $(($2 & 32)) -gt 0  ] && result="$result$bar"
#   bar="$bar$bar"; [ $(($2 & 64)) -gt 0  ] && result="$result$bar"
#   bar="$bar$bar"; [ $(($2 & 128)) -gt 0  ] && result="$result$bar"
#   echo -n "$result"
# }

MAXLINES=96000	# to prevent recursive dependencies

countargs() { echo -n $#; }

petok() { # args: [ package ] [ level ]
# $ASSERT dumper "--petok $@"
[ $DEBUG ] && set -xv
  unset LM;
  local r="$2";
  Ctr="$((Ctr+1))"
  [ $Ctr -lt $MAXLINES ] || {
    LM=`makeLEFTMARGIN $(($r))`
    echo "$LM${INDER}ERROR too many lines (recursive dependency), stack: $1"
    return
  }
  if [ -z "$r" ]; then
    echo
    [ -n "$1" ] && fn="package: $1"
  else
    LM=`makeLEFTMARGIN $(($r-1))`
    # LM=`makebar "$LEFT_MARGIN" $(($r-1))`
    #  rn=1
    #  while [ "$rn" -lt "$r" ]; do
    #    LM="$LM$LEFT_MARGIN";
    #    rn=$(($rn+1))
    #  done
    #OK# fn="$LM -$1"
    if [ $(($3 + 0)) -gt 0 ]; then
      fn="$LM$INDEN$1"
    else
      fn="$LM$INEND$1" 
      [ "$PRETTY" ] && fn="$fn$CR$LM"
    fi
  fi
  echo -n "$fn"
  # deps="`fetchpack $1`"
  local deplist=""
  [ "$1" ] && get_deplist "$1" || { echo; return; }

  if [ "$deplist" = "$MISS" ]; then
    echo "$NOTFOUND_MSG"
    # return 1
  else if [ "$deplist" = "$X11" ]; then
    echo "$X11SKIP_MSG"
    # return 1
    else
      # [ "$deplist" ] || echo -n "$FOUND_MSG"
      echo
      local p k=`countargs $deplist`
      for p in $deplist; do
	# ## too heavy
	# if recursed "$p" "$1"; then
	#   echo "${LM} - ERROR: recursive: $1 is child of $p"
	#   return
	# else
	#   petok "$p" $(($r+1)) $((k-=1));
	# fi
	petok "$p" $(($r+1)) $((k-=1)); # is this portable?
      done
    fi
  fi
}

# echo;
# echo "[ INDEX=\"$INDEX\" ]"
# echo "[ Using tmpdir: $tmpdir/ ]"

echo;
echo "[ Checking for $Checkfor dependencies ]"

while [ $# -gt 0 ]; do
  # set -xv
  pkgs=""
  if [ "$1" = "-p" ]; then
    shift;
    port="${1#/usr/ports/}";
    [ -n "$port" -a -z "${port##[a-z0-9]*}" ] && \
      pkgs=`grep "|/usr/ports/[^/]*/$port|" "$INDEX" | sed "s/|.*$//g"`
  else
    if [ "$1" = "-g" ]; then
      shift;
      [ -n "$1" -a -z "${1##[a-z0-9]*}" ] && \
        pkgs=`grep "^$1[^|]*|" "$INDEX" | sed "s/|.*$//g"`
    # else pkgs="$1"
    fi
  fi
  [ "$pkgs" ] || pkgs="$1"
  shift
#  break
  for pkg in `echo $pkgs`; do
    Ctr=0
    petok "$pkg" ""
  done
done

echo "$leaves" > "$tmpdir/debug_last_leaves"
echo "$pklist" > "$tmpdir/debug_last_pklist"

echo;
echo "[ Done checking for $Checkfor dependencies ]"
echo "[ Using tmpdir: $tmpdir/ ]"
# rm -R "$tmpdir"
