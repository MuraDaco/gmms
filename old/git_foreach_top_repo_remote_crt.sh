#!/bin/bash

function echo_chk_clrd {
    echo -e "\033[$1;$2m""dbg msg on stderr -> $3""\033[0;0m" > /dev/stderr
}

echo
echo_chk_clrd 1 33 "Executing: \"`basename $0`\" script"
echo_chk_clrd 1 35 "**** START script ************"
echo

git submodule foreach --recursive "{
    git_sub_repo_remote_crt.sh 
}"

echo
echo_chk_clrd 1 34 "**** END   script ************"
echo_chk_clrd 1 36 "Ending:    \"`basename $0`\" script"
echo
