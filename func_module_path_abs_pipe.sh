#!/bin/bash

## option_d=0
## [ "$1" = -d ] && {
##     shift
##     option_d=1
## }
## 
## # ********************************************************
## function echo_chk_clrd {
##     echo -e "\033[$1;$2m""chk -> $3""\033[0;0m" > /dev/stderr
## }
## 
## # ********************************************************
## function echo_dbg_clrd {
##     [ $option_d -eq 1 ] && {
##         echo -e "\033[$1;$2m""dbg -> $3""\033[0;0m" > /dev/stderr 
##     }
##     true
## }
## 
## # ********************************************************
## function echo_dbg {
##     [ $option_d -eq 1 ] && echo > /dev/stderr || true
## }

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

# ********************************************************
function module_path_abs {
    [ "$rec" ] || {
        path_abs="$1"
        rec=0
    }
    # get parent module
    parent_repogroup=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$1.parent) && {

        [ "$parent_repogroup" = "__ROOT__" ] && {
            path_abs="${PATH_REPO_MAIN%/$parent_module*}/$path_abs"
            echo "$path_abs" 
            rec=
        } || {
            parent_module=$parent_repogroup
            echo "$path_abs" | grep "/$parent_module/" > /dev/null 2>&1 && {
                echo_chk_clrd 1 31       "ERROR - A loop between submodule has been revealed \"$path_abs\" vs \"$parent_module\""
                exit 1
            }
            path_abs="$parent_module/$path_abs"
            module_path_abs "$parent_module"
        }
    } || {
        echo_chk_clrd 1 31       "No valid \"parent\" in submodule section of \"$1\" module in \"$PATH_REPO_MAIN_CONF_SMODULES\" file"
        exit 1
    }
}

# ********************************************************

[ -p /dev/stdin ] && {
    while IFS= read line; do
        module_path_abs "$line"
    done
}
