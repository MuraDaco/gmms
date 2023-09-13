#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

exit_status=0

option_x=0
[ "$1" = -x ] && {
    shift
    option_x=1
}

source $PATH_REPO_MAIN_SCRP_DIR/func_echo_selection.sh


# ********************************************************
# ********************************************************
# **** Start script
echo_start_script
# **** Start script


    # check the current url 
    export git_foreach_storage=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onstorage)
    export git_foreach_machine=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onmachine)
    export git_foreach_address=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onrouter )

    group=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.repogroup )

    remote_repo_current_composed=$(repo_sub_storage_param_get.sh url)
    remote_repo_current_config=$(git config --get-all remote.origin.url)

    echo_dbg
    echo_dbg_clrd 1 33 "current \"origin\" repo url in module \"config\" file:        $remote_repo_current_config"

    [ "$remote_repo_current_composed" = "$remote_repo_current_config" ] && {
        echo_dbg
        echo_dbg_clrd 1 32 "OK - \"composed\" from \"remote_device_modules\" file info"
    } || {
        echo_dbg
        echo_chk_clrd 1 31 "repo url located in \"config\" file DIFFERS from that composed by \"remote_device_modules\" file info"
        echo_chk_clrd 1 31 "remote_repo_current_composed:  $remote_repo_current_composed"
        echo_chk_clrd 1 31 "remote_repo_current_config:    $remote_repo_current_config"

        exit_status=1

    }


    [ ! "$group" = "__MAIN_GROUP__" ] && {

        url_on_parent_gitmodules=$(git config -f $toplevel/.gitmodules --get-all submodule."$sm_path".url)
        url_on_parent_config=$(
            cd $toplevel
            git config --get-all submodule."$sm_path".url
        )

        [ "$remote_repo_current_config" = "$url_on_parent_gitmodules" ] && {
            echo_dbg_clrd 1 32 "OK - on url_on_parent_gitmodules"
        } || {
            echo_chk_clrd 1 31 "ERROR - on url_on_parent_gitmodules"
            ## echo_clrd_exit 1 35 1
            exit_status=1
        }

        [ "$remote_repo_current_config" = "$url_on_parent_config" ] && {
            echo_dbg_clrd 1 32 "OK - on url_on_parent_config"
        } || {
            echo_chk_clrd 1 31 "ERROR - on url_on_parent_config"
            ## echo_clrd_exit 1 35 1
            exit_status=1
        }

    }

# **** End   script
echo_end_script
# **** End   script

[ $exit_status -eq 1 ] && {

    # question
    [ $option_x -eq 1 ] && {
        echo_chk_clrd 1 33 "How do you want the current check script ended?"
        list_values=$( 
            echo "Exit 0: ending as normal"
            echo "Exit 1: ending with error"
        )
        selecting_option              "choice_sel"
        choice_sel=${choice_sel%:*}
        echo_chk_clrd 1 33 "Selected: $choice_sel"
        [ "$choice_sel" = "Exit 0" ] && exit 0
        [ "$choice_sel" = "Exit 1" ] && exit 1
    }

}

true