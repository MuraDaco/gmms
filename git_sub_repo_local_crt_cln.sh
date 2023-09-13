#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

# **** Start script
echo_start_script
# **** Start script

[ "$1" ] && {
    script_current=$(basename $0)
    git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --name-only --get-regexp parameter.${script_current%.sh} | cut -d. -f3 | grep "^$1$" > /dev/null 2>&1 && {
        echo_dbg_clrd 1 32 "Parameter \"$1\" is OK"
        cmd="$1"
        shift
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


[ "$2" ] && {

    # creating
    { 
        [ -d ".git" ] || \
        [ -f ".git" ] 
    } && {

        {
            [ "$cmd" = "new" ] ||
            [ "$cmd" = "genericnew" ] 
        } && {

            echo_dbg_clrd 1 32 "OK - Now the \"$2\" new submodule will be created"
            echo
            mkdir -p "$2"
            ( 
                cd "$2"
                git init
            )
            [ "$cmd" = "new" ]         && {
                repo_sync_tmpl_dir.sh "$2"
                repo_sync_scrp_dir.sh "$2"
            }
            [ "$cmd" = "genericnew" ] && repo_sync_tmpl_dir_2.sh "$2"
            ( 
                cd "$2"
                [ -d .git ] && {
                    git add .
                    git commit -m "First commit"
                    git remote add origin "$1"
                }
            )
        }

        [ "$cmd" = "clone" ] && {

            echo_dbg_clrd 1 32 "OK - Now the \"$2\" new submodule will be created"
            echo
            mkdir -p "$2"
            ( 
                cd "$2"
                cd ..
                git clone "$1"
            )

            # check if repo cloned is empty
            repo_log=$(cd "$2" && git log --pretty=oneline --graph --decorate --all) && {
                [ "$repo_log" ] && {
                    echo_dbg_clrd 1 33 "The first two  line of \"git log --pretty=oneline ... \" command"
                    echo_dbg_clrd 1 33 `echo $repo_log | head -2`
                } || {
                    # an empty remote repo has been cloned
                    echo_chk_clrd 1 31 "ERROR - you want to clone an empty remote repo"
                    rm -rf "${2%%/*}"
                    echo_clrd_exit 1 34 1
                }
            }   
        }

        {
            [ "$cmd" = "new"   ]       ||
            [ "$cmd" = "genericnew" ] ||
            [ "$cmd" = "clone" ]
        } && {

            git submodule add "$1" "$2"
            git submodule absorbgitdirs "$2"

            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.onstorage "$storage_sel"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.onmachine "$protocol_sel"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.onrouter  "$address_sel"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.repogroup "$repogroup_sel"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.parent    "$module_parent_sel"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.storage   "$storage_sel"
        }

        {
            [ "$cmd" = "addabsorb"   ]
        } && {

            origin_url=$(
                cd $2
                git config --get remote.origin.url
            )

            echo_dbg_clrd 1 33 "url:                $1"
            echo_dbg_clrd 1 33 "toplevel:           $PWD"
            echo_dbg_clrd 1 33 "sm_path:            $2"
            echo_dbg_clrd 1 33 "origin_url:         $origin_url"
            echo_dbg_clrd 1 33 "----------------------"
            echo_dbg_clrd 1 33 "storage_sel:        $storage_sel"
            echo_dbg_clrd 1 33 "protocol_sel:       $protocol_sel"
            echo_dbg_clrd 1 33 "address_sel:        $address_sel"
            echo_dbg_clrd 1 33 "repogroup_sel:      $repogroup_sel"
            echo_dbg_clrd 1 33 "module_parent_sel:  $module_parent_sel"
            echo_dbg_clrd 1 33 "storage_sel:        $storage_sel"

            git submodule add "$1" "$2"
            git submodule absorbgitdirs "$2"

            (
                toplevel="$PWD"
                sm_path="$2"
                remote_url="$1"
                cd "$toplevel/$2" && {
                    git config --replace-all remote.origin.url "$remote_url"
                }
                cd "$toplevel" && {
                    git config -f ".gitmodules" --replace-all submodule.$sm_path.url  "$remote_url"
                    git config                  --replace-all submodule.$sm_path.url  "$remote_url"
                }

            )

            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.onstorage "$storage_sel"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.onmachine "$protocol_sel"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.onrouter  "$address_sel"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.repogroup "$repogroup_sel"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.parent    "$module_parent_sel"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.originurl "$origin_url"
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --add submodule.$sm_path.storage   "$storage_sel"
        }

        true

    } || {
        echo_chk_clrd "ERROR - you are not in the \"git root\" dir"
        echo_clrd_exit 1 34 1
    }

} || {

    echo_chk_clrd 1 31 "No valid parameters have been given"
    echo
    echo_chk_clrd 1 33 "how to use this command"
    echo
    echo_chk_clrd 1 33 "# launch the following command under the git root directory of the \"super-project\"/\"parent module\""
    echo_chk_clrd 1 33 "\$ `basename $0` <url> <path>"
    echo_chk_clrd 1 33 "# for example:"
    echo_chk_clrd 1 33 "\$ `basename $0`  \"file:///Users/work/ObsiDataRemote/Year_2023_2/repo__prjs/repo_test_3.git\" \"modules/repo_test_3\""
    echo
    echo_clrd_exit 1 34 1
}


# **** End   script
echo_end_script
# **** End   script
