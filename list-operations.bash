#!/opt/homebrew/bin/bash

source "$(dirname "$0")/tap.bash"

DEBUG_LEVEL="$DEBUG_LEVEL_FOR_LISP_DOT_BASH"

function abs {
    local NUM="$1"
    NUM="${NUM//-/}"
    echo "$NUM"
}

function arith {
    local OP="$1"
    shift
 
    local ACC="$1"
    shift
    for ARG in "$@"; do
        ((ACC=ACC "$OP" ARG))
    done
    echo "$ACC"
}

function gt {
    if [[ "$1" -gt "$2" ]]; then
        echo "'t"
    else
        echo "nil"
    fi
}

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
    if [[ "$DEBUG_LEVEL" = "0" ]] || [[ "$DEBUG_LEVEL" = ""  ]]; then
        return
    fi

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

function car {
    echo "$1"
}

function cdr {
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
    local LAST_ELEM="${LIST[-1]}"
    unset LIST[-1]
    
    OFS=$'\x1F'
    printf "${LAST_ELEM}${OFS}${LIST[*]}"
}

function run-unit-tests {
    plan 10

    #### Fixtures
    
    local -a FLAT_LIST=("+" "1" "2" "97")
    local -a CONSTRUCTED_FLAT_LIST="$(list + 2 4 200)"
    
    #### Working tests (denoted by commenting out with '## ')

    debug "literal flat list:" ${FLAT_LIST[@]}
    is  "${FLAT_LIST[*]}"  "+ 1 2 97"  "literal list"

    debug "constructed flat list:" ${CONSTRUCTED_FLAT_LIST[@]}
    is  "${CONSTRUCTED_FLAT_LIST}"  "+ 2 4 200"  "op 'list'"    

    local LEN=$(length ${FLAT_LIST[@]})
    debug "list length: $LEN"
    is  "$LEN"  4  "op 'length'"

    local CAR="$(car ${FLAT_LIST[@]})"
    debug "car: $CAR"
    is  "$CAR" "+" "op 'car'"

    local -a CDR="$(cdr ${FLAT_LIST[@]})"
    debug "cdr: $CDR"
    is  "$CDR"  "1 2 97"  "op 'cdr'"

    local LAST_ELEM="$(last-elem-of ${FLAT_LIST[@]})"
    debug "last element: $LAST_ELEM"

    local -a TRUNCATED_LIST=$(list-sans-last-elem ${FLAT_LIST[@]})
    debug "list after removing last element: ${TRUNCATED_LIST[@]}"

    function push {
        local ELEM="$1"
        shift
        
        echo "$@" "$ELEM"
    }
    
    function pop-by-ref {
        local LIST_NAME="$1"
        local ELEM_NAME="$2"
        local NEW_LIST_NAME="$3"
        eval "IFS=$'\x1F' read -r $ELEM_NAME $NEW_LIST_NAME <<< \"\$(_pop \${$LIST_NAME[@]})\""
    }
    
    local POPPED_ELEM
    local -a POPPED_LIST
    pop-by-ref FLAT_LIST  POPPED_ELEM  POPPED_LIST
    debug "popped last element: $POPPED_ELEM"
    debug "list after popping: ${POPPED_LIST[@]}"

    local -a PUSH_RETVAL=("$(push "f" "${FLAT_LIST[@]}")")
    debug "pushed-to list: ${PUSH_RETVAL[@]}"
    
    SUM="$(arith '+' 1 2 3 4)" # 10
    debug "arith '+' 1 2 3 4 -> $SUM"
    
    local DIVIDEND="$(arith '/' 64 2 2 4)" # 4
    debug "arith '/' 64 2 2 4 -> $DIVIDEND"
    
    local PRODUCT="$(arith '*' 2 8 4)" # 64
    debug "arith '*' 2 8 4 -> $PRODUCT"
    
    local MINOR="$(arith '-' 32 16 6)" # 10
    debug "arith '-' 32 16 6 -> $MINOR"
    
    local ABS_POS="$(abs 100)"
    debug "abs 100 -> $ABS_POS" # 100
    is  "$ABS_POS"  "100"  "op 'abs' with positive arg"
    
    local ABSOLUTE_ZERO="$(abs 0)"
    debug "abs 0 -> $ABSOLUTE_ZERO" # 0
    is  "$ABSOLUTE_ZERO"  "0"  "op 'abs' with 0 as the arg"
    
    local ABS_NEG="$(abs -98.6)"
    debug "abs -98.6 -> $ABS_NEG" # 98.6
    is  "$ABS_NEG"  "98.6"  "op 'abs' with negative arg"
    
    GT31="$(gt 3 1)"
    is "$GT31"  "'t"  "gt 3 1 -> 't"

    GT12="$(gt  1 2)"
    is "$GT12"  "nil"  "gt 1 2 -> nil"
    
    end
}


# Standard operations defined in Scheme

# >op.gt,
# append
# apply
# begin
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
