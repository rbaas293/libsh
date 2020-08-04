REPO_ROOT=$(dirname $0)
NULL=/dev/null

setup_color() {
        # Only use colors if connected to a terminal, unless override is passed.
        override=$1
        if [ -t 1 ] || [ ! -z "$override" ] ; then
                RED=$(printf '\033[31m')
                GREEN=$(printf '\033[32m')
                YELLOW=$(printf '\033[33m')
                BLUE=$(printf '\033[34m')
                MAGENTA=$(printf '\033[95m')
                CYAN=$(printf '\033[36m')
                BOLD=$(printf '\033[1m')
                ITALIC=$(printf '\033[3m')
                RESET=$(printf '\033[m')
                WARNING=$(printf '\033[93m')
                HEADER=$(printf '\033[95m')
                UNDERLINE=$(printf '\033[4m')

        else
                RED=""
                GREEN=""
                YELLOW=""
                BLUE=""
                BOLD=""
                RESET=""
        fi
}

setup_color

error() {
        echo ${BOLD}"$(basename $0):${RESET}${RED} Error   --> ${BOLD}$@"${RESET} >&2
}

verbose() {
    for i in $verbose $VERBOSE $v $V; do
        if expr match $i 'yes' > /dev/null; then
            echo ${BOLD}"$(basename $0):${RESET}${YELLOW} Verbose --> "${BOLD}"$@"${RESET}
            return
        fi
    done
}

debug() {
    for i in $debug $DEBUG $d $D; do
        if expr match $i 'yes' > /dev/null; then
            echo ${BOLD}"$(basename $0):${RESET}${CYAN} Debug   --> "${BOLD}"$@"${RESET}
            return
        fi
    done
}

debugg() {
    for i in $debugg; do
        if expr match $i 'yes' > /dev/null; then
            echo ${BOLD}"$(basename $0):${RESET}${CYAN} Debug   --> "${BOLD}"$@"${RESET}
            return
        fi
    done
}

write() {
        echo $BOLD"$(basename $0):${RESET} $@"
}

command_exists() {
        command -v "$@" >/dev/null 2>&1
}

beginswith() { case $2 in "$1"*) true;; *) false;; esac; }

checkresult() { if [ $? = 0 ]; then echo TRUE; else echo FALSE; fi; }

exists() { if [ ! -z $1 ]; then true; else false; fi; }

make_sh_macos_compatible() {
    if expr "$OSTYPE" : 'darwin' > /dev/null; then
        realpath() { 
            { case $1 in "/"*) true;; *) false;; esac; } && echo "$1" || echo "$PWD/${1#./}" 
        }
    fi
}

