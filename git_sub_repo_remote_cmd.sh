#!/bin/bash 


## # ********************************************************
## function echo_dbg_clrd {
##     [ $option_d -eq 1 ] && echo -e "\033[$1;$2m""dbg msg -> $3""\033[0;0m" > /dev/stderr || [ true ]
## }
## 
## # ********************************************************
## function echo_chk_clrd {
##     echo -e "\033[$1;$2m""dbg msg on stderr -> $3""\033[0;0m" > /dev/stderr
## }


source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh


# ********************************************************
function read_answer {
    while IFS= read -r answer
    do
        [ "$answer" == "$1" ] || [ "$answer" == "$2" ] && break
    done < /dev/stdin
}

# ********************************************************
function    wait_n_go   {
    echo_chk_clrd 1 33 "$1"
    echo_chk_clrd 1 33 "waiting your choice ... -> [yes | no]"
    read_answer "yes" "no"
    [ "$answer" == "no" ] && {
        exit 0
    }
}


# ********************************************************
# ********************************************************

echo_chk_clrd 1 33 "Executing: \"`basename $0`\" script"

cmd=$1
git_sub_repo_remote_url_chk.sh && {


    export git_foreach_storage=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onstorage)
    export git_foreach_machine=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onmachine)
    export git_foreach_address=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onrouter )

    protocol=$(repo_sub_storage_param_get.sh protocol) && {
        [ "$protocol" = "ssh://" ]  && {
            address=$(repo_sub_storage_param_get.sh address) && {

                ssh "$address" exit && {
                    echo_chk_clrd 1 32 "ssh OK"

                    mount=$(repo_sub_storage_param_get.sh mount)

	                reporemotepath=$(repo_sub_storage_param_get.sh reporemotepath)
	                group=$(repo_sub_storage_param_get.sh group)
	                groupremotepath=$(repo_sub_storage_param_get.sh groupremotepath)

                    ssh $address "bash -s" << EOF

                        # ********************************************************
                        function echo_chk_clrd {
                            echo -e "\033[\$1;\$2m""dbg msg on stderr -> \$3""\033[0;0m" > /dev/stderr
                        }

                        # ********************************************************
                        # ********************************************************

                        [ -d "$mount" ] && {
                            echo_chk_clrd 1 32 "OK - remote storage mounting folder is ready"

                            lsblk | grep "$mount" > /dev/null 2>&1 && {
                                echo_chk_clrd 1 32 "Partition \"$mount\" is already mounted"

                                [ -d "$reporemotepath" ] && {
                                    echo_chk_clrd 1 32 "OK - \"$reporemotepath\" folder exists"
                                    exit 2
                                } || {
                                    echo_chk_clrd 1 31 "WARNING - \"$reporemotepath\" does not exists"
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

                        echo_chk_clrd 1 33 "Ending the \"git remote repo\" procedure"

                        true
EOF
                    result=$?
                    echo_chk_clrd 1 33 "Command: $cmd"

                    {
                        [ "$cmd" = "del" ] && 
                        [ $result -eq 2 ]
                    } && {
                        wait_n_go "Do you want to remove the git remote repo \"$reporemotepath\"?"

                        [ "$answer" == "yes" ] && {
                            echo_chk_clrd 1 33 "Deleting git remote repo"

                            ssh $address "bash -s" << EOF
                                rm -rf "$reporemotepath"
                                pwd
                                cd `dirname "$reporemotepath"`
                                pwd
                                ls -al
                                exit 0
EOF
                            result=$?
                        }
                    }


                    {
                        [ "$cmd" = "crt" ] && 
                        [ $result -eq 3 ]
                    } && {
                        wait_n_go "Do you want to create the git remote repo \"$reporemotepath\"?"

                        [ "$answer" == "yes" ] && {
                            echo_chk_clrd 1 33 "Creating git remote repo"

                            ssh $address "bash -s" << EOF
                                mkdir -p "$reporemotepath" && {
                                    cd "$reporemotepath"
                                    git init --bare && {
                                        cd ..
                                        pwd
                                        ls -al
                                        cd `basename "$reporemotepath"`
                                        pwd
                                        ls -al
                                        exit 4
                                    }
                                }
EOF
                            result=$?
                        }
                    }

                    {
                        [ $result -eq 4 ] ||
                        [ $result -eq 2 ]
                    } && {
                        wait_n_go "Do you want to \"git push\" to the git remote repo of \"$sm_path\" module?"

                        [ "$answer" == "yes" ] && {
                            git push
                        }
                    }
                }
            }
        }
    }
}

echo
echo "****************"
echo
echo_chk_clrd 1 36 "Ending:    \"`basename $0`\" script"


