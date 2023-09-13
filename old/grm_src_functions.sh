# ------------------------------
# ****** _____ FUNCTIONS SECTION

function echo_dbg {
    [ $option_d -eq 1 ] && echo "dbg msg -> $1" > /dev/stderr || [ true ]
}

function echo_dbg_clrd {
    [ $option_d -eq 1 ] && echo -e "\033[$1;$2m""dbg msg -> $3""\033[0;0m" > /dev/stderr || [ true ]
}

function echo_chk_clrd {
    echo -e "\033[$1;$2m""dbg msg on stderr -> $3""\033[0;0m" > /dev/stderr
}

function echo_clrd {
    echo -e "\033[$1;$2m""$3""\033[0;0m"
}

function echo_chk_clrd_start {
    echo -e "\033[$1;$2m""$3" > /dev/stderr
}

function echo_chk_clrd_end {
    echo -e "\033[0;0m" > /dev/stderr
}


# ****** END - FUNCTIONS SECTION
# ------------------------------

