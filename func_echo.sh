option_d=0
[ "$1" = -d ] && {
    shift
    option_d=1
}

option_e=0
[ "$1" = -e ] && {
    shift
    option_e=1
}

# ********************************************************
function echo_dbg {
    [ $option_d -eq 1 ] && echo > /dev/stderr || true
}

# ********************************************************
function echo_chk {
    echo > /dev/stderr
}

# ********************************************************
function echo_dbg_clrd {
    [ $option_d -eq 1 ] && {
        echo -e "\033[$1;$2m""dbg msg - `basename $0` -> $3""\033[0;0m" > /dev/stderr 
    }
    true
}

# ********************************************************
function echo_chk_clrd {
    echo -e "\033[$1;$2m""dbg msg - `basename $0` -> $3""\033[0;0m" > /dev/stderr
}

# ********************************************************
function echo_clrd {
    echo -e "\033[$1;$2m""$3""\033[0;0m"
}

# ********************************************************
function echo_clrd_exit {
    [ $option_e -eq 1 ] && {
        echo > /dev/stderr
        echo -e "\033[1;35m"" =========================== \"`basename $0`\" script""\033[0;0m" > /dev/stderr
        echo > /dev/stderr
    }
    exit $3
}

# ********************************************************
function echo_end {
    [ $option_e -eq 1 ] && {
        echo > /dev/stderr
    }
}

# ********************************************************
function echo_clrd_2 {
    echo -e "\033[$1;$2m""$3""\033[$4;$5m""$6""\033[0;0m"
}

# ********************************************************
function echo_chk_clrd_start {
    echo -e "\033[$1;$2m""$3" > /dev/stderr
}

# ********************************************************
function echo_chk_clrd_end {
    echo -e "\033[0;0m" > /dev/stderr
}

function echo_start_script {
    echo_dbg
    echo_dbg_clrd 1 34 "**** START script ************ \"`basename $0`\" script - $1"
    echo_dbg
}

function echo_end_script {
    echo
    echo_dbg_clrd 1 35 "**** END   script ************ \"`basename $0`\" script - $1"
    echo
}
