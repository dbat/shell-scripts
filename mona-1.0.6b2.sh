#!/bin/sh
ROOT=/tmp/mnt
showbanner(){
cat <<::
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
º	Copyright (C) 2003-2007, Adrian H. & Ray AF	º
º							º
º	     Private property of PT SoftIndo		º
º	   Jl. Bangka II No.1A, JAKARTA - 12720 	º
º							º
º		* All rights reserved *			º
ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Synopsys:
  mount/unmount any ufs and/or dos filesystems 

Changelog:
  version 1.0.4d, last update: 2008.11.5
    (small fix add freebsd release 8 & 9)
  version 1.0.5, last update: 2009.01.03
    (allow more than 1 filter, remaining args
     will be treated as filters. examples added)
  version 1.0.5a, last update: 2010.01.01
    (update: FreeBSD 8+ allows more slices, upto silce-z)
  version 1.0.6-beta, last update: 2017.08.01
    (update: gpt style slices)
  version 1.0.6c, last update: 2017.08.02
    (comments and restyle/unobfuscated)
    but still, we don't give up readibility for silly standard
    eg. not expanding switch with only one line command per-case

Usage:
  [sh] ${0##*/} mount_arg filesystem_arg filter_args...

Where:
  mount_arg is either mount (read-only, read-write) or unmount
    valid choices are: -m, -mr, -mw and -u
    - preceding dash (-) IS required

  valid choices for filesystem_arg are:
    u, ufs, f, fat, n, nt, ntfs, d, dos, and all
    - could be in any (upper/lower/mixed) case,
    - preceding dash is allowed but not required
    - if not supplied, default to UFS

  filter_args: simply substrings which must be part of mount

Examples:
  [sh] ${0##*/} -m -a
  mount all partitions, ufs and dos (fat/ntfs)

  [sh] ${0##*/} -u
  unmount ufs only (dos partition will NOT be unmounted)

  [sh] ${0##*/} -mw ufs ad4s2[a-e] ad8s?[a-e]
  mount read-write ufs disk4 slice 2 and disk8 (any slices)
  partition a to e (usually root, var and usr/local)

Notes:
  when filter_args is given, then the preceding 2 arguments
  (mount and filesystem) must also be supplied

  default mount (-m) is read-only
  root dir will be under $ROOT/BSD or $ROOT/DOS

::
#ROOT=""
#ROOT=/tmp/mounts
}

case "$1" in
  -[?hH]|--help|[?])
    showbanner;
    exit 0;
  ;;
esac

printerr() {
  showbanner;
  echo -e "Error - $*\nProgram aborted.\n";
  exit 1;
}

getmountedslices() {
local IFS='
'; for dev in `df -l`; do
    # ignore blank string, get only line starts with "/"
    # /usr might hasn't been mounted yet, can't do grep here
    test -n "$dev" -a ! "${dev%%/*}" && echo "${dev%% *}" "${dev##* }";
  done
}

getmountpoint() {
  test "$1" != "/" || { echo "/"; return 1; }
  test -n "$MOUNTPOINTS" || MOUNTPOINTS=`getmountedslices`
local IFS='
'; for pair in $MOUNTPOINTS; do
    if test -z "${pair##$1 *}"; then
      echo -n "${pair##* }";
      return 0;
    fi
  done
  return 1
}

getMSDOSFS() {
  REL=`sysctl -b kern.osrelease`
  case ${REL%%-*} in
    4.*|7.47*) echo msdos;;
    [5-9].*) echo msdosfs;;
    *) echo msdosfs;;
  esac
}

case "$1" in
  -a) unset mod; set -- "" -a;;
  -m|-mr) mod=ro,;;
  -mw) mod=rw,;;
  -u) unset mod;;
  "") unset mod; showbanner;;
   *) printerr unknown option $1;;
esac

enum_fs() {
  set -f
  local c1="[0-9]" c2="[0-9][0-9]" c3="[1-4][a-z]"
  local sc1="[sp]$c1" sc2="[sp]$c2" sc3="[sp]$c3"
  local FS="" r=""
  test "$UFS" = 1 && r="$r $c1$sc1 $c1$sc2 $c1$sc3 $c2$sc3"
  test "$NT4" = 1 -o "$FAT" = 1 && r="$r $c1$sc1 $c1$sc2 $c2$sc1 $c2$sc2"
  for n in $r; { FS="$FS /dev/ad$n /dev/ada$n /dev/da$n /dev/aac$n"; }
  set +f; echo $FS
}

getfilters() {
  test -n "$3" && shift 2 || return;
  echo -n "$@";
}

filters="`getfilters "$@"`"

#filter="$3";
#echo filters="$filters"

UFS=""; NT4=""; DOS=""; FAT="";
case "${2#-}" in
  [aA]|[aA][lL][lL])
    UFS=1; NT4=1; FAT=1;;
    # nodes="/dev/ad*[sp]*[0-9ad-z] /dev/da*[sp]*[0-9ad-z]";;
  [dD]|[dD][oO][sS]|[fF]|[fF][aA][tT]|[nN]|[nN][tT]|[nN][tT][fF][sS])
    # nodes="/dev/ad*[sp]*[0-9] /dev/da*[sp]*[0-9]";;
    case "${2#-}" in 
      [dD]|[dD][oO][sS]) NT4=1; FAT=1;;
      [fF]|[fF][aA][tT]) FAT=1;;
      [nN]|[nN][tT]|[nN][tT][fF][sS]) NT4=1;;
    esac;;
  ""|[uU]|[uU][fF][sS])
    UFS=1;;
    #nodes="/dev/ad*[sp][1-4][ad-z] /dev/da*[sp][1-4][ad-z]";;
  *)
    echo "unknown filesystem identifier: $2";
    echo "please specify: ufs, fat, ntfs, dos";
    exit 1;;
