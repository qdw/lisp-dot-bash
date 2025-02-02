#!/opt/homebrew/bin/bash

function main {
    if [[ $# -ne 1 ]]; then
        echo "Wrong number of arguments. Usage: lisp.bash 'lisp code'" \
             >/dev/stderr
        exit 1
    fi

    local LISP_CODE="$1"
    lx "$LISP_CODE"
    
    # TOKENS="$(lx "$LISP_CODE")"
    # echo "$TOKENS"
    
    # or maybe...
    
    # function parse {
    #     local EXPR="$1"
    #     local IFS=' ()'
    #     local -a TOKES
    #     read -ra TOKES <<< "$EXPR"
    # }

    # while true; do
    #     TOKEN_REST="$(pop "$EXPR")"
    #     OUTPUT=$(evl 
    #     read -a TOKEN <<< "$TOKENS"
}

function lx {
    local CODE="$1"
    local -a TOKENS
    read -ra TOKENS <<< "$CODE"
    
    # Pad parens with spaces so that they'll be treated as separate tokens...
    for CHAR in '(' \
                ')'
    do
        CODE="${CODE//${CHAR}/ ${CHAR} }"
    done
    
    # Read whitespace-separated tokens into an array
        
    
    # CODE="${CODE//^${SEP}/}"
    # CODE="${CODE//${SEP}$/}" 
    



    # Define an output token separator that won't be used in the
    # input Lisp.
    
    # ASCII has a chacter for just such a purpose:
    # local SEP=$'\x1F'
    # But it's not printable, which makes print-style debugging hard.
    # So just use newline.
    # local SEP=$'\n'
    local SEP='|'
    
    # Replace each sequence of whitespace(s) with the separator char.
    CODE="${CODE//+[[:space:]]/${SEP}}"
    
    # # B
    
    No, I want it to replace each sequence of whitespace chars with a 

    printf "$CODE"
}

main "$@"
