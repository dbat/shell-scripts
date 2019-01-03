#!/bin/sh
#
# Package get dependencies (recursively)
# version 1.0.2a (default to .tbz)
#
# Copyright 2006, aa & Inge DR.
# PT Softindo, JAKARTA
#
# prequisities: sh, tar, gzip/bzip, sed
# (no, virginia, we do not need perl "Operating System")
#
# known limitations:
#   no cache, slow.
#   not using /var/db/pkg for already installed packages
#

#REL <= 4  
ext=.tgz; opz=z

#REL >= 5
ext=.tbz; opz=j

petok() {

  local r=$2
  unset lm
  if test -z "$r"; then [ -n "$1" ] && fn="package: $1"
  else
    rn=1
    while [ "$rn" -lt "$r" ]; do 
      lm="$lm  "
      rn=$(($rn+1))
    done
    fn="$lm -$1"
  fi

  pkg=${1%$ext}$ext

  if test -s "$pkg"; then
    echo -n "$fn"
    dep=`tar -$opz -Oxf $pkg \+CONTENTS | grep @pkgdep | sed s/"^.* "//g`
    [ -z "$dep" ] && echo -n "#" # (leaf package, independent)
    echo ""
    for P in $dep; do 
      [ "$r" ] || echo
      [ -n "$P" ] && petok $P $(($r+1))
    done
  else
    #echo "$fn!" # (not found)
    echo "$fn! not found"
  fi

}

while [ -z "${1%%-*}" ]; do
  case "$1" in
    -[zg]) { ext=.tgz; opz=z; };;
    ""|-[h?]|--help) shift $#;;
    *) echo "unknown argument: \"$1\" (ignored)";;
  esac
  [ -n "$1" ] && shift
  [ -z "$1" ] && break
done

if test -n "$1"; then
  echo  -e "\nrequests: $*"
  echo  "ext=$ext;opz=$opz"
  echo
  pwd=`pwd`
  for f in $*; do
    #simple sanity check
    [ "${f%%-*}" ] || {
      echo -e "\nunknown argument: \"$f\" (skipped)";
      continue; 
    }
    dirname=${f%/*}
    basename=${f##*/}
    [ "$dirname" ] && cd $dirname 2>/dev/null
    echo
    petok $basename
    cd "$pwd"
  done
else
  echo -e "\nPackage dependencies enumerator\n"
  echo -e "Usage: $0 [-z] [ tarball ]\n"
  echo "Arguments"
  echo "  -z     : FreeBSD REL <= 4 gzipped tarball (.tgz)"
  echo "  tarball: That things under \"All\" directory"
  echo
  echo "Result indicators"
  echo "  *      : leaf package (no more dependencies)"
  echo "  !      : not found / error"
  echo
fi
echo

