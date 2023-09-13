#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh

echo
echo_chk_clrd 1 33 "Executing: \"`basename $0`\" script"
echo_chk_clrd 1 35 "**** START script ************"
echo

func_module_url_chk.sh -d -e

git submodule foreach --recursive "{
    func_module_url_chk.sh -d -e
    true
}"

echo
echo_chk_clrd 1 34 "**** END   script ************"
echo_chk_clrd 1 36 "Ending:    \"`basename $0`\" script"
echo
