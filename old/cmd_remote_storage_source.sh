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
## 
## # ********************************************************
## function echo_dbg {
##     [ $option_d -eq 1 ] && echo > /dev/stderr || true
## }

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

# ********************************************************
# ********************************************************

# **** Start script
echo_dbg
echo_dbg_clrd 1 35 "**** START script ************"
echo_dbg_clrd 1 33 "Executing: \"`basename $0`\" script"
echo_dbg

[ "$1" ] && {
    script_current=$(basename $0)
    git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --name-only --get-regexp parameter.${script_current%.sh} | cut -d. -f3 | grep "^$1$" > /dev/null 2>&1 && {
        echo_dbg_clrd 1 32 "Parameter \"$1\" is OK"
        cmd=$1
        shift
    } || {
        echo_chk_clrd 1 31 "No valid parameter \"$1\" is given"
        exit 1
    }
}


    mount=$(repo_sub_storage_param_get.sh mount)
	group=$(repo_sub_storage_param_get.sh group)
	groupremotepath=$(repo_sub_storage_param_get.sh groupremotepath)
    storage_uuid=$(repo_sub_storage_param_get.sh uuid)

    remote_repo_path="$groupremotepath$1"

    [ "$cmd" = "chkremoterepopath" ] && reporemotepath=$(repo_sub_storage_param_get.sh reporemotepath)

    echo_dbg_clrd 1 33 "storage_uuid: $storage_uuid"

    protocol=$(repo_sub_storage_param_get.sh protocol) && {
        [ "$protocol" = "ssh://" ]  && {
            address=$(repo_sub_storage_param_get.sh address) && {

                ssh -o ConnectTimeout=2 "$address" exit && {
                    echo_chk_clrd 1 32 "ssh OK"


                    ssh $address "bash -s" << EOF

                        # ********************************************************
                        function echo_dbg_clrd {
                            [ $option_d -eq 1 ] && {
                                echo -e "\033[\$1;\$2m""dbg msg -> \$3""\033[0;0m" > /dev/stderr 
                            }
                            true
                        }

                        # ********************************************************
                        function echo_chk_clrd {
                            echo -e "\033[\$1;\$2m""dbg msg on stderr -> \$3""\033[0;0m" > /dev/stderr
                        }

                        # ********************************************************
                        # ********************************************************

                        [ -d "$mount" ] && {
                            echo_chk_clrd 1 32 "OK - remote storage mounting folder is ready"

                            [ -L "/dev/disk/by-uuid/$storage_uuid" ] && {
                                echo_dbg_clrd 1 32 "Partition \"$mount\" is attached"

                                [ -d "$groupremotepath" ] && {

                                    [ "$cmd" = "lsrepogroup" ] && {
                                        cd "$groupremotepath"
                                        find . -name "*.git" -type d -maxdepth 1 | sort | cut -d/ -f2
                                        exit 0
                                    }

                                    [ "$cmd" = "newremote" ] && {
                                        cd "$groupremotepath" && {
                                            mkdir "$1" && {
                                                cd "$1"
                                                git init --bare
                                            }
                                        }
                                    }

                                    [ "$cmd" = "chkremoterepopath" ] && {
                                        [ -d "$reporemotepath" ] || {
                                            echo_chk_clrd 1 31 "ERROR - Remote repository directroy (\"$reporemotepath\") does not exists"
                                            exit 3
                                        }
                                    }


                                    [ "$cmd" = "removeremoterepo" ] && (
                                        [ -d "$remote_repo_path" ] && {
                                        
                                            cd "$remote_repo_path"
                                            [ `git config --get core.bare` ] && {
                                                echo_dbg_clrd 1 32 "OK - Remote repository directroy (\"$remote_repo_path\") is a proper git \"bare\" repository"
                                            } || {
                                                echo_chk_clrd 1 31 "ERROR - Remote repository directroy (\"$remote_repo_path\") does not appear as a git \"bare\" repository"
                                                exit 1
                                            }
                                        } || {
                                            echo_chk_clrd 1 31 "ERROR - Remote repository directroy (\"$remote_repo_path\") does not exists"
                                            exit 1
                                        }
                                    )

                                    true

                                } || {
                                    echo_chk_clrd 1 31 "ERROR - \"$groupremotepath\" does not exists"
                                    exit 3
                                }
                            } || {
                                echo_chk_clrd 1 31 "ERROR - Partition \"$mount\" is not attached yet"
                                exit 1
                            }
                        } || {
                            echo_chk_clrd 1 31 "ERROR - remote storage mounting folder does not exists"
                            exit 1
                        }

                        echo_chk_clrd 1 33 "Ending the \"git remote repo\" procedure"

                        true
EOF
                }
                exit $?
            }
        }

        {
            [ "$protocol" = "file://" ] || 
            [ "$protocol" = "file:/" ]  
        } && {
            [ -d "$mount" ] || {
                echo_chk_clrd 1 31 "ERROR - Partition \"$mount\" is not attached yet"
                exit 2
            }

            [ -d "$groupremotepath" ] && {

                [ "$cmd" = "lsrepogroup" ] && (
                    cd "$groupremotepath"
                    find . -name "*.git" -type d -maxdepth 1 | sort | cut -d/ -f2
                )

                [ "$cmd" = "newremote" ] && {
                    cd "$groupremotepath" && {
                        mkdir "$1" && {
                            cd "$1"
                            git init --bare
                        }
                    }
                }

                [ "$cmd" = "chkremoterepopath" ] && {
                    [ -d "$reporemotepath" ] || {
                        echo_chk_clrd 1 31 "ERROR - Remote repository directroy (\"$reporemotepath\") does not exists"
                        exit 3
                    }
                }

                [ "$cmd" = "removeremoterepo" ] && (
                    [ -d "$remote_repo_path" ] && {

                        cd "$remote_repo_path"
                        [ `git config --get core.bare` ] && {
                            echo_dbg_clrd 1 32 "OK - Remote repository directroy (\"$remote_repo_path\") is a proper git \"bare\" repository"
                        } || {
                            echo_chk_clrd 1 31 "ERROR - Remote repository directroy (\"$remote_repo_path\") does not appear as a git \"bare\" repository"
                            exit 1
                        }
                    } || {
                        echo_chk_clrd 1 31 "ERROR - Remote repository directroy (\"$remote_repo_path\") does not exists"
                        exit 1
                    }
                )
                
                true
            } || {
                echo_chk_clrd 1 31 "ERROR - \"$groupremotepath\" does not exists"
                exit 3
            }

        }
    }


# **** End   script
echo
echo_dbg_clrd 1 36 "Ending:    \"`basename $0`\" script"
echo_dbg_clrd 1 34 "**** END   script ************"
echo

true