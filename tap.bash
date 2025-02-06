#!/opt/homebrew/bin/bash

PLANNED=0        
FAILS=0
WINS=0
        
TEST_NUMBER=1

function tap_bail {
    local REASON="$2"
    if [[ "$REASON" ]]; then
        REASON=" $REASON"
        techo "Bail out!${REASON}"
        return 1
    fi
}

function skip {
    local N="$1"
    local REASON="$2"
    if [[ "$REASON" ]]; then
        REASON=" $REASON"
    fi
    
    local LAST="$(($TEST_NUMBER + N))"
    while true; do
        if [[ "$TEST_NUMBER" -gt "$LAST" ]]; then
            return
        else
            techo "ok $TEST_NUMBER - # SKIP${REASON}"
            ((WINS+=1))
            ((TEST_NUMBER+=1))
        fi
    done
}   

function techo {
    echo "$@" >/dev/stderr
}

function ok {
    local BOOL="$1"
    local DESC="$2"
    
    local OK_P
    if [[ "$BOOL" -eq 0 ]]; then
        OK_P="ok"
        ((WINS += 1))
    else
        OK_P="not ok"
        ((FAILS += 1))
    fi

    if [[ "$DESC" ]]; then
        DESC=" - $DESC"
    fi
    
    techo "$OK_P ${TEST_NUMBER}${DESC}"
    ((TEST_NUMBER += 1))
}

function is {
    local GOT="$1"
    local EXPECTED="$2"
    local DESC="$3"
    
    if [[ "$DESC" ]]; then
        DESC=" - $DESC"
    fi
    
    local OKNOTOK DIAG
    if [[ "$GOT" = "$EXPECTED" ]]; then
        OKNOTOK="ok"
        ((WINS += 1))
    else
        OKNOTOK="not ok"
        ((FAILS += 1))
        DIAG=" (got $GOT, expected $EXPECTED)"
    fi
      
    techo "$OKNOTOK ${TEST_NUMBER}${DESC}${DIAG}"
    ((TEST_NUMBER += 1))
}

function plan {
    PLANNED="$1"
    techo "1..$PLANNED"

    FAILS=0
    WINS=0    
    TEST_NUMBER=1
}

function end {
    local TOTAL="$((FAILS + WINS))"
    if [[ "$TOTAL" -ne "$PLANNED" ]]; then
        techo "warning: planned $PLANNED tests but ran $TOTAL"
        return 1
    elif [[ "$FAILS" -gt 0 ]]; then
        techo "$WINS/$PLANNED tests failed"
        return 1
    else
        techo "all tests succeeded"
        return 0
    fi
}

function tap_example_1 {
    plan 4

    true; ok $? "that which is true is true"
    false; ok $? "polar bears are marsupials"
    is "$((2 + 2))" 5 "2+2 = 5"
    is "$((2 + 2))" 4 "2+2 = 4"
    
    end
}

function tap_example_2 {
    plan 3
    
    ok true "ran test 1"
    ok true "ran test 2"
    
    if false; then
        ok "ran test 3"
    fi
    
    end
}

# tap_example_1
# techo
# tap_example_2
