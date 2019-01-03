#!/bin/sh
DEFR="/tmp/ISO"
showbanner(){
cat <<::
==================================================
    Copyright (C) 2003-2007, Adrian H. & Ray AF

         Private property of PT SoftIndo
       Jl. Bangka II No.1A, JAKARTA - 12720

            * All rights reserved *
==================================================

Program: cdimage; Initial release: 2009.01.12
Version: 1.1.0; Last update: 2009.10.23

Synopsys:
  mount cd image

Usage:
  [sh] ${0##*/} [filename][.iso] [mount-point]
  or
  [sh] ${0##*/} [-u] [device_number]

  the second syntax only applied to default mount
  (under "$DEFR-n", where n = device_number)

Notice:
  if no argument specified, then the first .iso found
  will be mounted under "$DEFR-0"

to unmount/remove:
  umount	_mountpoint_
  mdconfig -du	_mdnumber_
  rmdir 	_mountpoint_

::
}; helpme() { showbanner; exit; }
case "$1" in -[?hH]|--help|[?]) helpme;; esac
printerr() { showbanner; echo -e "Error - $*\nProgram aborted.\n"; exit 1; }

isnums () { test "$1" && test "${1##*[!0-9]*}"; }

if test "$1" = "-u" -o "$1" = "-r" -o "$1" = "-d"; then
  if isnums "$2"; then
    umount -v "$DEFR-$2" && mdconfig -d -u $2 && {
      test "`echo "$DEFR-$2"/*`" = "$DEFR-$2/*" && \
        rmdir "$DEFR-$2" && echo "$DEFR-$2 removed"
    }
    return
  fi
fi


ISO="${1:-`echo *.[Ii][Ss][Oo]`}"
ISO="${ISO%% *}"
test -e "$ISO" || ISO="`echo $ISO.[iI][Ss][Oo]`"
test -r "$ISO" -a -s "$ISO" || helpme

#
# echo "=Note:================================="
# echo "for FreeBSD RELEASE 4.11 and below:"
# echo "to mount:"
# echo "  vnconfig -s labels -c /dev/rvn0 $ISO"
# echo "  mount -t /dev/vn0c cd9660 $mountpoint"
# echo
# echo "to unmount:"
# echo "  umount /dev/vn0c"
# echo "  vnconfig -u /dev/vn0c"
# echo "======================================="
#

mountpoint="${2:-$DEFR}";	#-${dev#md}}"
if test -z "$1"; then
  read -p "mount $ISO under $mountpoint? [Y]" ans
  case "$ans" in ""|[Yy]);; *) helpme;; esac
fi

REL="`sysctl -b kern.osrelease`" && REL="${REL%%.*}" || \
  { echo unknown FreeBSD release; exit 1; }

dev="`mdconfig -a -t vnode -f "$ISO"`" || \
  { echo can not create md device; exit 1; }

mountpoint="$mountpoint-${dev#md}"
echo
test -d "$mountpoint" || mkdir "$mountpoint"
test -d "$mountpoint" || { echo can not create $mountpoint; exit; }
if mount -t cd9660 /dev/$dev "$mountpoint"; then
  #getRandomMD5() { dd if=/dev/random count=1 2>/dev/null | md5 -q; } #example
  tmpmsg="/tmp/${0##*/}.${dev#md}.msg"
  cat <<- EOF > "$tmpmsg"
	Operation succeed. Found *BSD release: $REL+
	CD image: $ISO, mounted in: "$mountpoint"

	to unmount/remove it later, type:
	  [sh] ${0##*/} -u ${dev#md}

	to manually remove it use these commands:
	  umount "$mountpoint"
	  mdconfig -d -u ${dev#md}
	  rmdir "$mountpoint"

	(this message is saved to log-file: "$tmpmsg")
	EOF
  cat "$tmpmsg"
else
  echo can not mount CD image at "mountpoint: $mountpoint"
fi
echo
