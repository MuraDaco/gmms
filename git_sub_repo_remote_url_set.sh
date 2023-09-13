#!/bin/bash 

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

option_f=0
[ "$1" = -f ] && {
    shift
    option_f=1
}

# **** Start script
echo_start_script
# **** Start script

{
    [ -n "$1" ] &&
    [ "$1" -eq "$1" ] 2>/dev/null
} && {
    echo_dbg_clrd 1 33 "parameter is a number: \"$1\""
    storage=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-all submodule.$sm_path.storage | sed "$1q;d" ) 
    [ "$storage" ] || {
        echo_chk_clrd 1 33 "NO priority level AVAILABLE - nothing has been done"
        echo_clrd_exit 1 35 1
    }
} || {
    [ "$1" ] && {
        echo_dbg_clrd 1 33 "parameter is a string: \"$1\""
        storage="$1"
        git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-all submodule.$sm_path.storage | grep "^$1$" > /dev/null 2>&1 || {
            [ $option_f -eq 1 ] && {
                git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.storage $storage
            } || {
                echo_chk_clrd 1 31 "NO \"storage\" variable with \"$storage\" value in \"submodule\" section of \"$sm_path\" submodule AVAILABLE "
                echo_clrd_exit 1 35 1
            }
        }
    } || {
        echo_dbg_clrd 1 33 "no parameter is given"
        storage=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-all submodule.$sm_path.storage | sed "1q;d" )
        [ "$storage" ] || {
            echo_chk_clrd 1 31 "NO STORAGE AVAILABLE"
            echo_clrd_exit 1 35 1
        }
    }
}

[ "$storage" ] && {

    func_module_url_chk.sh -d -x && {

        # set new repo url
        export git_foreach_storage=$storage
        export git_foreach_machine="$2"
        export git_foreach_address="$3"
    
        echo_dbg_clrd 1 33 "git_foreach_storage: \"$git_foreach_storage\""
        echo_dbg_clrd 1 33 "git_foreach_machine: \"$git_foreach_machine\""
        echo_dbg_clrd 1 33 "git_foreach_address: \"$git_foreach_address\""

        remote_repo_new=$(repo_sub_storage_param_get.sh url) && {
            # $sm_path checking is already done in the previous script

            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --replace-all submodule.$sm_path.onstorage "$storage"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --replace-all submodule.$sm_path.onmachine "$2"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --replace-all submodule.$sm_path.onrouter  "$3"

            echo_dbg_clrd 1 32 "remote repo url CURRENT      = $remote_repo_new"

            [ -d .git ] && {
                # from "main" (super-super project) git repository
                git config --replace-all remote.origin.url "$remote_repo_new"
            }

            [ -f .git ] && {
                # from "submodule" git repository
                [ "$PWD" = "$toplevel/$sm_path" ] && {

                    (
                        ## git submodule set-url "$sm_path" "$remote_repo_new" 
                        ## the command above does not work with git version 2.24.3 (Apple Git-128)
                        git config --replace-all remote.origin.url "$remote_repo_new"
                        cd "$toplevel"
                        git config -f ".gitmodules" --replace-all submodule.$sm_path.url  "$remote_repo_new"
                        git config                  --replace-all submodule.$sm_path.url  "$remote_repo_new"
                    )
                    url_on_parent_gitmodules=$(git config -f $toplevel/.gitmodules --get-all submodule."$sm_path".url)
                    url_on_parent_config=$(
                        cd $toplevel
                        git config --get-all submodule."$sm_path".url
                    )

                    [ "$remote_repo_new" = "$url_on_parent_gitmodules" ] && {
                        echo_dbg_clrd 1 32 "OK - on url_on_parent_gitmodules"
                        echo_clrd_exit 1 35 0
                    } || {
                        echo_chk_clrd 1 31 "ERROR - on url_on_parent_gitmodules: $url_on_parent_gitmodule"                        
                        echo_clrd_exit 1 35 1                        
                    }

                    [ "$remote_repo_new" = "$url_on_parent_config" ] && {
                        echo_dbg_clrd 1 32 "OK - on url_on_parent_config"
                        echo_clrd_exit 1 35 0
                    } || {
                        echo_chk_clrd 1 31 "ERROR - on url_on_parent_config"
                        echo_clrd_exit 1 35 1
                    }

                }
            }

            url_on_module_config=$(git config --get-all remote.origin.url)

            [ "$remote_repo_new" = "$url_on_module_config" ] && {
                echo_dbg_clrd 1 32 "OK - on url_on_module_config"
                echo_clrd_exit 1 35 0
            } || {
                echo_chk_clrd 1 31 "ERROR - on url_on_module_config"
                echo_clrd_exit 1 35 1
            }
        } || {
            echo_chk_clrd 1 33 "Warning - \"repo_sub_storage_param_get.sh\" exit with error"
            echo_clrd_exit 1 35 1
        }
    } || {
        echo_chk_clrd 1 33 "Warning - \"func_module_url_chk.sh\" exit with error"
        echo_clrd_exit 1 35 1
    }

} || {
     echo_chk_clrd 1 33 "Warning - \"storage\" variable is empty"
     echo_clrd_exit 1 35 1
}

# **** End script
echo_end_script
# **** End script
