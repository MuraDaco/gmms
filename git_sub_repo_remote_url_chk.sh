#!/bin/bash 


## option_d=0
## [ "$1" = -d ] && {
##     shift
##     option_d=1
## }
## 
## # ********************************************************
## function echo_chk_clrd {
##     echo -e "\033[$1;$2m""dbg msg on stderr -> $3""\033[0;0m" > /dev/stderr
## }
## 
## # ********************************************************
## function echo_dbg_clrd {
##     [ $option_d -eq 1 ] && {
##         echo -e "\033[$1;$2m""dbg msg -> $3""\033[0;0m" > /dev/stderr 
##     }
##     true
## }

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

# ********************************************************
# ********************************************************

# **** Start script
echo
echo_dbg_clrd 1 35 "**** START script ************"
echo_dbg_clrd 1 33 "Executing: \"`basename $0`\" script"
echo

[ "$toplevel" ] && cd "$toplevel/$sm_path" ] && {

    # check the current url 
    export git_foreach_storage=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onstorage)
    export git_foreach_machine=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onmachine)
    export git_foreach_address=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onrouter )

    remote_repo_current_composed=$(repo_sub_storage_param_get.sh url)
    remote_repo_current_config=$(git config --get-all remote.origin.url)

    [ "$remote_repo_current_composed" = "$remote_repo_current_config" ] && {
        echo_dbg_clrd 1 32 "repo url located in \"config\" file is equal to that composed by \"remote_device_modules\" file info"
        echo_dbg_clrd 1 33 "current repo url:        $remote_repo_current_composed"
    } || {
        echo_chk_clrd 1 31 "repo url located in \"config\" file DIFFERS from that composed by \"remote_device_modules\" file info"
        echo_chk_clrd 1 31 "remote_repo_current_composed:  $remote_repo_current_composed"
        echo_chk_clrd 1 31 "remote_repo_current_config:    $remote_repo_current_config"
        exit 1
    }

} || {
    echo_chk_clrd 1 31 "ERROR - No valid parent module path (\"toplevel\" variable: $toplevel) or module path (\"sm_path\" variable: $sm_path)"
    exit 1
}


# **** End   script
echo
echo_dbg_clrd 1 36 "Executing: \"`basename $0`\" script"
echo_dbg_clrd 1 34 "**** END   script ************"
echo

true

