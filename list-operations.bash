#!/opt/homebrew/bin/bash

DEBUG_LEVEL="$DEBUG_LEVEL_FOR_LISP_DOT_BASH"

function length {
    local -a LIST=("$@")
    echo ${#LIST[@]}
}

function debug {
    local CALLER="${FUNCNAME[1]}"
    local STACK_DEPTH=$(length ${FUNCNAME[@]})
    local STACK_DEPTH_OF_CALLER=$((STACK_DEPTH - 2))
    # echo "Caller $CALLER is $STACK_DEPTH_OF_CALLER deep"
    # echo "Debug level is $DEBUG_LEVEL"
    
    if [[ $DEBUG_LEVEL -ge $STACK_DEPTH_OF_CALLER ]]; then
        echo "$CALLER:" "$@" >/dev/stderr
    fi
}

function list {
    echo "$@"
}

function car {
    local -a LIST=("$@")
    debug "input: " ${LIST[@]}
    local RETVAL="${LIST[0]}"
    debug "output: $RETVAL"
    echo "$RETVAL"
}

function cdr {
    local -a LIST=("$@")
    debug "input: ${LIST[@]}"
    local LENGTH=${#LIST[@]}
    debug "length: $LENGTH"
    echo ${LIST[@]:1:LENGTH}
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
# Then use a horrible eval-read kludge to unpack the two retvals.
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
    echo "${LIST[-1]}"
}

function list-sans-last-elem {
    local -a LIST=("$@")
    local LENGTH=${#LIST[@]}
    local LAST_INDEX=$(( LENGTH - 1 ))
    echo ${LIST[@]:0:LAST_INDEX}
}

function _pop {
    local -a LIST=("$@")

    local LAST="$(last-elem-of ${LIST[@]})"
    local -a REST="$(list-sans-last-elem ${LIST[@]})"
    
    OFS=$'\x1F'
    printf "${LAST}${OFS}${REST}"
}

function run-unit-tests {
    #### Fixtures
    
    local FLAT_LIST=("+ 1 2 97")
    local CONSTRUCTED_FLAT_LIST="$(list + 2 4 200)"
    
    #### Working tests

    debug "Literal flat list:" ${FLAT_LIST[@]}
    
    debug "Constructed flat list:" ${CONSTRUCTED_FLAT_LIST[@]}
    
    local LEN=$(length ${FLAT_LIST[@]})
    debug "List length: $LEN"

    local CAR="$(car ${FLAT_LIST[@]})"
    debug "car: $CAR"
    
    local -a CDR=($(cdr ${FLAT_LIST[@]}))
    debug "cdr: ${CDR[@]}"
    
    local LAST_ELEM="$(last-elem-of ${FLAT_LIST[@]})"
    debug "Last element of the literal list: $LAST_ELEM"

    local -a TRUNCATED_LIST=$(list-sans-last-elem ${FLAT_LIST[@]})
    debug "List after removing last element: ${TRUNCATED_LIST[@]}"

    function pop {
        local LIST_NAME="$1"
        local ELEM_NAME="$2"
        local NEW_LIST_NAME="$3"
        eval "IFS=$'\x1F' read -r $ELEM_NAME $NEW_LIST_NAME <<< \"\$(_pop \${$LIST_NAME[@]})\""
    }

    pop FLAT_LIST  POPPED_ELEM  POPPED_LIST
    debug "POPPED_ELEM: $POPPED_ELEM"
    debug "POPPED_LIST: $POPPED_LIST"
}

# Run the main function only if this script was executed directly;
# don't run it if this script was source'd by a different Bash script.
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    run-unit-tests "$@"
fi
