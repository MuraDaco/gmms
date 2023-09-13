#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_echo_selection.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

# ********************************************************
function reset_fetch_config {
    git config --replace-all remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
}

# ********************************************************
function add_fetch_config {
    git config --add remote.origin.fetch "+refs/heads/$1:refs/remotes/origin/$1"
}

# ********************************************************
function set_fetch_on_config {

    echo_dbg
    branch_current=$(git symbolic-ref --short -q HEAD) && {
        echo_dbg_clrd 1 32 "Current branch is: $branch_current (\"$1\" module)"
        fetch_current=$(git config --get-all remote.origin.fetch) && {
            fetch_branch=${fetch_current#*/origin/}
            [ "$branch_current" = "$fetch_branch" ] && {
                echo_dbg_clrd 1 32 "OK - current branch is properly configured in fetch parameter"
                echo_dbg_clrd 1 32 "current branch:      \"$branch_current\""
                echo_dbg_clrd 1 32 "remote.origin.fetch: \"$fetch_current\""
            } || {
                echo_dbg_clrd 1 31 "WARNING - fetch parameter contains a branch different from current one"
                echo_dbg_clrd 1 31 "current branch:      \"$branch_current\""
                echo_dbg_clrd 1 31 "fetch   branch:      \"$fetch_branch\""
                echo_dbg_clrd 1 31 "remote.origin.fetch: \"$fetch_current\""
            }
        } || {
            echo_dbg_clrd 1 33 "Setting ... fetch parameter for \"$branch_current\" branch"
            git config --replace-all remote.origin.fetch +refs/heads/$branch_current:refs/remotes/origin/$branch_current            
        }

    } || {
        echo_dbg_clrd 1 31 "Module \"$1\" in DETACHED MODE"
    }
    echo_dbg
    echo_dbg_clrd 1 33 "-------------- (module: $sm_path) (module path: $toplevel/$sm_path)"

}

# ********************************************************
function branch_checkout_forced {

    echo_dbg
    # check weather branch exists
    git branch | cut -c3- | grep "^$2$" && {
        # branch exists
        # perform the checkout
        # echo_dbg_clrd 1 33 "Branch exists so Peforming checkout" && {
        git checkout $2 && {
            echo_dbg_clrd 1 32 "Checkout of \"$2\" branch has been succesfully performed"
        } || {
            echo_dbg_clrd 1 31 "ERROR in checkout of \"$2\" branch procedure"
        }
    } || {
        # branch does not exist
        # create the branch and then perform the checkout
        # echo_dbg_clrd 1 33 "CREATING branch and then Peforming checkout" && {
        git checkout -b $2 && {
            echo_dbg_clrd 1 32 "Creation & Checkout of \"$2\" branch has been succesfully performed"
        } || {
            echo_dbg_clrd 1 31 "ERROR in checkout of \"$2\" branch procedure"
        }
    }
    echo_dbg
    echo_dbg_clrd 1 33 "--------------"

}

function branch_checkout_only {

    echo_dbg
    # check weather branch exists
    git branch | cut -c3- | grep "^$2$" && {
        # branch exists
        # echo_dbg_clrd 1 33 "Peforming checkout ONLY" && {
        git checkout $2 && {
            echo_dbg_clrd 1 32 "Checkout of \"$2\" branch has been succesfully performed"
        } || {
            echo_dbg_clrd 1 31 "ERROR in checkout of \"$2\" branch procedure"
            exit 1
        }
    } || {
        # branch does not exist
        # create the branch and then perform the checkout
        echo_dbg_clrd 1 31 "Branch \"$2\" does not exist"
    }
    echo_dbg
    echo_dbg_clrd 1 33 "--------------"

}

function branch_status_compare {

    branch_current=$(git symbolic-ref --short -q HEAD) && {
        case "$branch_current" in
            "$2")
                echo_dbg_clrd 1 32 "Owner: Current branch is: $branch_current (\"$1\" module)"
            ;;
            "main")
                echo_dbg_clrd 1 33 "Main:  Current branch is: $branch_current (\"$1\" module)"
            ;;
            *)
                echo_dbg_clrd 1 35 "Other: Current branch is: $branch_current (\"$1\" module)"
            ;;
        esac 
    } || {
        echo_dbg_clrd 1 31 "Module \"$1\" in DETACHED MODE"
    }

}

