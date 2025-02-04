function l {
    cd ~/src/lisp-dot-bash \
        && DEBUG_LEVEL_FOR_LISP_DOT_BASH=2 ./list-operations.bash
}

function t {
    cd ~/src/lisp-dot-bash \
       && DEBUG_LEVEL_FOR_LISP_DOT_BASH=2 ~/src/lisp-dot-bash/lisp.bash "(+  1 2 (*   3 (/ 88 4 )))"
