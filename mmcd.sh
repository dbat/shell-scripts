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
mount/unmount iso images
Version 1.0.0, 2008-11-01
using freebsd 5+ mdconfig (do not run under freebsd 4 and below)

Usage: [sh] ${0##*/} [ -m | -u ] [ iso-images or mountpoints.. ]

Where:
 -m	: mount
 -u	: unmount and detach/delete md-unit
 name	: either iso files or mountpoints dirs
	    could be with our without .iso extension

Notes	:
	mountpoints are automatically created or deleted
	based on iso-filename+md-unit

	one file.iso could be mounted several times

	upon unmounting file.isos (not dirs), all associated
	mountpoints and md-unit with those iso files, if any,
	will all be dropped

Examples
	${0##*/} -m *.iso ; mount all iso images in current dir
	${0##*/} -u *.iso ; unmount all iso images in current dir

ÿ
::
}; case "$1" in ""|-[?hH]|--help|[?]) showbanner; exit 0;; esac
printerr() { showbanner; echo -e "Error - $*\nProgram aborted.\n"; exit 1; }
showerr() { echo -e "\nError $?: $*\n"; }
case "$1" in -[um]) op="${1#-}";; *) printerr unknown argument $1;; esac

miso(){
  for r in $*; do
    iso="$r"; test -f "$r" || iso="${r%.iso}.iso" 
    test -s "$iso" || continue
    u=`mdconfig -n -a -t vnode -f "$iso"` || continue
    mp="${iso%.iso}.$u"
    test -d "$mp" || {
      mkdir -p "$mp" || { mdconfig -d -u $u; continue; }
    }
    mount -vt cd9660 -onoatime /dev/md$u $mp 
  done
}

umiso() {
  for r in $*; do
    test -d "$r" && mps="$r" || mps="${r%.iso}.[0-9]*"
    for d in $mps; do
      test -d "$d" && umount -v "$d" || continue
      u="${d##*.}"; mdconfig -d -u $u || continue
      test ! -e /dev/md$u && rmdir "$d"
    done
  done 
}

# shift; for arg in $*
#   { case "$op" in m) miso "$arg";; u) umiso "$arg";; *);; esac; }

shift; case "$op" in
  m) miso $*;;
  u) umiso $*;;
esac
