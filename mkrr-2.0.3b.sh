#!/bin/sh
# restore package dependencies (non-existent packages)
# from backup directory / repository
#
# usage
#     ${0%.sh} -go [ category/port.. ] [ port.. ]
#
# changelog:
# - Test whether Makefile exist (not only testing directory)

# Variables to be customized
USERPORTS="${USERPORTS:-/usr/ports}"
REPODIR="${REPODIR:-.repo}"
test -n "${REPODIR##/*}" && REPODIR="$USERPORTS/$REPODIR"
test -r /usr/bin/grep -o -r /bin/grep && HAVE_GREP=1 || unset HAVE_GREP

echo=echo
script="${0##*/}"

showMode() {
    test -n "$echo" && mode=TEST-ONLY/NONDESTRUCT || mode="DESTRUCT/APPLY"
    echo ""
    echo "  *** Execution mode: $mode"
    test -n "$echo" && \
    echo "  *** Use switch -y to apply change"
    exit
}

showHelp() {
    echo ""
    echo "  ---------------------------------------------"
    echo "  Restore ports from backup (repository) dir"
    echo "  ---------------------------------------------"
    echo "  Version: 2.0.3b"
    echo "  Created: 2016.08.19"
    echo "  Updated: 2016.09.17"
    echo ""
    echo "  Usage:"
    echo "      [ USERPORTS=path ] [ REPODIR=path ] \\"
    echo "      ${script%.sh} [ -y ] [ category/ports.. ] [ ports.. ]"
    echo ""
    echo "  Notes:"
    echo "      Default to TEST MODE (nothing changed)"
    echo "      Give argument \"-y\" to really execute/apply change"
    echo ""
    echo "      If not an absolute path, REPODIR will be taken as"
    echo "      relative path to/under USERPORTS"
    echo ""
    echo "  Warning:"
    echo "      If you supplied ONLY port name, i.e. DID NOT specify"
    echo "      any categories, then ALL categories which have the same"
    echo "      port name will be all affected (moved)"
    echo ""
    echo "      Category/package might be glob. You've been warned."
    echo ""
    echo "  | Backstory:"
    echo "  | "
    echo "  | We used to build ports from very minimal set of packages"
    echo "  | After building INDEX, most of them (nearly all) were initially"
    echo "  | put in the repository, where they categorized/grouped further,"
    echo "  | for instance: REPODIR/bigfellas/astro/..."
    echo "  | "
    echo "  | Then one-by-one we put them back in the root ($USERPORTS)"
    echo "  | merely based on dependencies requirement *)"
    echo "  | *) non-existent packages warning upon ports compilation"
    echo "  | "
    echo "  | This script is create specially to handle that task:"
    echo "  | move back packages from REPODIR to USERPORTS"
    echo ""
    echo "  Default values (set/edit these vars as necessary)"
    echo ""
    echo "      USERPORTS=$USERPORTS"
    echo "      REPODIR=$REPODIR"
    echo ""
    echo "  Important:"
    echo "      pkg categories MUST be grouped further under the repo dir"
    echo "      (add 1 layer up, example: REPODIR/\"obsolete\"/irc/irc)"
    echo ""
    echo "      according to tradition, group name should be in lowercase"
    echo ""
    echo "  Notes:"
    echo "      Both USERPORTS and REPODIR should reside on the same device"
    echo "      (using hardlink to copy Makefile), though it's quite easy to"
    echo "      change this behaviour (by using symlink or simple copy), we"
    echo "      don't recommend it, REPODIR should even better put under"
    echo "      USERPORTS instead"
    showMode
}


case "$1" in
    -[hH\?]|--[hH\?]|"") showHelp;;
    -y) shift; echo=;;
esac

test -z "$1" && showHelp;
test -n "$*" || showHelp;

for arg; do

    test -n "${arg##[!a-z0-9_/]*}" || {
        echo "invalid: $arg"
        continue
    }

    package="${arg##*/}"

    test -n "${package##[!A-Za-z0-9_]*}" || {
        echo "skipped: $package"
        continue
    }

    category="`dirname "$arg"`"

    test "$category" = "." && \
        packlist="`ls -d "$REPODIR"/*/*/$package`" || \
        packlist="`echo $REPODIR/[a-z0-9_]*/$arg`"

    for fullpath in $packlist; do

        category="`dirname $fullpath`"
        category="${category##*/}"

        package="${fullpath##*/}"

        PKG="$category/$package"

	test -d "$USERPORTS/$PKG" && {
	    echo "already exist: $USERPORTS/$PKG"
	    continue
        }

        PICKED="`echo $REPODIR/[a-z0-9_]*/$PKG`"
	test -f "$PICKED/Makefile" || {
	    echo "port is not exist: $PICKED"
	    continue
	}

	unset OKEH

	if test -r pkg-descr -o -r pkg-plist; then
	    OKEH=1
	else
	    if test "$HAVE_GREP"; then
	        #unset OKEH
	        grep -q "^ *SUBDIR *+=" "$PICKED/Makefile" && {
		    echo "category directory: $PICKED"
		    continue
	        }

	        if grep -q "\(PORT\|PKG\||VER\|USE[_S]\|MAINT\|WANT\)" "$PICKED/Makefile"; then
		    OKEH=1
	        else
		    if grep -q "\.CURDIR" "$PICKED/Makefile"; then
		        OKEH=1
		    else
		        echo "invalid directory: $PICKED"
		        continue
		    fi
	        fi
	    fi
	fi

        USERCAT="$USERPORTS/$category" 

        test -d "$USERCAT" || {
            echo "creating category: $USERCAT"
            $echo mkdir -pv "$USERCAT"
            $echo ln -v "$PICKED/../Makefil"* "$USERCAT"
        }

        $echo mv -v "$PICKED" "$USERCAT"
    done

done

test -n "$echo" && showMode
