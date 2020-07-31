parse_all_params() {
    # Parses all arguments passed to a script or function. The varables do not need to be defined beforehand.
    #
    # If a `-f` true false switch is passed, a varible named `f` is created and set to `yes`.
    # If a `-f <arg-value>` is passed, a variable named `f` is created and set to `<arg-value>`.
    # The functionality above is equivalent for parameters passed with a `--` prefix. e.g. `--force`
    #
    # Args:
    #   $@: Inherent form caller script/function.
    #
    # Returns:
    #   Dynamic variables based on the name of passed parameters.
    #
    while [ $# -gt 0 ]; do
        if expr match $1 '--' > /dev/null;then str_rm='--'; elif expr match $1 '-' > /dev/null; then str_rm='-'; fi
        name=${1#$str_rm}
        if expr match $1 '--' > /dev/null || expr match $1 '-' > /dev/null; then
            if { if [ ! -z $2 ]; then true; else false; fi; } && ! { case $2 in "-"*) true;; *) false;; esac; }; then
                value=$2
                shift
            else
                value=yes
            fi
        # Uncommenting the following two lines will allow passing a switch without a `-` or `--` prefix. This may induce undefined operation.
        #else
            #value=yes
        fi
        
        #echo "$name = $value"
        IFS= read -r -d '' "$name" <<< $value
        shift
    done
}

param() {
    # Parses all parameters passed to a script or function for the specified TYPE and NAME given.
    # If a match is found, a dynamic variable will be created with the name of the passed parameter.
    # The value of this parameter will depend on the TYPE specified.
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
    #   $@: 
    #       This must be passed in order to pass the callers parameters into the function.
    #
    # Examples:
    #   `param switch debug $@`
    #       Parses parameters and matches the parameter `-debug` or `--debug`. After a match, $debug = 'yes'.  
    #   
    #   `param short l $@`
    #       Parses parameters and matches the parameter `-l 386`. After a match, $l = 386.
    #   
    #   `param long length $@`
    #       Parses parameters and matches the parameter `--length 386`. After a match, $length = 386
    #
    # Returns: 
    #   A Dynamic variable based on the positional TYPE and NAME parameters.
    #
    TYPE=$1
    NAME=$2
    argnum=3
    #echo
    #echo PARAMETER NAME: $NAME
    #echo PARAMETER TYPE: $TYPE
    #echo
    #echo FUNCTION_START: argnum=$argnum
    while [ $# -gt 2 ]; do 
        #echo LOOP_START: argnum=$argnum
        case $TYPE in
            switch|--switch|-sw|sw) {
                if [ "$3" = "-$NAME" ] || [ "$3" = "--$NAME" ]; then 
                    if { if [ ! -z $4 ]; then true; else false; fi; } && ! { case $4 in "-"*) true;; *) false;; esac; }; then
                        echo error: "Switch $3 Does Not Take an Argument."
                        exit 1
                    fi
                IFS= read -r -d '' "$NAME" <<< 'yes';
                #echo $NAME = yes  
                return 0
                fi 
            } ;;
            short|string|--string|-str|str) {
                if [ "$3" = "-$NAME" ]; then
                    if { if [ ! -z $4 ]; then true; else false; fi; } && ! { case $4 in "-"*) true;; *) false;; esac; }; then 
                        shift;
                        argnum=$(expr $argnum + 1) ; #echo SHORT argnum=$argnum                          
                        IFS= read -r -d '' "$NAME" <<< $3;
                        #echo $NAME = $3 
                        return 0                  
                    else
                        echo error "Parameter $3 Requires an Argument."
                        exit 1
                    fi
                fi
            } ;;
            long|longstring|--longstring|-lstr|lstr) {
                if [ "$3" = "--$NAME" ]; then
                    if { if [ ! -z $4 ]; then true; else false; fi; } && ! { case $4 in "-"*) true;; *) false;; esac; }; then 
                        shift; 
                        argnum=$(expr $argnum + 1) ; #echo LONG: argnum=$argnum 
                        IFS= read -r -d '' "$NAME" <<< $3;
                        #echo $NAME = $3 
                        return 0                  
                    else
                        echo error: "Parameter $3 Requires an Argument."
                        exit 1
                    fi
                fi
            } ;;
            shortlong|SHORTLONG) {
                if [ "$3" = "-$NAME" ] || [ "$3" = "--$NAME" ]; then
                    if { if [ ! -z $4 ]; then true; else false; fi; } && ! { case $4 in "-"*) true;; *) false;; esac; }; then 
                        shift; 
                        argnum=$(expr $argnum + 1); #echo SHORTLONG: argnum=$argnum
                        IFS= read -r -d '' "$NAME" <<< $3;
                        #echo $NAME = $3 
                        return 0
                    else
                    echo error "Parameter $3 Requires an Argument."
                    exit 1
                    fi
                fi
            } ;;
        esac
        shift
        argnum=$(expr $argnum + 1)
    done
}