function checkout_branch {

    echo_dbg
    git checkout $2 && {
        branch_current=$(git symbolic-ref --short -q HEAD) && {
            echo_dbg_clrd 1 32 "Current branch is: $branch_current (\"$1\" module)"
        } || {
            echo_dbg_clrd 1 31 "Module \"$1\" in DETACHED MODE"
        }
    }
    echo_dbg
    echo_dbg_clrd 1 33 "--------------"

}

# ********************************************************
function check_branch_status {

    echo_dbg
    branch_current=$(git symbolic-ref --short -q HEAD) && {
        echo_dbg_clrd 1 32 "Current branch is: $branch_current (\"$1\" module)"
    } || {
        echo_dbg_clrd 1 31 "Module \"$1\" in DETACHED MODE"
    }
    echo_dbg
    echo_dbg_clrd 1 33 "--------------"

}

# ********************************************************
function update_url_childs_submodule {

    export sm_path=$1
    export git_foreach_storage=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get "submodule.$1.onstorage")
    export git_foreach_machine=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get "submodule.$1.onmachine")
    export git_foreach_router=$( git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get "submodule.$1.onrouter")

    echo_dbg_clrd 1 33 "sm_path:                $sm_path"
    echo_dbg_clrd 1 33 "git_foreach_onstorage:  $git_foreach_storage"
    echo_dbg_clrd 1 33 "git_foreach_onmachine:  $git_foreach_machine"
    echo_dbg_clrd 1 33 "git_foreach_onrouter:   $git_foreach_router"

    echo

    while IFS= read -r item; do
        {
            git config -f ".gitmodules" --get "submodule.$item.url" > /dev/null &&
            [ -d "$item" ]
        } && {
            submodule_list+=("$item")
        } || {
            echo_dbg_clrd 1 31 "WARNING - The \"$item\" module is not properly configured as submodule: its section in \".gitmodules \" file or its working dir or both do not exist"
        }
    done < <(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp "submodule" | grep "^submodule.*.parent $1$" | cut -d'.' -f2)

    echo

    for item in "${submodule_list[@]}";
    do
        echo
        echo_dbg_clrd 1 33 "Updating submodule \"$item\" url (PWD: $PWD)"

        [ ! -f "$item/.git" ] && {

            echo
            export sm_path=$item
            module_url_new=$(repo_sub_storage_param_get.sh -d url)

            echo_chk_clrd 1 31 "Do you want to modify the url of the \"$item\" submodule?"
            echo_chk_clrd 1 31 "Note: module_url_new -> $module_url_new"
            list_values=$( 
                echo "Yes:     -> OK, performing url update..."
                echo "No:      -> nothing will be done, the submdoule url will be left inhalterd"
            )
            selecting_option              "choice_sel"
            choice_sel=${choice_sel%:*}
            echo_chk_clrd 1 33 "Selected: $choice_sel"

            [ "$choice_sel" = "Yes" ] && {
                echo_chk_clrd 1 33 "module_url_new: $module_url_new"
                git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --replace-all "submodule.$sm_path.onstorage" "$git_foreach_storage"
                git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --replace-all "submodule.$sm_path.onmachine" "$git_foreach_machine"
                git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --replace-all "submodule.$sm_path.onrouter"  "$git_foreach_router"              
                git config -f ".gitmodules"                                --replace-all "submodule.$sm_path.url"       "$module_url_new"
            } || {
                echo_chk_clrd 1 33 "JUMP TO NEXT submodule"
            }

            true
        } || {
            echo_chk_clrd 1 33 "Warning - The \"$item\" submodule is already initialized, cloned and absorbed therefore you must use another cmd to update its url"
        }

        echo
        echo_chk_clrd 1 32 "-----------------------"
        echo

    done

    echo 
}

