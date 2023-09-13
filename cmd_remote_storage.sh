#!/bin/bash 

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh


# ********************************************************
# ********************************************************

# **** Start script
echo_start_script
# **** Start script


[ "$1" ] && {
    script_current=$(basename $0)
    git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --name-only --get-regexp parameter.${script_current%.sh} | cut -d. -f3 | grep "^$1$" > /dev/null 2>&1 && {
        echo_dbg_clrd 1 32 "Parameter \"$1\" is OK"
        cmd=$1
        shift
    } || {
        echo_chk_clrd 1 31 "No valid parameter \"$1\" is given"
        echo_clrd_exit 1 34 1
    }
}

    mount=$(repo_sub_storage_param_get.sh mount)
	group=$(repo_sub_storage_param_get.sh group)
	groupremotepath=$(repo_sub_storage_param_get.sh groupremotepath)
    storage_uuid=$(repo_sub_storage_param_get.sh uuid)
    remote_repo_path="$groupremotepath$1"
    [ "$cmd" = "newremote" ] && remote_repo_name=$1
    [ "$cmd" = "chkremoterepopath" ] && reporemotepath=$(repo_sub_storage_param_get.sh reporemotepath)

    echo_dbg_clrd 1 33 "storage_uuid: $storage_uuid"

    protocol=$(repo_sub_storage_param_get.sh protocol) && {
        [ "$protocol" = "ssh://" ]  && {
            address=$(repo_sub_storage_param_get.sh address) && {

                ssh -o ConnectTimeout=2 "$address" exit && {
                    echo_chk_clrd 1 32 "ssh OK"
                    ssh $address "bash -s" -- < $PATH_REPO_MAIN_SCRP_DIR/cmd_remote_storage_common.sh -d "cmd=$cmd" "mount=$mount" "group=$group" "groupremotepath=$groupremotepath" "storage_uuid=$storage_uuid" "remote_repo_path=$remote_repo_path" "remote_repo_name=$remote_repo_name" "reporemotepath=$reporemotepath"
                }
                exit $?
            }
        }

        {
            [ "$protocol" = "file://" ] || 
            [ "$protocol" = "file:/" ]  
        } && {
            cmd_remote_storage_common.sh -d "cmd=$cmd" "mount=$mount" "group=$group" "groupremotepath=$groupremotepath" "storage_uuid=$storage_uuid" "remote_repo_path=$remote_repo_path" "remote_repo_name=$remote_repo_name" "reporemotepath=$reporemotepath"
            exit $?
        }
    }


# **** End   script
echo_end_script
# **** End   script

true