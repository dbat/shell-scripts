#!/bin/sh
#change these accordingly
logname=pflog
location=/var/log
#location=/var/tmp/var/log/pf

case "$1" in -[?hH]|--help|[?]) cat <<-::
#
# ========================================
# Copyright 2004-2007, Adrian H & Ray AF
# Private property of PT SoftINDO, Jakarta
# All rights reserved
# ========================================
#
# Combine pflog dump, under assumptions:
#  - log file is: $logname*
#  - location is under directory: $location
#  - rotating logs should be in a timely manner
#    (could be packed by either gzip or bzip)
#
# Usage: [sh] $0 [ouputname]
#    if not specified, outputname will be: ${logname}_all
#
# Requires:
#  - dd
#  - gzcat/bzcat
#  - ls capable to sort by reversed time
#
# Notes::
#  - OpenBSD pflog dump format header (24 bytes):
#    D4 C3 B2 A1 02 00 04 00 - 00 00 00 00 00 00 00 00
#    74 00 00 00 75 00 00 00
#
#  - This script actually simply concatenate
#    all pflog files (sorted by time), with their
#    24-bytes tcpdump-header stripped - except for
#    the first file (the oldest).
#
#--------------------------------------------------
# BIGDUMP: tcpdump -XX -S -tttt -vv -enr pflog_all 
#--------------------------------------------------
#
::
exit 0;; esac

LS="/bin/ls -rU"	#sorted by time, reversed (oldesr first)

OUT="${1:-$location/${logname}_all}"
list=`$LS $location/$logname*` || exit 1

test -e $OUT && { rm $OUT || { echo error $OUT already exists; exit 1; } }

unset n
for f in $list; do
  test -f "$f" || continue
  case ${f##*.} in
    [Bb][Zz]|[Bb][Zz]2) CAT=bzcat;;
    [Gg][Zz]|[Gg][Zz][Ii][Pp]|[Zz]) CAT=bzcat;;
    *) CAT=cat;;
  esac
  echo; echo processing file $f... using $CAT
  #first log must not be modified
  test "$n" || { n=1; $CAT $f > $OUT; continue; }
  #crop header on next subsequent logs
  $CAT $f | dd ibs=24 skip=1 >>$OUT
done

echo; echo Done. Output file in $OUT