# ********************************************************
function remove_submodule_and_its_childs {

    echo_dbg_clrd 1 33 "Removing child submodule section"
    while IFS= read -r item; do
        echo_dbg_clrd 1 33 "Removing submodule \"$item\""
        remove_submodule_and_its_childs $item
    done < <(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp "submodule" | grep "^submodule.*.parent $1$" | cut -d'.' -f2)

    echo_dbg_clrd 1 33 "Removing header submodule section"
    echo_dbg_clrd 1 33 "After recursion (removing $1 module)"
    git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --remove submodule.$1 && {
        echo_chk_clrd 1 32 "OK - Section of submodule \"$1\" is properly removed"
    }

}


# ********************************************************
function list_submodule_and_its_childs {

    echo_dbg_clrd 1 33 "Removing child submodule section"
    [ "$echo_item" ] && echo "$1" || echo_item="yes"
    while IFS= read -r item; do
        echo_dbg_clrd 1 33 "Removing submodule \"$item\""
        list_submodule_and_its_childs $item
    done < <(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp "submodule" | grep "^submodule.*.parent $1$" | cut -d'.' -f2)

    echo_dbg_clrd 1 33 "Removing header submodule section"
    echo_dbg_clrd 1 33 "After recursion (removing $1 module)"

}

# ********************************************************
function list_submodule_and_its_parents {
    [ "$rec" ] || {
        path_abs="$1"
        rec=0
    }
    # get parent module
    parent_repogroup=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$1.parent) && {

        [ "$parent_repogroup" != "__ROOT__" ] && {
            echo "$path_abs" | grep "/$parent_module/" > /dev/null 2>&1 && {
                echo_chk_clrd 1 31       "ERROR - A loop between submodule has been revealed \"$path_abs\" vs \"$parent_module\""
                exit 1
            }
            path_abs="$parent_module/$path_abs"
            list_submodule_and_its_parents "$parent_module"
        }
        true
    } || {
        echo_chk_clrd 1 31       "No valid \"parent\" in submodule section of \"$1\" module in \"remote_device_modules\" file"
        exit 1
    }
    echo $1
}

# ********************************************************
function list_submodule_and_its_childs_gitignore {
    
            start_item=$1
            toplevel=$2
            sm_path=$3
            echo_dbg_clrd 1 33 "start_item: $start_item"
            echo_dbg_clrd 1 33 "toplevel:   $toplevel"
            echo_dbg_clrd 1 33 "sm_path:    $sm_path"
            modify=0
            while IFS= read -r item; do
                [ "$start_item" = "$item" ] && modify=1
                [ $modify -gt 0 ] && {
                    
                    [ ! "$sm_path" = "$item" ] && {

                        sm_path_abs_item=${toplevel%$item*}/$item
                        cd $sm_path_abs_item && {

                            echo_dbg_clrd 1 34 "starting from \"$item\" module for adding its section"
                            echo_dbg_clrd 1 34 "PWD: $PWD"

                            export SECTION_MARK_START="# ____ Start ____ $item"
                            export SECTION_MARK_END="# ____ End   ____ $item"
                            [ -f ".gitignore_modules" ] && {
                                echo_dbg_clrd 1 32 "OK - .gitignore_modules file exists"
                                export FILE_GITIGNORE="$PWD/.gitignore_modules"
                            } || {
                                echo_dbg_clrd 1 33 "WARNING - (PWD: $PWD) .gitignore_modules file does not exist"
                                export FILE_GITIGNORE=
                            }

                            echo_dbg_clrd 1 32 "SECTION_MARK_START: $SECTION_MARK_START"
                            echo_dbg_clrd 1 32 "SECTION_MARK_END:   $SECTION_MARK_END"
                            echo_dbg_clrd 1 32 "FILE_GITIGNORE:     $FILE_GITIGNORE"

                            cd $toplevel/$sm_path && {
                                echo_dbg_clrd 1 32 "PWD: $PWD"
                                echo_dbg_clrd 1 32 "toplevel:           $toplevel"
                                echo_dbg_clrd 1 32 "sm_path:            $sm_path"
                                git_sub_gitignore_delete_section.sh  -d
                                git_sub_gitignore_create_section.sh  -d
                                git_sub_gitignore_add.sh             -d
                            }

                        }
                    }
                    true
                }
            done < <(list_submodule_and_its_parents $sm_path)

}