parse_all_params() {
    # Parses all arguments passed to a script or function. The varables do not need to be defined beforehand.
    #
    # If a `-f` true false switch is passed, a varible named `f` is created and set to `yes`.
    # If a `-f <arg-value>` is passed, a variable named `f` is created and set to `<arg-value>`.
    # The functionality above is equivalent for parameters passed with a `--` prefix. e.g. `--force`
    #
    # Args:
    #   $@: Inherent form caller script/function.
    #   --debug : Debug by displaying parameter names and values.
    #
    # Returns:
    #   Dynamic variables based on the name of passed parameters.
    #
    define_param switch debug $@

    while [ $# -gt 0 ]; do
        if expr $1 : '--.' > /dev/null; then str_rm='--'; elif expr $1 : '-.' > /dev/null; then str_rm='-'; fi
        name=${1#$str_rm}
        if expr $1 : '--.' > /dev/null || expr $1 : '-.' > /dev/null; then
            if exists $2 && ! beginswith '-' $2; then
                value=$2
                shift
            else
                value=yes
            fi
        # Uncommenting the following two lines will allow passing a switch without a `-` or `--` prefix. This may induce undefined operation.
        #else
            #value=yes
        fi

        debug "$name = $value"

        IFS= read -r -d '' "$name" <<< $value
        shift
    done
}

define_param() {
    # Parses all parameters passed to a script or function for the specified TYPE and NAME given.
    # If a match is found, a dynamic variable will be created with the name of the passed parameter.
    # The valuethis parameter will be set equal to will depend on the TYPE specified.
    #
    # Args:
    #   TYPE: 
    #       switch :     true or false parameter which does not accept an argumet. Will only be detected 
    #                    if passed with a short ('-') or long ('--') prefix. e.g. -verbose or --verbose
    #       short  :     Parameter which accepts an argument. Will only be detected if passed with a
    #                    short ('-') prefix. e.g. -p 8572 or -port 4545
    #       long   :     Parameter which accepts an argument. Will only be detected if passed with a 
    #                    long ('--') prefix. e.g. --p 8572 or --port 4545
    #       shortlong:   Parameter which accepts an argument. Will only be detected if passed with a
    #                    short ('-') or long ('--') prefix. e.g. -port  4545 or --port 4545
    #   
    #   NAME:
    #       The varable name in which to save the value of the argument passed to the parameter. This will also be the 
    #       name of the parameter.
    #   
    #   dbugg:
    #       If 'debugg' is passed as positional parameter 3, even more debug messages tha the standared `--debug` will be printed.
    #
    #   $@: 
    #       This must be passed in order to pass the callers parameters into the function.
    #
    # Examples:
    #   `define_param switch debug $@`
    #       Parses parameters and matches the parameter `-debug` or `--debug`. After a match, $debug = 'yes'.  
    #   
    #   `define_param short l $@`
    #       Parses parameters and matches the parameter `-l 386`. After a match, $l = 386.
    #   
    #   `define_param long length $@`
    #       Parses parameters and matches the parameter `--length 386`. After a match, $length = 386/
    #
    # Returns: 
    #   A Dynamic variable based on the positional TYPE and NAME parameters.
    #
    TYPE=$1
    NAME=$2
    argnum=3
    # if even more than just --debug is needed, the set the below variable to 'yes' or pass debugg as the third argument
    debugg=no
    if exists $3 && [ "$3" = "debugg" ]; then
        debugg=yes
        shift;
        argnum=$(expr $argnum + 1)
    fi
    debugg
    debugg PARAMETER NAME: $NAME
    debugg PARAMETER TYPE: $TYPE
    debugg
    debugg FUNCTION_START: argnum=$argnum
    while [ $# -gt 2 ]; do 
        debugg LOOP_START: argnum=$argnum
        case $TYPE in
            switch|--switch|-sw|sw) {
                if [ "$3" = "-$NAME" ] || [ "$3" = "--$NAME" ]; then 
                    if exists $4 && ! beginswith '-' $4; then
                        error "Switch $3 Does Not Take an Argument."
                        exit 1
                    fi

                IFS= read -r -d '' "$NAME" <<< 'yes';
                debug $NAME = yes  
                return 0
                fi 
            } ;;
            short|string|--string|-str|str) {
                if [ "$3" = "-$NAME" ]; then
                    if exists $4 && ! beginswith '-' $4 ; then 
                        shift;
                        argnum=$(expr $argnum + 1) ; debugg SHORT argnum=$argnum                          
                        IFS= read -r -d '' "$NAME" <<< $3;
                        debug $NAME = $3 
                        return 0                  
                    else
                        error "Parameter $3 Requires an Argument."
                        exit 1
                    fi
                fi
            } ;;
            long|longstring|--longstring|-lstr|lstr) {
                if [ "$3" = "--$NAME" ]; then
                    if exists $4 && ! beginswith '-' $4 ; then 
                        shift; 
                        argnum=$(expr $argnum + 1) ; debugg LONG: argnum=$argnum 
                        IFS= read -r -d '' "$NAME" <<< $3;
                        debug $NAME = $3 
                        return 0                  
                    else
                        error "Parameter $3 Requires an Argument."
                        exit 1
                    fi
                fi
            } ;;
            shortlong|SHORTLONG) {
                if [ "$3" = "-$NAME" ] || [ "$3" = "--$NAME" ]; then
                    if exists $4 && ! beginswith '-' $4 ; then 
                        shift; 
                        argnum=$(expr $argnum + 1); debugg SHORTLONG: argnum=$argnum
                        IFS= read -r -d '' "$NAME" <<< $3;
                        debug $NAME = $3 
                        return 0
                    else
                    error "Parameter $3 Requires an Argument."
                    exit 1
                    fi
                fi
            } ;;
        esac
        shift
        argnum=$(expr $argnum + 1)
    done
    debugg DONE: argnum=$argnum
}

need_root() {
    # Check to see if the caller of this function is a root user.
    # If caller is not root, an error message is printed and the script is exited
    #
    # args: None
    #
    # returns: boolean
    if command -v "whoami" >/dev/null 2>&1; then
        if [ $(whoami) != root ]; then
                echo "This script must be run as root"
                exit 1
        fi
    else
        if [ $EUID -ne 0 ]; then
            echo "This script must be run as root"
                exit 1
        fi
    fi
    return 0
}

check_file() {
	# Check file or directory existence. Writes to stderr if does not exist.
	# Exits by default, but second argument can be passed to bypass exit.
    #
    # Args:
    #   Position 1: File
    #   Position 2: Exit Functionality. To Continue without exiting pass `continue` or `c`
    #
    # Returns:
    #   Boolean
    #
	FILE=$1
	EXIT=$2
	if [ ! -e $FILE ]; then
		error "Path Does Not Exist: $FILE"
		case $EXIT in
			exit|EXIT|E|e) exit 1 ;;
			continue|CONTINUE|C|c) return 1 ;;
			*) exit 1;;
		esac
	fi
        return 0
}
