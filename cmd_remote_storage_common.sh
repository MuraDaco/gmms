#!/bin/bash 

option_d=0
[ "$1" = -d ] && {
    shift
    option_d=1
}


# ********************************************************
function echo_dbg_clrd {
    [ $option_d -eq 1 ] && {
        echo -e "\033[$1;$2m""dbg msg -> $3""\033[0;0m" > /dev/stderr 
    }
    true
}

# ********************************************************
function echo_chk_clrd {
    echo -e "\033[$1;$2m""dbg msg on stderr -> $3""\033[0;0m" > /dev/stderr
}

cmd=${1#cmd=}
shift
mount=${1#mount=}
shift
group=${1#group=}
shift
groupremotepath=${1#groupremotepath=}
shift
storage_uuid=${1#storage_uuid=}
shift
remote_repo_path=${1#remote_repo_path=}
shift
remote_repo_name=${1#remote_repo_name=}
shift
reporemotepath=${1#reporemotepath=}
shift

# ********************************************************
# ********************************************************

# # **** Start script
# echo_start_script
# # **** Start script


echo_dbg_clrd 1 33 "mount:            $mount            "
echo_dbg_clrd 1 33 "group:            $group            "
echo_dbg_clrd 1 33 "groupremotepath:  $groupremotepath  "
echo_dbg_clrd 1 33 "storage_uuid:     $storage_uuid     "
echo_dbg_clrd 1 33 "remote_repo_path: $remote_repo_path "
echo_dbg_clrd 1 33 "remote_repo_name: $remote_repo_name "
echo_dbg_clrd 1 33 "reporemotepath:   $reporemotepath   "


[ -d "$mount" ] && {
    echo_dbg_clrd 1 32 "OK - remote storage mounting folder is ready"

    {
        {
            [ "$storage_uuid" ] &&
            [ -L "/dev/disk/by-uuid/$storage_uuid" ]    
        } || {
            [ ! "$storage_uuid" ]
        }
    } && {

        echo_dbg_clrd 1 32 "Partition \"$mount\" is attached"

        [ -d "$groupremotepath" ] && {
            echo_dbg_clrd 1 33 "Remote directory of group \"$groupremotepath\" exists"

            [ "$cmd" = "lsrepogroup" ] && {
                echo_dbg_clrd 1 33 "Executing \"$cmd\" remote command ..."
                cd "$groupremotepath"
                find . -name "*.git" -type d -maxdepth 1 | sort | cut -d/ -f2
                exit 0
            }

            [ "$cmd" = "lsrepogroupall" ] && {
                echo_dbg_clrd 1 33 "Executing \"$cmd\" remote command ..."
                cd "$groupremotepath"
                find . -name "*.git" -type d ! '(' -path "*/.git/*" -o -path "$PATH_REPO_MAIN/.git" ')' | sort
                exit 0
            }

            [ "$cmd" = "newremote" ] && {
                echo_dbg_clrd 1 33 "Executing \"$cmd\" remote command ..."
                cd "$groupremotepath" && {
                    git init --bare "$remote_repo_name"
                }
            }

            [ "$cmd" = "chkremoterepopath" ] && {
                echo_dbg_clrd 1 33 "Executing \"$cmd\" remote command ..."
                [ -d "$reporemotepath" ] || {
                    echo_chk_clrd 1 31 "ERROR - Remote repository directroy (\"$reporemotepath\") does not exists"
                    exit 3
                }
            }
    
    
            [ "$cmd" = "removeremoterepo" ] && {
                echo_dbg_clrd 1 33 "Executing \"$cmd\" remote command ..."
                [ -d "$remote_repo_path" ] && {
                
                    cd "$remote_repo_path"
                    [ `git config --get core.bare` ] && {
                        echo_dbg_clrd 1 32 "OK - Remote repository directroy (\"$remote_repo_path\") is a proper git \"bare\" repository and now it will be removed"
                        cd ..
                        rm -rf "$remote_repo_path"
                    } || {
                        echo_chk_clrd 1 31 "ERROR - Remote repository directroy (\"$remote_repo_path\") does not appear as a git \"bare\" repository"
                        exit 1
                    }

                } || {
                    echo_chk_clrd 1 31 "ERROR - Remote repository directroy (\"$remote_repo_path\") does not exists"
                    exit 1
                }
            }
        
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

echo_dbg_clrd 1 33 "Ending the \"git remote repo\" procedure"

# ********************************************************
# ********************************************************

# # **** End   script
# echo_end_script
# # **** End   script


