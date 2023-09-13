#!/bin/bash


function echo_chk_clrd {
    echo -e "\033[$1;$2m""dbg msg on stderr -> $3""\033[0;0m" > /dev/stderr
}

function echo_clrd {
    echo -e "\033[$1;$2m""$3""\033[0;0m"
}

function echo_chk_clrd_start {
    echo -e "\033[$1;$2m""$3" > /dev/stderr
}

function echo_chk_clrd_end {
    echo -e "\033[0;0m" > /dev/stderr
}

echo
echo_chk_clrd 1 33 "Executing: \"`basename $0`\" script"
echo_chk_clrd 1 35 "**** START script ************"
echo

function submodule_param_set {

    {
        [ -d ".git" ] ||
        [ -f ".git" ]
    } && {
        [ -d ".git" ] && {
            export sm_path=$(basename "$PWD")
            echo "toplevel:           NOT NECESSARY - the module set is the main module \"$sm_path\""
            echo "sm_path:            $sm_path"
        }
        true
        [ -f ".git" ] && {
            parent_module_name=$(
                cd ..
                worktree=$(git config --get core.worktree) && {
                    basename "$worktree"
                } || {
                    basename "$PWD"
                }
            )
            echo "parent_module_name: $parent_module_name"
            export toplevel=${PWD%/$parent_module_name*}/$parent_module_name
            export sm_path=${PWD##*/$parent_module_name/}
            echo "toplevel:           $toplevel"
            echo "sm_path:            $sm_path"
        }
        true
    } || {
        echo_chk_clrd 1 31 "ERROR - the path exists but it is not a \".git\" folder"
        parent_module_name=$(basename `git config --get core.worktree`)
        toplevel=${PWD%/$parent_module_name*}/$parent_module_name
        partial_path=${PWD##*/$parent_module_name/}
        echo_chk_clrd_start 1 33 "An available list of possible module for the given \"-m\" option is reported below:"
        git config --name-only --get-regexp submodule | grep "$partial_path" | cut -d. -f2 | uniq 
        echo_chk_clrd_end
        exit 1
    }

}

case "$1" in
    --module | -m)
        shift
        cd "$1" && {
            submodule_param_set
        } || {
            echo_chk_clrd 1 31 "ERROR - No valid submodule path is given: the folder does not exist"

            parent_module_name=$(basename `git config --get core.worktree`)
            toplevel=${PWD%/$parent_module_name*}/$parent_module_name
            partial_path=${PWD##*/$parent_module_name/}

            echo_chk_clrd_start 1 33 "An available list of possible module for the current path (\"$PWD\", where this script was launched) is reported below:"
            git config --name-only --get-regexp submodule | grep "$partial_path" | cut -d. -f2 | uniq
            echo_chk_clrd_end

            exit 1
        }
        shift
    ;;
    *)
        submodule_param_set
        echo
    ;;
esac

git_sub_repo_remote_cmd.sh $1

echo
echo_chk_clrd 1 34 "**** END   script ************"
echo_chk_clrd 1 36 "Ending:    \"`basename $0`\" script"
echo
