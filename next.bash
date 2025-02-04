function add {
    local ACC=0
    for ARG in "$@"; do
        ACC=$((ACC + ARG))
    done

    echo "$ACC"
}
        
function apply {
    local OP="$1"
    shift
    local -a ARGS=("$@")
    
    local ACC=0
    for ARG in ${ARGS[@]}; do
        ACC=$((ACC OP ARG))
    done
    
    echo "$ACC"
}

function execute {
    local OP="$1"
    shift
    local -a ARGS=("$@")

    case "$OP" in
        '+')
            add ${ARGS[@]}
            ;;
        
        '-'|'*'|'/')
            apply "$OP" "${ARGS[@]}"
            ;;
        
        *)
            echo "Unsupported operation '$OP'" >/dev/stderr
            return 1
            ;;
    esac
}

function read_tokens {
    local -a STACK=("$@")
    
    # INT_PATTERN="[[:digit:]]+"
    
    while read -r TOKEN; do
        if [[ "$TOKEN" = "(" ]]; then
            read_tokens ${STACK[@]}
        elif [[ "$TOKEN" = ")" ]]; then
            echo "$STACK"
            OP="$(car ${STACK[@]})"
            local -a ARGS="$(cdr ${STACK[@]})"
            execute "$OP" ${STACK[@]}
        else
            STACK+="$TOKEN"
            read_tokens "$STACK"

    
    if [[ $EXPR =~ "$INT_PATTERN" ]]; then
        echo evl "$EXPR" "$STACK[*]"
}
