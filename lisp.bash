#!/opt/homebrew/bin/bash

function debug {
    local MESSAGE="$@"
    local -a LINES
    IFS=$'\n' read -d "" -ra LINES <<< "$MESSAGE"
    
    if [[ -n "$DEBUG_LISP_DOT_BASH" ]]; then
        for LINE in "${LINES[@]}"; do
            echo "[debug] $LINE" >/dev/stderr
        done
    fi
}

function main {
    if [[ $# -ne 1 ]]; then
        echo "Wrong number of arguments. Usage: lisp.bash 'lisp code'" \
             >/dev/stderr
        exit 1
    fi

    local LISP_CODE="$1"
    local TOKENS="$(lx "$LISP_CODE")"
#   debug "function lx returned
#$TOKENS"
}

function lx {
    local CODE="$1"
    
    debug "Lisp code:
<$CODE>"
    
    # Pad parens with spaces, so they'll be treated as separate tokens.
    for CHAR in '(' \
                ')'
    do
        CODE="${CODE//${CHAR}/ ${CHAR} }"
    done
    debug "Code with parens space-padded:
<$CODE>"

    # Turn each chunk of 1 or more whitespace chars into a single ' '.
    # It's a hack, but Bash doesn't do regex substitution, so we need it.
    read -ra TEMPARR <<< "$CODE"
    CODE="${TEMPARR[*]}"
    debug "Code with whitespace normalized:
<$CODE>"

    # Define an output token separator that won't be used in the
    # input Lisp.    
    # ASCII has a chacter for just such a purpose:
    # local SEP=$'\x1F'
    # But it's not printable, which makes print-style debugging hard.
    # So just use newline.
    # local SEP=$'\n'
    local SEP='|'
    
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