esac
nodes="`enum_fs`"

# Constants:
BSD=BSD
DOS=DOS

AA=999:999
OWNER="-uaa -gaa"
OWNER=""

opt_UFS="noatime -t ufs"
opt_DOS="noatime,noexec,nosuid,nodev"
opt_DOS="noatime,noexec,nosuid"		#FreeBSD7 no longer accepts nodev
opt_NT4="-m775 -t ntfs"	#could never be written anyway
			#limited (if any at all) write only for small system
opt_NT4="-m775"
opt_FAT="-m664,-M775 -t `getMSDOSFS`" 

MOUNTPOINTS=`getmountedslices`

for node in $nodes; do
  test -e "$node" || continue

  # filter = filter1 AND filter2 AND filter3...
  SKIP=""
  if [ "$filters" ]; then
    SKIP=1
    for f in $filters; do
      test -z "${node##*$f*}" && { SKIP=; break; }
    done
  fi

  [ "$SKIP" ] && continue; #noisy: { echo "skipped: $node"; continue; }
  
  test "$1" != -u && mountpt="`getmountpoint $node`" && {
    echo -n $node already mounted in: $mountpt\ ;
    test -w $mountpt && echo "(rw)" || echo "(ro)"
    test -z "";
    continue;
  }

  # splice="${node#/dev/}"	# = ad2s2a ad4p7
  # slice="$splice"
  # 
  # test -z "${splice##*s[0-9]*}" && slice="s${splice#*s}"	# s2a 
  # test -z "${splice##*p[0-9]*}" && slice="p${splice#*p}"	# p7
  # 
  # chunk="${node%$slice}"	# = /dev/ad2
  # dev="${chunk#/dev/}"		# = ad2
  # 
  # disk=""	#disk="$root/$dev"
  # mountpoint=""	#mountpoint="$disk/$dev$slice"

  part="${node#/dev/}"

  __setmountvars() {
    # got vars: disk, mountpoint
    test "$1" -a ! "$2" || printerr "invalid construct: [$@]"
    #echo disk=$disk part=$part mountpoint=$mountpoint
    case "$1" in
      UFS) test -z "${part%%*[1-4][ad-z]}" -o -z "${part%%*p[1-9]*}" || return 1
	root=$ROOT/$BSD; OPTS="$mod$opt_UFS";;
      DOS|FAT|NT4) test -z "${part%%*[0-9]}" -o -z "${part%%*p[1-9]*}" || return 1
	root=$ROOT/$DOS; OPTS="$mod$opt_DOS"
	test $1 = FAT && OPTS="$OPTS,$opt_FAT" || OPTS="$OPTS $opt_NT4"
        OPTS="$OPTS $OWNER";;
      *) printerr unknown filesystem: $*;;
    esac

    devid="${part%%[0-9]*}";	# device name:  [ad]0s2a, [ada]11p7
    _part_="${part#$devid}";	# partname without devname: ad[0s2a], ada[11p7]
    devno="${_part_%%[a-z]*}"	# device no (number only): ad[0]s2a, ada[11]p7
    dev="$devid$devno"; 	# device: [ad0]s2a, [ada11]p7

    # disk=$root/$dev		# /mnt/UFS/ad2
    # mountpoint=$disk/$dev$slice	# /mnt/UFS/ad2/ad2s2a
    # echo now disk=$disk slice=$slice mountpoint=$mountpoint

    disk=$root/$dev		# /mnt/UFS/ad2
    mountpoint=$disk/$part	# /mnt/UFS/ad2/ad2s2a
  }

  __delifempty() { test -d "$1" -a "$1/*" = "`echo $1/*`" && rm -R "$1"; }
  __delife_all() { __delifempty $mountpoint; __delifempty $disk; }
  __mountcheck() { __setmountvars $1 && echo "  $1: $node will be mounted on $mountpoint"; }
 
  # updated for freebsd7's minor bug:
  # does not return error on failed mount_ntfs
  __mount() {
    __setmountvars $1 || return
    [ "$1" = "NT4" ] && FBSD7_BUG=_ntfs || unset FBSD7_BUG
    test -d $mountpoint || {
      mkdir -p $mountpoint && \
        chown $AA $mountpoint || \
        printerr $mountpoint creation failed;
    }
    (mount$FBSD7_BUG -o $OPTS $node $mountpoint > /dev/null 2>&1) && \
      echo "mounted $1 in $mountpoint (${mod%,})" && return
    __delife_all;
    return 1 # must be returning fail
  }
  __unmount() {
     __setmountvars $1 || return
    test -d $mountpoint && umount $mountpoint && \
      echo "  unmounted $1: $node on $mountpoint"
    __delife_all
  }

  case "$1" in
    -m|-m[wr]) 
      test "$UFS" = 1 && __mount UFS && continue
      test "$NT4" = 1 && __mount NT4 && continue
      test "$FAT" = 1 && __mount FAT && continue
      #echo "*** failed to mount $node";;
      ;;
    -u)
      test "$UFS" = 1 && __unmount UFS
      test "$FAT" = 1 -o "$NT4" = 1 && __unmount DOS
      #echo "*** failed to unmount $node";;
      ;;
    "")
      test "$UFS" = 1 && __mountcheck UFS && continue
      test "$FAT" = 1 -o "$NT4" = 1 && __mountcheck DOS  && continue
      #echo "*** invalid $node";;
      ;;
  esac

done

#test "$1" || { echo; showbanner; }
