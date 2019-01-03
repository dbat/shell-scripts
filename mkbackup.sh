#!/bin/sh
CPR=`cat <<"##"
#===========================================
# FreeBSD 5/6 backup builder:  root usr var
# ------------------------------------------
# Copyright 2002-2006, aa & Inge DR.
# Private property of PT SOFTINDO, Jakarta
#===========================================

usage: $0 [ -b ] [ -go ]
  -b  : use bzip2/tbz instead gzip/tgz
  -go : unatended, assume yes for all queries

   whenever asked to proceed, "g" means: GO
   (yes to all) and "q" means: QUIT instantly
   anything else means skip

##
`
echo -e "$CPR"
echo

unset QUIT
[ "$1" = "-go" -o "$2" = "-go" ] && GO=1 || unset GO
if test "$1" = "-b" -o "$2" = "-b"; then
  zopt=cpjf; zext=tar.bz
else
  zopt=cpzf; zext=tar.gz
fi

asktoproceed() {
  local ans result="$GO"
  echo; echo -n "Packing $1 "; shift
  if [ ! "$GO" ]; then
    read -p"do you want to proceed [N]?" ans
    case $ans in
      [yY]) result=1;;
      [gG]) GO=1; result=1;;
      [xXqQ]) QUIT=1;;
      *);;
    esac
    else echo;
  fi
  test "$result" && for n in $*;{ echo " -> $n"; }
}

timetar() {
  if asktoproceed $1; then
    TGZ="$REL-${1%%:*}.$zext"
    [ "$2" ] && shift || return 1
    time tar -$zopt "$TGZ" --exclude "*history" --exclude "*/wiki*/*" $* 
    chown 999:999 "$TGZ"
  else [ "$QUIT" ] && exit 1
  fi
  echo -e "\tDone archiving $TGZ."
}

REL="`sysctl -b kern.osrelease`"
REL="${REL%%-*}"
echo
echo got kernel version: $REL
echo backup extension: .$zext

dotfiles="/profile /.profile /.cshrc /.info /.mc /.bashrc"
dotfiles=
for dot in profile .profile .cshrc .info .mc .bashrc; do
  test -f /$dot && dotfiles=`echo -e $dotfiles /$dot`
done

KERNEL="$dotfiles /boot /kernel* /modules* /AA /inge /dev\
  /bin /sbin /etc /lib /libexec\
  /rescue /stand /base/aa/CPR /var/run/*.hints /var/var-000.tar\
  /var/db/*sql /var/db/*z /var/www\
  /var/tmp/vi.recover/dummy\
  /tmp/mc-root/dummy /.usr/dummy\
"

# expand and validate glob
validatex() { for f in $*; { [ -e "$f" ] && echo -n "$f "; }; }

timetar kernel: `validatex $KERNEL`

#basedir provided only to prevent recursive mistake
basedirs="/boot /var /usr /bin /lib /libexec /etc"
rootdirs=`validatex /root`

for D in $basedirs $rootdirs; do
  test "${PWD%%$D*}" || {
    echo "error! this tool must not be run under root or base dirs:"
    echo $basedirs $rootdirs
    return 1
  }
done

list=/tmp/list-$$.tmp
test -e $list && rm -Rf $list
test -e $list && return 1

for file in $dotfiles; do echo $file >> $list; done
find -x $rootdirs \( -type f -or -type l \) -not -regex "/root/user/.*" >> $list

timetar root: $dotfiles $rootdirs

rm $list

[ -d /etc -o -d /usr/local ] && timetar etc: /etc /usr/local/etc /user/local/etc
[ -d /user -o -d /root/user ] && timetar root+user: $dotfiles $rootdirs /user 

setexcludes(){
  local b=$1; shift
  while test -n "$1"; do echo -n "--exclude /$b/$1 "; shift; done
}

for bulk in var usr; do
  excludes=
  case $bulk in
    var) excludes=`setexcludes $bulk run tmp mnt mount mounts`;;
    usr) test -f /usr/src -o -L /usr/src || excludes=--exclude /usr/src;;
  esac
  timetar $bulk: $excludes /$bulk
done

echo; echo All done.
read ans; return 0

