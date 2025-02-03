#!/opt/homebrew/bin/bash

function main_list_ops {
    set -eu
    source "$(dirname "$0")/lisp.bash" # to get the debug() function
    set +eu
        
    function list {
        echo "$@"
    }
    
    function car {
        local -a CAR_TOKENS=("$@")
        debug "input: " ${CAR_TOKENS[*]}
        local CAR_RETVAL="${CAR_TOKENS[0]}"
        debug "output: $CAR_RETVAL"
        echo "$CAR_RETVAL"
    }
    
    function cdr {
        local -a CDR_TOKENS=("$@")
        debug "input: ${CDR_TOKENS[*]}"
        local CDR_RETVAL=${CDR_TOKENS[@]}
        debug "output: $CDR_RETVAL"
        echo "$CDR_RETVAL"
    }
    
    # I can't figure out how to implement pop in Bash
    # without resorting to eval, because Bash allows
    # neither array pass-by-reference nor returning
    # multiple values - so I can't mutate the array
    # inside the pop function, and I can't return
    # the last element and the rest of the array
    # as separate values, either.
    # 
    # So I see two possible solutions:
    # 
    # 1. Be evil, use eval, and take the performance hit.
    #
    # 2. Split pop into two separate functions, last-elem-of
    # and remove-last-elem. The first just returns the element
    # without modifying the array. The second takes an array
    # and returns a new array consisting of all its elements
    # but the last.
    # 
    # I went ahead and implemented both solutions,
    # but I like the evil one better. Who wants to remember
    # to call two functions?    
    function last-elem-of {
        local -a LIST=("$@")
        debug "input: ${LIST[*]}"    
        local LAST_ELEM="${LIST[-1]}"
        debug "output: $LAST_ELEM"
        echo "${LAST_ELEM}"
    }
    
    function remove-last-elem {
        local -a LIST=("$@")
        unset LIST[-1]
        echo "${LIST[*]}"
    }
    
    function pop {
        local LISTNAME="$1"
        local -a LIST=("$(eval "echo \$$LISTNAME")")
        local POP_RETVAL="${LIST[-1]}"
        echo "$POP_RETVAL"
        
        # Hm, this part doesn't work. Dunno why.
        set -x
        eval "unset $LISTNAME[-1]"
        set +x
    }
    
    MYAR=("a" "b" "cde")
    MLEM="$(pop MYAR)"
    # unset MYAR[-1]
    echo "MLEM! $MLEM"
    echo "MYAR! ${MYAR[*]}"
        
    # local LAST_ELEM=$(last-elem-of 
    # local LESS_EVIL_ELEM=$(printf "%s%s%s%s" '$' '{' "$LISTNAME[-1]" '}')
    # echo "$LESS_EVIL_ELEM"
    # eval "$LESS_EVIL_ELEM"
        
    # #local EVIL_CODE="echo \${$LISTNAME[-1]}"
    # #local LAST_ELEM=$(eval "$EVIL_CODE")
        
    # echo "$LAST_ELEM"
            
    
    ######### Unit tests
    ######### vvvvvvvvvv
    ### Fixtures
    T_LITERAL_FLAT_LIST=("+ 1 2 97")
    T_CONSTRUCTED_FLAT_LIST="$(list + 2 4 200)"
    
    ### Working tests
    ##debug "Literal flat list:" ${T_LITERAL_FLAT_LIST[@]}
    ##local CAR_LIT=$(car ${T_LITERAL_FLAT_LIST[@]})
    ##debug "car of that list: $CAR_LIT"
    ##debug "Constructed flat list: ${T_CONSTRUCTED_FLAT_LIST[@]}"
    ##local CAR_CONSTRUCTED=$(car ${T_CONSTRUCTED_FLAT_LIST[@]})
    ##debug "car of that list: $CAR_CONSTRUCTED"
    
    ### Not yet working
    # local ELEM="$(pop T_LITERAL_FLAT_LIST)"
    # debug "Last element, popped from the literal list: $ELEM"
    # debug "List after popping: ${T_LITERAL_FLAT_LIST[*]}"

    
    # echo "cdr: $(cdr $T_LITERAL_FLAT_LIST)"
    # echo "Constructed flat list: $(list + 1 2 97)"

    # debug "Evaluating..."
    # evl "$AST"
    ######### ^^^^^^^^^^
    ######### End of unit tests
}

# Run the main function only if this script was executed directly;
# don't run it if this script was source'd by a different Bash script.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_list_ops "$@"
fi
