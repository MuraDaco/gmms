#!/bin/bash 

## option_d=0
## [ "$1" = -d ] && {
##     shift
##     option_d=1
## }
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

[ "$1" ] && {
    script_current=$(basename $0)
    git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --name-only --get-regexp parameter.${script_current%.sh} | cut -d. -f3 | grep "^$1$" > /dev/null 2>&1 && {
        echo_dbg_clrd 1 32 "Parameter \"$1\" is OK"
    } || {
        echo_chk_clrd 1 31 "No valid parameter \"$1\" is given"
        exit 1
    }
}

address=$(repo_sub_storage_param_get.sh address)

echo_dbg_clrd 1 33 "address: $address"
ssh -o ConnectTimeout=2 "$address" exit && {

    [ "$1" = "testconnection" ] && {
        echo_dbg_clrd 1 32 "ssh OK"
        exit 0
    }
    mount=$(repo_sub_storage_param_get.sh mount)
    [ "$1" = "crt" ] && {
    	reporemotepath=$(repo_sub_storage_param_get.sh reporemotepath) || {
            exit 1
        }
    }

    [ "$1" = "shutdown" ] && {
        echo_dbg_clrd 1 32 "Shuttingdown \"$address\" machine"
        bash -c "ssh $address sudo shutdown -h 0"
    }

	group=$(repo_sub_storage_param_get.sh group)
	groupremotepath=$(repo_sub_storage_param_get.sh groupremotepath)
    ssh $address "bash -s" << EOF

        # ********************************************************
        function echo_chk_clrd {
            echo -e "\033[\$1;\$2m""dbg msg on stderr -> \$3""\033[0;0m" > /dev/stderr
        }


        # ********************************************************
        function echo_dbg_clrd {
            [ $option_d -eq 1 ] && {
                echo -e "\033[\$1;\$2m""dbg msg -> \$3""\033[0;0m" > /dev/stderr 
            }
            true
        }

        # ********************************************************
        # ********************************************************
        [ -d "$mount" ] && {
            echo_dbg_clrd 1 32 "OK - remote storage mounting folder is ready"
            {
                lsblk | grep "$mount" > /dev/null 2>&1 || mount "$mount" 
            } && {

                [ "$1" = "teststoragemount" ] && {
                    echo_dbg_clrd 1 32 "remote storage partition is mounted"
                    exit 0
                }

                [ "$1" = "umount" ] && {
                    umount "$mount" && {
                        echo_dbg_clrd 1 32 "remote storage partition \"$mount\" is UNmounted"
                        exit 0
                    } || {
                        echo_dbg_clrd 1 32 "ERROR - unmounting remote storage partition \"$mount\" is failed "
                        exit 1
                    }
                }

                [ "$1" = "crt" ] && {
                    echo_dbg_clrd 1 31 "Executing command \"crt\""
                #    mkdir -p "$reporemotepath" && {
                #        cd "$reporemotepath"
                #        git init --bare && {
                #            cd ..
                #            pwd
                #            ls -al
                #            cd `basename "$reporemotepath"`
                #            pwd
                #            ls -al
                #            exit 4
                #        }
                #    }

                }

                echo_dbg_clrd 1 32 "Partition \"$mount\" is already mounted"
                [ -d "$groupremotepath" ] && {
                    echo_dbg_clrd 1 32 "OK - \"$groupremotepath\" folder exists"

                    [ "$1" = "lsrepogroup" ] && {
                        cd "$groupremotepath"
                        find . -name "*.git" -type d -maxdepth 1 | sort | cut -d/ -f2
                        exit 0
                    }
                    true
                } || {
                    echo_chk_clrd 1 31 "WARNING - \"$groupremotepath\" does not exists"
                    exit 3
                }


            } || {
                echo_chk_clrd 1 31 "ERROR - Partition \"$mount\" is not mounted yet"
                exit 1
            }
        } || {
            echo_chk_clrd 1 31 "ERROR - remote storage mounting folder does not exists"
            exit 1
        }
        echo_dbg_clrd 1 33 "Ending the \"git remote repo\" procedure"
        true
EOF
    exit $?
} || {
    echo_chk_clrd 1 31 "ssh connection unavailable"
    exit 1
}
