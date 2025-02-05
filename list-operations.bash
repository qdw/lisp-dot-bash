#!/opt/homebrew/bin/bash

DEBUG_LEVEL="$DEBUG_LEVEL_FOR_LISP_DOT_BASH"

function add {
    local ACC=0
    for ARG in "$@"; do
        ((ACC = ACC + ARG))
    done
    echo "$ACC"
}

# Operator overloading in Bash has limitations.
# You can define a function named +
# but you can't define a function named >
# So, instead, we'll map all Lisp operators
# to function calls, like this:
#
# lisp op   bash function
# +         add
# >         greater than
# ...
# function + {
#     add "$@"
# }

function apply {
    local FUNC="$1"
    shift
    $FUNC "$@"
}

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

# function scalist {
#     local SCALIST
#     SCALIST[0]="a"
#     SCALIST[1]="b"
#     for ((i=0; i<${#SCALIST[@]}; i++)); do
#         debug "scalist elem $i:" ${SCALIST[i]}
#     done
#     debug "${SCALIST[*]}"
#     echo "${SCALIST[*]}"
# }

# function scalist-caller {
#     local -a LS=("$(scalist)")
#     debug "scalist returned $LS"
    
#     # for ((i=0; i<${#LS[@]}; i++)); do
#     for ELEM in ${LS[@]}; do
#         echo "'$ELEM'"
#     done
# }

function debug-car {
    local -a LIST=("$@")
    debug "input: " ${LIST[@]}
    local RETVAL="${LIST[0]}"
    debug "output: $RETVAL"
    echo "$RETVAL"
}

function car {
    local -a LIST=("$@")
    echo "${LIST[0]}"
}

function alt-car {
    echo "$1"
}

function debug-cdr {
    local -a LIST=("$@")
    debug "input: ${LIST[@]}"
    local LENGTH=${#LIST[@]}
    debug "length: $LENGTH"
    echo ${LIST[@]:1:LENGTH}
}

function cdr {
    local -a LIST=("$@")
    local LENGTH=${#LIST[@]}
    echo ${LIST[@]:1:LENGTH}
}

function alt-cdr {
    shift
    echo "$@"
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

function alt-last-elem-of {
    echo ${!#}
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

function _alt_pop {
    local -a LIST=("$@")
    local LAST_ELEM="${LIST[-1]}"
    unset LIST[-1]
    
    OFS=$'\x1F'
    printf "${LAST_ELEM}${OFS}${LIST[*]}"
}

function run-unit-tests {
    #### Fixtures
    
    local -a FLAT_LIST=("+" "1" "2" "97")
    local -a CONSTRUCTED_FLAT_LIST="$(list + 2 4 200)"
    
    #### Working tests (denoted by commenting out with '## ')

    debug "literal flat list:" ${FLAT_LIST[@]}
    debug "constructed flat list:" ${CONSTRUCTED_FLAT_LIST[@]}

    local LEN=$(length ${FLAT_LIST[@]})
    debug "list length: $LEN"

    local CAR="$(car ${FLAT_LIST[@]})"
    debug "car: $CAR"

    local ALT_CAR="$(alt-car ${FLAT_LIST[@]})"
    debug "alt-car: $CAR"

    local -a CDR="$(cdr ${FLAT_LIST[@]})"
    debug "cdr: $CDR"

    local -a ALT_CDR="$(alt-cdr ${FLAT_LIST[@]})"
    debug "alt-cdr: ${ALT_CDR[@]}"

    local LAST_ELEM="$(last-elem-of ${FLAT_LIST[@]})"
    debug "last element: $LAST_ELEM"

    local ALT_LAST_ELEM="$(alt-last-elem-of ${FLAT_LIST[@]})"
    debug "alt last element: $ALT_LAST_ELEM"

    local -a TRUNCATED_LIST=$(list-sans-last-elem ${FLAT_LIST[@]})
    debug "list after removing last element: ${TRUNCATED_LIST[@]}"

    function pop {
        local LIST_NAME="$1"
        local ELEM_NAME="$2"
        local NEW_LIST_NAME="$3"
        eval "IFS=$'\x1F' read -r $ELEM_NAME $NEW_LIST_NAME <<< \"\$(_pop \${$LIST_NAME[@]})\""
    }
    
    function push {
        local ELEM="$1"
        shift
        
        list "$@" $ELEM
    }
    
    pop FLAT_LIST  POPPED_ELEM  POPPED_LIST
    debug "popped last element: $POPPED_ELEM"
    debug "list after popping: $POPPED_LIST"
    
    function pop-by-reference {
        local LIST_NAME="$1"
        local ELEM_NAME="$2"
        local NEW_LIST_NAME="$3"
        eval "IFS=$'\x1F' read -r $ELEM_NAME $NEW_LIST_NAME <<< \"\$(_alt_pop \${$LIST_NAME[@]})\""
    }

    pop-by-reference FLAT_LIST  ALT_POPPED_ELEM  ALT_POPPED_LIST
    debug "pop-by-reference set ALT_POPPED_ELEM to this value: $ALT_POPPED_ELEM"
    debug "pop-by-reference set ALT_POPPED_LIST to this value: ${ALT_POPPED_LIST[@]}"
    
    local -a PUSH_RETVAL=("$(push "f" "${FLAT_LIST[@]}")")
    debug "pushed-to list: ${PUSH_RETVAL[@]}"
    
    SUM="$(add 1 2 3 4)"
    debug "add 1 2 3 4 -> $SUM"
    
    local -a ARR=("1" "2" "3" "4")
    ARRSUM=$(add ${ARR[@]})
    debug "add with array arg -> $ARRSUM"
    
    APSUM="$(apply add 1 2 3 4)"
    debug "apply add 1 2 3 4 -> $APSUM"
}    



# Standard operations defined in Scheme



# >op.gt,
# abs
# append
# apply
# begin
# car
# cdr
# cons
# eq?
# expt
# equal?
# length
# list
# list?
# map
# max
# min
# not
# null?
# number?
# print
# procedure?
# round
# symbol?


# Run the main function only if this script was executed directly;
# don't run it if this script was source'd by a different Bash script.
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    run-unit-tests "$@"
fi
