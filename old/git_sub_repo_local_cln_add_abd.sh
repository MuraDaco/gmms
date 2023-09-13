#!/bin/bash

option_d=0
[ "$1" = -d ] && {
    shift
    option_d=1
}

# ********************************************************
function echo_dbg_clrd {
    [ $option_d -eq 1 ] && {
        echo -e "\033[$1;$2m""dbg msg -> $3""\033[0;0m" > /dev/stderr 
    }
    true
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

# **** Start script
echo_dbg_clrd 1 33 "Executing: \"`basename $0`\" script"
echo_dbg_clrd 1 35 "**** START script ************"
echo


[ "$2" ] && {

    { 
        [ -d ".git" ] || \
        [ -f ".git" ] 
    } && {
        echo_dbg_clrd "OK - Now the \"$2\" new submodule will be created"
        echo
        mkdir -p "$2"
        ( 
            cd "$2"
            cd ..
            git clone "$1"
        )

        git submodule add "$1" "$2"
        git submodule absorbgitdirs "$2"
        true

    } || {
        echo_chk_clrd "ERROR - you are not in the \"git root\" dir"
        exit 1
    }

} || {

    echo_chk_clrd 1 31 "No valid parameters have been given"
    echo
    echo_chk_clrd 1 33 "how to use this command"
    echo
    echo_chk_clrd 1 33 "# launch the following command under the git root directory of the \"super-project\"/\"parent module\""
    echo_chk_clrd 1 33 "\$ `basename $0` <url> <path>"
    echo_chk_clrd 1 33 "# for example:"
    echo_chk_clrd 1 33 "\$ `basename $0`  \"file:///Users/work/ObsiDataRemote/Year_2023_2/repo__prjs/repo_test_3.git\" \"modules/repo_test_3\""
    echo
    exit 1
}


# **** End script
echo
echo_dbg_clrd 1 34 "**** END   script ************"
echo_dbg_clrd 1 36 "Ending:    \"`basename $0`\" script"
echo

