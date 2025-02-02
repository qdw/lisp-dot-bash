#!/opt/homebrew/bin/bash

# Define an output token separator that won't be used in the
# input Lisp.    
# ASCII has a chacter for just such a purpose:
# local SEP=$'\x1F'
# But it's not printable, which makes print-style debugging hard.
# So just use newline. That way we don't have to change IFS, either.
SEP=$'\n'    


function debug {
    local DBGLVL="${DEBUG_LEVEL_FOR_LISP_DOT_BASH:-0}"
    ### echo "Debug level: $DBGLVL" >/dev/stderr
    if [[ $DBGLVL = 0 ]]; then
        return
    fi

    local CALLER="${FUNCNAME[1]}"
    ### echo "Caller: $CALLER" >/dev/stderr
    local STACK_DEPTH_OF_CALLER=$(( ${#FUNCNAME[@]} - 2 ))
    ### echo "Stack depth of caller: $STACK_DEPTH_OF_CALLER" >/dev/stderr
    if [[ $DBGLVL -ge $STACK_DEPTH_OF_CALLER ]]; then
        ### echo "Debug level $DBGLVL >= $STACK_DEPTH_OF_CALLER (caller's stack depth), so print the debug message" >/dev/stderr
        ### echo "message: '${@[*]}'" >/dev/stderr
        for LINE in "$@"; do
            echo "[debug] $CALLER: $LINE" >/dev/stderr
        done
        echo >/dev/stderr
    else
        :
        ## echo "$DBGLVL < $STACK_DEPTH_OF_CALLER (caller's stack depth), so don't print the debug message" >/dev/stderr
    fi
}

function main {
    if [[ $# -ne 1 ]]; then
        echo "Wrong number of arguments. Usage: lisp.bash 'lisp code'" \
             >/dev/stderr
        exit 1
    fi

    local LISP_CODE="$1"
    debug "Lisp code:" \
          "$LISP_CODE"
    
    local TOKENS="$(lx "$LISP_CODE")"
    debug "The lexer returned the following token-string:" \
          "$TOKENS"

    debug "Parsing..."
    parse <<< "$TOKENS"
}

function lx {
    local CODE="$1"
    
    debug "Lisp code:" \
          "$CODE"
    
    # Pad parens with spaces, so they'll be treated as separate tokens.
    for CHAR in '(' \
                ')'
    do
        CODE="${CODE//${CHAR}/ ${CHAR} }"
    done
    debug "Code with parens space-padded:" \
          "$CODE"

    # Turn each chunk of 1 or more whitespace chars into a single ' '.
    # It's a hack, but Bash doesn't do regex substitution, so we need it.
    read -ra TEMPARR <<< "$CODE"
    CODE="${TEMPARR[*]}"
    debug "Code with whitespace normalized:" \
          "$CODE"

    # Replace each resulting space with the separator character.
    CODE="${CODE// /${SEP}}"

    local CHAR_DESC=""
    if [[ "$SEP" = $'\x1F' ]]; then
        CHAR_DESC="the ASCII data separator character (hex 1F, unprintable"
    else
        CHAR_DESC="char '$SEP'"
    fi
    debug "Tokens separated by $CHAR_DESC:
$CODE"

    echo "$CODE"
}


main "$@"
