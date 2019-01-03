#!/bin/sh

test "$1" || { echo nothing happen; exit 1; }

bar="============================"
bar2="----------------------------"
unset err; log="/tmp/zz-${0##*/}.log"

alias today='date -j "+%Y.%m.%d %H:%M:%S"'
alias ticks='date -j +%s'

clock () {
  test -z "$1" -o -z "$1" && \
    { echo "missing arguments"; return 1; }
  local ts="$(($2-$1))"
  test "$ts" -lt 0 && \
    { echo limitless; return 2; }
  case "$ts" in
    0) echo unchanged;;
    1) echo a second\!;;
    60) echo a minute;;
    3600) echo an hour;;
    86400) echo a day;;
    *)	local tics="$ts seconds"
	if test "$ts" -le 60; then echo "$tics"
	  else echo "`date -j -r "$ts" "+%T"` ($tics)"
	fi;;
  esac
  return 0
}

makebar () {
  test "$2" || return 1
  local b="$1"; shift
  local n="${#@}"
  while test "$n" -gt 0; do
    n="$(($n-1))"; echo -n $b
  done
}


TIMER="START: `today`"
PROCS="PROCESS: \"$*\""
#echo "len PROCS=${#PROCS}, len bar=${#bar}"
test "${#PROCS}" -gt "${#bar}" && {
  bar=`makebar "=" "$PROCS"`
  bar2=`makebar "-" "$PROCS"`
}

echo -e "\n$bar\n$PROCS\n$TIMER\n$bar2" | tee -ai $log

tic="`ticks`"; $* || err=1; tac="`ticks`"

test "$err" && echo "*** ERROR ***" | tee -ai $log

echo; echo "RUNNING TIME: `clock "$tic" "$tac"`" | tee -ai $log

TIMER="FINISH: `today`"
echo -e "\n$bar2\n$TIMER\n$bar" | tee -ai $log
echo ""| tee -ai $log

