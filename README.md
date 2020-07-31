# libsh
A collection of shell libraries/functions. 

## Libraries
### Dynamic Parsers

Filename: `dynamic_parsers.sh`

Include in script: `source <path-to-repo>/dynamic_parsers.sh`

#### Functions

##### `parse_all_params`
    ```
    Parses all arguments passed to a script or function. The varables do not need to be defined beforehand.
    
     If a `-f` true false switch is passed, a varible named `f` is created and set to `yes`.
     If a `-f <arg-value>` is passed, a variable named `f` is created and set to `<arg-value>`.
     The functionality above is equivalent for parameters passed with a `--` prefix. e.g. `--force`
    
     Args:
       $@: Inherent form caller script/function.
    
     Returns:
       Dynamic variables based on the name of passed parameters.
    ```

##### `param`
    ```
     Parses all parameters passed to a script or function for the specified TYPE and NAME given.
     If a match is found, a dynamic variable will be created with the name of the passed parameter.
     The value of this parameter will depend on the TYPE specified.
    
     Args:
       TYPE: 
           switch :     true or false parameter which does not accept an argumet. Will only be detected 
                        if passed with a short ('-') or long ('--') prefix. e.g. -verbose or --verbose
           short  :     Parameter which accepts an argument. Will only be detected if passed with a
                        short ('-') prefix. e.g. -p 8572 or -port 4545
           long   :     Parameter which accepts an argument. Will only be detected if passed with a 
                        long ('--') prefix. e.g. --p 8572 or --port 4545
           shortlong:   Parameter which accepts an argument. Will only be detected if passed with a
                        short ('-') or long ('--') prefix. e.g. -port  4545 or --port 4545
       
       NAME:
           The varable name in which to save the value of the argument passed to the parameter. This will also be the 
           name of the parameter.
    
       $@: 
           This must be passed in order to pass the callers parameters into the function.
    
     Examples:
       `param switch debug $@`
           Parses parameters and matches the parameter `-debug` or `--debug`. After a match, $debug = 'yes'.  
       
       `param short l $@`
           Parses parameters and matches the parameter `-l 386`. After a match, $l = 386.
       
       `param long length $@`
           Parses parameters and matches the parameter `--length 386`. After a match, $length = 386
    
     Returns: 
       A Dynamic variable based on the positional TYPE and NAME parameters.
    ````

#### Testing

Run `./test_parsers.sh`

Edit `test_parsers.sh` and change the `if` statments to test each function.

### Standard

Filename: `std.sh`

Include in script: `source <path-to-repo>/std.sh`

#### Functions

See script file (for now).

#### Testing 

Run `./test_std.sh`
