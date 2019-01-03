#!/bin/sh

DEF_BITS=6
DEF_DEPTH=2
EXAMPLE_OWNER=80
EXAMPLE_MODE=700
DEF_MAXDIR=256000
MKDX_MAXDIR="${MKDX_MAXDIR:-$DEF_MAXDIR}"
MIN_BITS=1
MAX_BITS=8
showbanner(){
DEF_BITS_1=$(($DEF_BITS-1))
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
Version: 1.4.2f
Created: 2008.09.10
Updated: 2016.08.03

Synopsys:
  Create recursive sub level dirs according to given level/bitmask

Usage:
  [sh] ${0##*/} [ -q ] basedir [ depth=$DEF_DEPTH ] [ bits=$DEF_BITS ] [ mode ] [ owner ]

  where
    -q      : Quiet, pass default on invalid. has to be the first argument.
    basedir : REQUIRED. base directory to put in, will be created if it
              does not yet exist. simply set it to . (DOT) for current dir.
              Special basedir: /dev/null is allowed for testing purpose.

    depth   : Depth level, default = $DEF_DEPTH
    bits    : 1 - 8 charset bitmask, default = $DEF_BITS ($((2<<$DEF_BITS_1)) chars represented).
              Maximum functional bitmask is 6, as used by PHP session.
              Note: if specifying more than 6-bit, you have to supply
                    your own custom directory name set.

    mode    : UNIX file mode, access permission bits. Should be user-
              executable and writeable (unless this script is run by root)
              Caution: Existing directories, if any, wouldn't be changed.
    owner   : Change owner, can only be done by root.

Requirements:
  POSIX shell sh with arithmetic expansions
  chmod/chown, if argument mode/owner used, respectively

Environment variables (only set if necessary):
  MKDX_MAXDIR: Maximum directories allowed to be created
  MKDX_DIRSET: Custom directory name set, default to 0..9,A..Z,COMMA,DASH
               might be desirable if you set bitmask more than 6.
               If they are less than bitmask representation, then
               the default values ([-0-9,A-Z,]) will be appended.
         note: Custom directory name set is NOT restricted to 1 char/dirname,
               nor this script will prevent for duplication, if any.
Examples:
  - Create 2-level depth, 6-bit subdirs placeholder for PHP session
      #root> sudo -u www ${0##*/} /tmp/.Ss
      #root> su -m www -c "${0##*/} /tmp/.Ss 2 6 700"

    then edit php.ini to contain: session.save_path='2;/tmp/.Ss'

  - Create 3-level depth, 5-bit subdirs, and set public mode rw
      \$user> ${0##*/} /tmp/.Ss  3  5  777

  - Benchmark filesystem. Override maximum value and create 1 million dirs
      time MKDX_MAXDIR=2000000 ${0##*/} -q /tmp/x 4 5; time rm -Rf /tmp/x;

  - Supply your own custom directory name set
    (for 4 bits = 2^4 = 16 names needed)
      MKDX_DIRSET="1 2 3 4 5 6 7 8 9 11 12 13 14 15 16"  ${0##*/} /tmp/hex 3 4
    (for 3 bits = 2^3 = 8 names needed)
      MKDX_DIRSET="this is my super cool dir name set"  ${0##*/} ~/dumb 5 3

  - Just checking out how many dirs will be created by 8-level depth, 7-bit
      ${0##*/} /dev/null 8 7  (Result = 72624976668147840)

::
}; case "$1" in -[?hH]|--help|[?]|"") showbanner; exit 1;; esac

printerr() {
  echo "${0##*/} ERROR: $*"
  echo "Program aborted.";
  exit 2;
}

isnums() { test "$1" && test "${1##*[!0-9]*}"; }

test "$1" = "-q" && { SILENT=1; shift; } || SILENT=

test -z "$SILENT" && \
if isnums "$1"; then
  if [ ! -d "$1" -a -z "$3" ]; then
    echo "you have specified basedir as numeric: $1"
    read -p "are you sure want to do this ?[n]" ans
    test [ "$ans" = "y" -o "$ans" = "Y" ] || printerr Invalid arguments: $*
  fi
fi

DEPTH="${2:-$DEF_DEPTH}"
[ -n "$1" ] && isnums "$DEPTH" || {
  test -z "$SILENT" && \
    printerr "Invalid depth: $2" || \
    DEPTH="$DEF_DEPTH"
}

sum_r() {
  # count total inodes/dirs must be created
  # (used for php session)
  #
  # 4-bit: [0-9a-f]
  # 0  L1  L2  L3   L4  L5  L6    N
  # 1  16  -   -    -   -   -     16
  # 2  16  256 -    -   -   -     272
  # 3  16  256 4K   -   -   -     4,368
  # 4  16  256 4K   64K -   -     69,904 *)
  # 5  16  256 4K   64K 1M  -     1,118,480
  # 6  16  256 4K   64K 1M  16M   17,895,696
  #
  # 5-bit: [0-9a-v]
  # 1  32  -   -    -   -   -     32
  # 2  32  1K  -    -   -   -     1,056
  # 3  32  1K  32K  -   -   -     33,824 *)
  # 4  32  1K  32K  1M  -   -     1,082,400
  # 5  32  1K  32K  1M  32M -     34,636,832
  # 6  32  1K  32K  1M  32M 1G    1,108,378,656
  #
  # 6-bit: [0-9a-zA-Z.,]
  # 1  64  -   -    -   -   -     64
  # 2  64  4K  -    -   -   -     4,160 *)
  # 3  64  4K  256K -   -   -     266,304
  # 4  64  4K  256K 16M -   -     17,043,520
  # 5  64  4K  256K 16M 1G  -     1,090,785,344
  # 6  64  4K  256K 16M 1G  64G   69,810,262,080
  #
  # *) max. reasonable value for respective bitmask

  isnums "$1" && isnums "$2" || return
  [ "$(($1*$2))" -lt 63 ] || return
  local i=1 result=1 base=1 bits=$1 depth=$2

  # sh has no power
  while [ $i -le $bits ]; do
    i=$(($i+1))
    base=$(($base+$base))
  done

  i=0; bits=$base
  while [ $i -lt $depth ]; do
    result=$(($result+$base))
    base=$(($base*$bits))
    i=$(($i+1))
  done
  echo $(($result -1))
}

BITS="${3:-$DEF_BITS}"

CDIR="\
 0 1 2 3 4 5 6 7 8 9 a b c d e f\
 g h i j k l m n o p q r s t u v\
 w x y z A B C D E F G H I J K L\
 M N O P Q R S T U V W X Y Z"

# Private use only, set WITHOUT_PUNCT=1 if your php session doesn't use them
# (My php built doesn't include COMMA and DASH to simplify checking (ie. any
# session which contains those characters in it is simply a bogus session)
test "$WITHOUT_PUNCT" = 1 || CDIR="$CDIR , -"

# next 6-bit directory characters should you need them
# CDIR2=""
# octal="0 1 2 3 4 5 6 7"
# for i in $octal; do for j in $octal; do CIDR2="$CIDR2 `printf "\2$i$j"`"; done; done;
#
# append to CIDR to make 7-bit placeholder for dirnames
# CIDR="$CIDR $CIDR2"

mkCDIR() {
  isnums "$1" && n="$1" || {
    test -z "$SILENT" && \
      printerr "Invalid bitmask. argument must be numeric" || \
      n="$DEF_BITS"
  }
  test "$n" -ge "$MIN_BITS" || n="$MIN_BITS"
  test "$n" -le "$MAX_BITS" || n="$MAX_BITS"
  n=$(($n - 1))
  n=$((2 << $n))  
  set -- $MKDX_DIRSET $CDIR $CDIR $CDIR $CDIR
  CDIR="$1"
  while test "$n" -gt 1; do
    shift 
    CDIR="$CDIR $1"
    n=$(($n - 1))
  done
}

mkCDIR "$BITS"

# case "$BITS" in
#   2) CDIR="${CDIR%5*}";;
#   3) CDIR="${CDIR%9*}";;
#   4) CDIR="${CDIR%g*}";;
#   5) CDIR="${CDIR%w*}";;
#   6);; *) printerr invalid bitmask: $3;;
# esac

[ "$1" = /dev/null ] && MKDX_MAXDIR=$((0x7fffffffffffffff))

isnums "$MKDX_MAXDIR" || MKDX_MAXDIR=$DEF_MAXDIR

SUMDIR=`sum_r $BITS $DEPTH`
[ $? -eq 0 ] || printerr "\n(2 power $(($BITS*$DEPTH))) is too much for me"
[ $SUMDIR -le $MKDX_MAXDIR ] || printerr "
  request to create $SUMDIR inodes has been rejected,
  MKDX_MAXDIR=$MKDX_MAXDIR. Set/increase this environment variable to override
"

# allow /dev/null for testing
if [ "$1" = "/dev/null" ]; then
  echo "$DEPTH-level/$BITS-bit of total $SUMDIR directories will be created"
  return
fi

# OR mode with 0300 (u+wx)
# [ -n "$4" ] && CHMOD="-m `printf %o $((0$4 | 0300))`" || unset CHMOD
# [ -n "$CHMOD" ] && FFMOD="${CHMOD##* }" || unset FFMOD

[ -n "$4" ] && CHMOD="-m $4" || unset CHMOD

# if [ "$5" ]; then unset CHUSR
#   [ "`id -u`" = "0" ] && CHUSR=`id -un $5` || \
#   echo "Can not change owner to: $5"
# fi

dig_in_ex() {
  test $2 -lt $(($DEPTH-1)) && local spc="$spc$3"
  test -z "$SILENT" && \
  echo "$spc"depth $(($DEPTH-$2)): $1 dirs: $CDIR
  cd -P "$1" || return #printerr broken in $*
  # mkdir $CHMOD $CDIR 2> /dev/null #|| return
  if [ "$CHUSR" ]; then
    #su -m $CHUSR -c "mkdir -p $CDIR" #|| return
    su -m $CHUSR -c "mkdir -p $CHMOD $CDIR" 2>/dev/null
  else
    #mkdir -p $CDIR #|| return
    mkdir -p $CHMOD $CDIR 2>/dev/null
  fi
  if [ $2 -gt 1 ]; then
    for i in $CDIR; do
      test -d "$1/$i" && \
        dig_in "$1/$i" $(($2-1)) "  "
    done
  fi
  return 0
}

dig_in() {
  test $2 -lt $(($DEPTH-1)) && local spc="$spc$3"
  [ "$SILENT" ] || echo "$spc"depth $(($DEPTH-$2)): $1 dirs: $CDIR
  cd -P "$1" || return #printerr broken in $*
  mkdir $CHMOD $CDIR 2>/dev/null
  if [ $2 -gt 1 ]; then
    for i in $CDIR; do
      #test -d "$1/$i" && \
        dig_in "$1/$i" $(($2-1)) "  "
    done
  fi
  #return 0
}

test -d "$1" || mkdir -p $CHMOD "$1" 
test -d "$1" || printerr "Can not create directory: $1"
test -w "$1" || printerr "Directory $1 is read-only"

# test "$CHMOD" && chmod "${CHMOD##* }" "$1"
# test "$CHUSR" && chown $CHUSR "$1"

# BASEDIR=`realpath "$1"`
BASEDIR="$1"

test "$DEPTH" -gt 0 && (trap return 2 3; dig_in $BASEDIR $DEPTH;)
if [ "$?" = "0" ]; then
cat <<- EOF > "$BASEDIR/CONFIG"
	PATH=$BASEDIR
	DEPTH=$DEPTH
	BITS=$BITS
EOF
else printerr "Failed on creating directories";
fi

# MODE="${4:-$DEF_MODE}"
# OWNER="${6:-$DEF_OWNER}"

# test -n "$4" && chmod -R "$4" "$BASEDIR"/*
if test -n "$5"; then
  chown -R "$5" "$BASEDIR" 2>/dev/null || \
    echo "${0##*/} WARNING: Can not change $BASEDIR to owner: $5"
fi
echo "${0##*/} INFO: $DEPTH-level/$BITS-bit of total $SUMDIR directories has been processed in $1"
