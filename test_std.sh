#!/bin/bash
SELF=$(realpath $0)
SELF_PARENT=$(dirname $0)
#debug=no
#set -x

source $SELF_PARENT/std.sh

# Set true to test.
if true
then
    parse_all_params $@
    for i in $foo $verbose $v $debug $d $p; do
        if exists $i; then
            write $foo
        fi
    done
fi

# Set true to test.
if false
then
    define_param switch debug $@
    define_param switch verbose $@
    define_param short foo $@
    define_param long bazz $@
    define_param shortlong hello $@
fi

# TEST for define_parm function
if false
then
	for i in switch short long 'stringlong'
	do
		LOCATION=$(define_param $i location "$@")
		if exists $LOCATION; then echo $LOCATION; fi
	done
fi


# Set true to test.
if true
then
    echo

    write $(basename ${BASH_SOURCE[0]}) is just a test file.

    verbose $(basename ${BASH_SOURCE[0]}) is just a test file.

    debug $(basename ${BASH_SOURCE[0]}) is just a test file.

    error $(basename ${BASH_SOURCE[0]}) is just a test file.
fi

exit