function get_sm_path {
    [ ! "$1" = "$PATH_REPO_MAIN" ] && {
        folder_up=$(dirname "$1")
        {
            [ -d "$folder_up/.git" ] ||
            [ -f "$folder_up/.git" ]
        } && {
            echo ${2#$folder_up/}
        } || {
            get_sm_path "$folder_up" "$2"
        }
    } || {
        echo_dbg_clrd 1 32 "$PATH_REPO_MAIN"
        exit 1
    }
}

function get_toplevel {
    [ ! "$1" = "$PATH_REPO_MAIN" ] && {
        folder_up=$(dirname "$1")
        {
            [ -d "$folder_up/.git" ] ||
            [ -f "$folder_up/.git" ]
        } && echo $folder_up || get_toplevel "$folder_up"
    } || {
        exit 1
    }
}

[ "$1" ] && {
    cmd=$1
    shift
}

[ "$cmd" = "childlist" ] &&
{

    # ********************************************************
    list_submodule_and_its_childs "$1"

}

[ "$cmd" = "parentlist" ] &&
{

    # ********************************************************
    list_submodule_and_its_parents "$1"

}

[ "$cmd" = "getsmpath" ] &&
{

    # ********************************************************
    get_sm_path "$1" "$1"

}

[ "$cmd" = "gettoplevel" ] &&
{

    # ********************************************************
    get_toplevel "$1"

}

[ "$cmd" = "remove" ] &&
{
    [ "$1" ] && {
        module_to_remove=$1
        shift
    }

    # ********************************************************
    remove_submodule_and_its_childs "$module_to_remove"

}


[ "$cmd" = "seturldeinit" ] &&
{
    [ "$1" ] && {
        parent_module=$1
        shift
    }

    # ********************************************************
    update_url_childs_submodule "$parent_module"

}


[ "$cmd" = "branchstatus" ] &&
{
    [ "$1" ] && {
        module_to_check=$1
        shift
    }

    check_branch_status "$module_to_check"

}

[ "$cmd" = "checkout" ] &&
{
    [ "$1" ] && {
        module_to_checkout=$1
        shift
        branch_to_checkout=$1
        shift
    }

    checkout_branch "$module_to_checkout" "$branch_to_checkout"

}

[ "$cmd" = "checkout_forced" ] &&
{
    [ "$1" ] && {
        module_to_checkout=$1
        shift
        branch_to_checkout=$1
        shift
    }

    branch_checkout_forced "$module_to_checkout" "$branch_to_checkout"

}

[ "$cmd" = "checkout_only" ] &&
{
    [ "$1" ] && {
        module_to_checkout=$1
        shift
        branch_to_checkout=$1
        shift
    }

    branch_checkout_only "$module_to_checkout" "$branch_to_checkout"

}


[ "$cmd" = "branch_status_compare" ] &&
{
    [ "$1" ] && {
        module_to_checkout=$1
        shift
        branch_owner=$1
        shift
    }

    branch_status_compare "$module_to_checkout" "$branch_owner"

}



[ "$cmd" = "gitignore" ] &&
{
    [ "$1" ] && {
        start_module=$1
        shift
        target_sm_path=$1
    }

    # ********************************************************
    target_sm_path_abs=$(func_module_path_abs.sh "$target_sm_path")
    target_toplevel=${target_sm_path_abs%/$target_sm_path}
    list_submodule_and_its_childs_gitignore  "$start_module" "$target_toplevel" "$target_sm_path"

}

[ "$cmd" = "configfetch" ] &&
{
    [ "$1" ] && {
        module_to_check=$1
        shift
    }

    set_fetch_on_config "$module_to_check"

}

[ "$cmd" = "config_reset_ref_fetch" ] &&
{
    [ "$1" ] && {
        module_to_modify=$1
        shift
    }

    reset_fetch_config "$module_to_modify"

}

[ "$cmd" = "config_add_ref_fetch" ] &&
{
    [ "$1" ] && {
        branch_to_set=$1
        shift
        add_fetch_config "$branch_to_set"
    }


}

true
