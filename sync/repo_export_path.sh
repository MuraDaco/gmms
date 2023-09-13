#!/bin/bash


# ********************************************************
function echo_chk_clrd {
    echo -e "\033[$1;$2m""dbg msg on stderr -> $3""\033[0;0m" > /dev/stderr
}
# ********************************************************
function echo_chk_clrd_start {
    echo -e "\033[$1;$2m""$3" > /dev/stderr
}

# ********************************************************
function echo_chk_clrd_end {
    echo -e "\033[0;0m" > /dev/stderr
}

option_restore=0
option_set=0
[ "$1" = --restore ] && {
    shift
    option_restore=1
} || {
    [ "$1" = --set ] && {
        shift
        option_set=1
    }
}


{
    [ $option_restore -eq 0 ] &&
    [ $option_set -eq 0 ]
} && {
    echo_chk_clrd_start 1 33
    echo "PATH:                         $PATH"
    echo "PATH_ORIGINAL:                $PATH_ORIGINAL"
    echo "PATH_REPO_MAIN:               $PATH_REPO_MAIN"
    echo "FOLDER_SCRP_DIR:              $FOLDER_SCRP_DIR"
    echo "PATH_REPO_MAIN_SCRP_DIR:      $PATH_REPO_MAIN_SCRP_DIR"
    echo "PATH_REPO_MAIN_CONF_OBDASH:   $PATH_REPO_MAIN_CONF_OBDASH"
    echo "PATH_REPO_MAIN_CONF_STORAGES: $PATH_REPO_MAIN_CONF_STORAGES"
    echo "PATH_REPO_MAIN_CONF_SMODULES: $PATH_REPO_MAIN_CONF_SMODULES"
    echo "PATH_REPO_MAIN_CONF_BRANCHES: $PATH_REPO_MAIN_CONF_BRANCHES"
    echo
    echo "Option available: \"--restore\" or \"--set\" "
    echo_chk_clrd_end
}

[ $option_restore -eq 1 ] && {

    [ "$PATH_ORIGINAL" ] && {
        export PATH=$PATH_ORIGINAL
        export PATH_ORIGINAL=""
        export PATH_REPO_MAIN=""
        export FOLDER_SCRP_DIR=""
        export PATH_REPO_MAIN_SCRP_DIR=""
        export PATH_REPO_MAIN_CONF_OBDASH=""
        export PATH_REPO_MAIN_CONF_STORAGES=""
        export PATH_REPO_MAIN_CONF_SMODULES=""
        export PATH_REPO_MAIN_CONF_BRANCHES=""

        echo_chk_clrd_start 1 32 "OK - Original path "
        echo "PATH: \"$PATH\""
        echo "has been restored succesfully."
        echo_chk_clrd_end
    } || {
        echo_chk_clrd 1 31 "ERROR - this command can only be executed after the \"repo_export_path.sh\" one"
    }

}

[ $option_set -eq 1 ] && {

    [ "$PATH_ORIGINAL" ] && {
        echo_chk_clrd 1 31 "WARNING - this command can only be executed once on terminal session or after that you restore the path"
    } || {

        path_pre_obsidata=${PWD%/ObsiData/*}
        path_post_obsidata=${PWD#*/ObsiData/}
        obsidata_subdir=${path_post_obsidata%%/*}
        PATH_REPO_MAIN="$path_pre_obsidata/ObsiData/$obsidata_subdir"
        FOLDER_SCRP_DIR="gmms"
        FOLDER_SCCG_DIR="gmmg"
        PATH_REPO_MAIN_SCRP_DIR="$PATH_REPO_MAIN/$FOLDER_SCRP_DIR"
        PATH_REPO_MAIN_CONF_OBDASH="$PATH_REPO_MAIN_SCRP_DIR/obdash.cfg"
        PATH_REPO_MAIN_CONF_STORAGES="$PATH_REPO_MAIN/$FOLDER_SCCG_DIR/obdash_storages.cfg"
        PATH_REPO_MAIN_CONF_SMODULES="$PATH_REPO_MAIN/$FOLDER_SCCG_DIR/obdash_smodules.cfg"
        PATH_REPO_MAIN_CONF_BRANCHES="$PATH_REPO_MAIN/$FOLDER_SCCG_DIR/obdash_branches.cfg"
        [ -d "$PATH_REPO_MAIN/.git" ] && {
            echo_chk_clrd 1 32 "OK ---- \"$PATH_REPO_MAIN\" is a valid obsi data path"

            export PATH_ORIGINAL=$PATH
            export PATH_REPO_MAIN
            export PATH=$PATH_REPO_MAIN_SCRP_DIR:$PATH
            export FOLDER_SCRP_DIR
            export PATH_REPO_MAIN_SCRP_DIR
            export PATH_REPO_MAIN_CONF_OBDASH
            export PATH_REPO_MAIN_CONF_STORAGES
            export PATH_REPO_MAIN_CONF_SMODULES
            export PATH_REPO_MAIN_CONF_BRANCHES

        } || {
            echo_chk_clrd 1 31 "ERROR - \"$PATH_REPO_MAIN\" is not a valid obsi data path"
        }
    }
}
