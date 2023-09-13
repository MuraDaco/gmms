#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

# **** Start script
echo_start_script
# **** Start script

echo_dbg_clrd 1 33 "git_foreach_storage:    $git_foreach_storage"
echo_dbg_clrd 1 33 "git_foreach_machine:    $git_foreach_machine"
echo_dbg_clrd 1 33 "git_foreach_address:    $git_foreach_address"
echo_dbg_clrd 1 33 "git_foreach_repogroup:  $git_foreach_repogroup"

{
    [ -d .git ] || \
    [ -f .git ]
} || {
    echo_chk_clrd 1 31 "ERROR - ($PWD) the current command \"`basename $0`\" must be executed in a \"root git\" folder (a folder which contains a \".git\" folder or \".git\" file)"
    echo_clrd_exit 1 34 1
}

group="$git_foreach_repogroup"
[ "$git_foreach_storage" == "default" ] && git_foreach_storage=
[ "$git_foreach_machine"  == "default" ] && git_foreach_machine=
{
    [ "$1" = "reporemotepath" ] ||
    [ "$1" = "url" ]
} && {
    [ "$sm_path" ] || {
        echo_chk_clrd 1 31  "No \"sm_path\" parameter (sub module path) set"
        echo_clrd_exit 1 34 1
    }
}



[ "$PATH_REPO_MAIN" ] && {

    [ "$1" ] && {
        script_current=$(basename $0)
        git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --name-only --get-regexp parameter.${script_current%.sh} | cut -d. -f3 | grep "^$1$" > /dev/null 2>&1 && {
            echo_dbg_clrd 1 32 "Parameter \"$1\" is OK"
        } || {
            echo_chk_clrd 1 31 "No valid parameter \"$1\" is given"
            echo_clrd_exit 1 34 1
        }
    } || {
        echo_chk_clrd 1 31        "No parameter is given. This command requires one parameter."
        echo_chk_clrd_start 1 33  "The list of available parameters is reported below:"
        git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --name-only --get-regexp parameter | cut -d. -f3 > /dev/stderr
        echo_chk_clrd_end
        echo_clrd_exit 1 34 1
    }

    [ "$git_foreach_storage" ] && {
        storage=$git_foreach_storage

        git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --name-only --get-regexp protocols | grep "\.$storage\." > /dev/null 2>&1 && {

            [ "$git_foreach_machine" ] && {
                machine="$git_foreach_machine"
            } || {
                machine=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-all protocols.$storage.default)
            }
             
            [ "$1" = "machine" ] && echo $machine

            [ "$1" = "uuid" ] && {
                storage_uuid=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-all mount.$storage.uuid) && {
                    echo $storage_uuid
                } || {
                    echo_dbg_clrd 1 31        "Warning - No valid uuid for \"$storage\" remote storage"
                    echo_clrd_exit 1 34 1
                }
            }

            protocol=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-all protocols.$storage.$machine) && {

                [ "$1" = "protocol" ] && echo $protocol

                mount_tmp=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-all mount.$storage.$machine)

                mount=${mount_tmp%/__NO_REPOGROUP_PATH__*}
                [ "$mount" != "$mount_tmp" ] && {
                    remote_group="/"
                }

                # eval is necessary when mount is equal to $HOME
                eval eval_mount="$mount"

                [ "$1" = "mount" ] && echo $eval_mount

                {
                    [ "$group" ] ||
                    group=$(git        config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get     submodule.$sm_path.repogroup ) 
                } && {

                    module_name=$(basename "$sm_path")
                    [ "$1" = "group" ] && echo $group

                    [ "/" != "$remote_group" ] && {
                        remote_group=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES"         --get-all repogroup.$group.path) && {
                            echo_dbg_clrd 1 33 "remote_group: $remote_group"
                            true
                        } || {
                            echo_chk_clrd 1 31  "No valid \"group\" parameter \"$group\""
                            echo_chk_clrd_start 1 33 "Available values are:"
                            git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --name-only --get-regexp repogroup | cut -d. -f2 | uniq  > /dev/stderr
                            echo_chk_clrd_end
                            echo_clrd_exit 1 34 1
                        }
                    }

                    [ "$1" = "reporemotepath" ] && echo "$eval_mount$remote_group$module_name.git"
                    [ "$1" = "groupremotepath" ] && echo "$eval_mount$remote_group"

                    true
                } || {
                    echo_chk_clrd 1 33  "repogroup: \"$group\""
                    echo_chk_clrd 1 31  "No valid \"sm_path\" git variable (\"$sm_path\") or \"repogroup\" variable is not properly configured for \"$sm_path\" submodule"
                }

                [ "$git_foreach_address" ] && {
                    address_nick="$git_foreach_address"
                    address=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-all net.$machine.$address_nick) || {
                        echo_chk_clrd 1 31 "No valid \"address\" parameter: \"$address_nick\" does not match with \"$machine\" machine or does not exist"
        
                        git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --name-only --get-regexp net | grep "\.$machine\." > /dev/null 2>&1 && {
                            echo_chk_clrd_start 1 33 "Available values are:"
                            git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --name-only --get-regexp net | grep "\.$machine\." | cut -d. -f3 > /dev/stderr
                            echo_chk_clrd_end
                            echo_clrd_exit 1 34 1
                        } || {
                            echo_chk_clrd_start 1 33 "No address value is available to match \"$machine\" machine"
                            echo_chk_clrd_start 1 33 "No address parameter is necessary for \"$machine\" machine"
                            echo_chk_clrd_end
                        }

                    }

                } || {
                    address_nick=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-all net.$machine.default)
                    [ "$address_nick" ] && {
                        address=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-all net.$machine.$address_nick)
                    } || address=
                }
                # echo "net: $net"

                echo_dbg_clrd 1 33 "protocol:     $protocol"
                echo_dbg_clrd 1 33 "eval_mount:   $eval_mount"
                echo_dbg_clrd 1 33 "remote_group: $remote_group"

                [ "$1" = "url" ]        && echo "$protocol$address$eval_mount$remote_group$module_name.git"
                [ "$1" = "urlgroup" ]   && echo "$protocol$address$eval_mount$remote_group"
                [ "$1" = "address" ]    && echo "$protocol$address"
                true
                
            } || {
                echo_chk_clrd 1 31  "No valid \"machine\" parameter: \"$machine\" does not match with \"$storage\" storage or does not exist"
                echo_chk_clrd_start 1 33 "Available values are:"
                git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --name-only --get-regexp protocols | grep "\.$storage\." | cut -d. -f3  > /dev/stderr
                echo_chk_clrd_end
                echo_clrd_exit 1 34 1
            }

        } || {
            echo_chk_clrd 1 31 "ERROR - No valid \"storage\" parameter (\"$storage\") is given"
            echo_chk_clrd_start 1 33 "Available values are:"
            git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --name-only --get-regexp protocols | grep "^protocols\." | cut -d. -f2 | uniq  > /dev/stderr
            echo_chk_clrd_end
            echo_clrd_exit 1 34 1
        }


    } || {
        echo_chk_clrd 1 31 "ERROR - No \"storage\" parameter is given, please set it."
        echo_chk_clrd_start 1 33 "Available values are:"
        git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --name-only --get-regexp protocols | grep "^protocols\." | cut -d. -f2 | uniq  > /dev/stderr
        echo_chk_clrd_end
        echo_clrd_exit 1 34 1
    }
} || {
    echo_chk_clrd 1 31 "ERROR - \"PATH_REPO_MAIN\" variable is not defined"
    echo_clrd_exit 1 34 1
}

# **** End   script
echo_end_script
# **** End   script
