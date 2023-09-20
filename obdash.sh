#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_echo_selection.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

PWD_script="$PWD"

function continue_or_exit   {
    echo_chk_clrd 1 31 "2. Check the above list of parameter, then select your choice?"
    list_values=$( 
        echo "Continue: It's all OK      -> perform the commands"
        echo "Exit:     Wrong parameters -> stop di execution of current script"
    )
    selecting_dash_option              "choice_sel"
    choice_sel=${choice_sel%:*}
    echo_chk_clrd 1 33 "Selected: $choice_sel"

    [ "$choice_sel" = "Exit" ] && exit 0
    true
}
	
function recursive_or_not   {
    echo_chk_clrd 1 32 "How do you want to perform the command [Once / Recursively]?"
    list_values=$( 
        echo "Once:        perform the commands in one shot"
        echo "Recursive:   perform the commands recursively"
    )
    selecting_dash_option              "recursive_sel"
    recursive_sel=${recursive_sel%:*}
    echo_chk_clrd 1 33 "Selected: $recursive_sel"
}

function checkout_forcing   {
    echo_chk_clrd 1 32 "Do you want to create the branch if it does not exist?"
    list_values=$( 
        echo "No"
        echo "Yes"
    )
    selecting_dash_option              "branch_creation_sel"
    branch_creation_sel=${branch_creation_sel%:*}
    echo_chk_clrd 1 33 "Selected: $branch_creation_sel"
}

function func_Branch_Info_Summary   {
    # *********************************
    # Info summary
    echo
    echo_chk_clrd 1 34 "Module branch Info"
    [ "$brc_owner" ]            && echo_chk_clrd 1 32 "brc_owner:              $brc_owner"
    [ "$sel_branch" ]           && echo_chk_clrd 1 32 "sel_branch:             $sel_branch"
    [ "$branch_creation_sel" ]  && echo_chk_clrd 1 32 "branch_creation_sel:    $branch_creation_sel"
    
    
    echo
}

function func_Info_Summary  {

    # *********************************
    # Info summary
    echo
    echo_chk_clrd 1 34 "Module info (Selected):"
    [ "$module_parent_sel" ]  && echo_chk_clrd 1 32 "module_parent_sel:  $module_parent_sel"
    [ "$repogroup_sel" ]      && echo_chk_clrd 1 32 "repogroup_sel:      $repogroup_sel"
    echo_chk_clrd 1 34 "Module info (Retrived):"
    [ "$toplevel" ]           && echo_chk_clrd 1 32 "toplevel:           $toplevel"
    [ "$module_path_abs" ]    && echo_chk_clrd 1 32 "module_path_abs:    $module_path_abs"
    [ "$sm_path_abs" ]        && echo_chk_clrd 1 32 "sm_path_abs:        $sm_path_abs"
    [ "$sm_path" ]            && echo_chk_clrd 1 32 "sm_path:            $sm_path"
    [ "$sm_to_init_path" ]    && echo_chk_clrd 1 32 "sm_to_init_path:    $sm_to_init_path"
    
    echo
    echo_chk_clrd 1 34 "URL info (Selected):"
    [ "$storage_sel" ]        && echo_chk_clrd 1 32 "storage_sel  (onstorage):    $storage_sel"
    [ "$protocol_sel" ]       && echo_chk_clrd 1 32 "protocol_sel (onmachine):    $protocol_sel"
    [ "$address_sel" ]        && echo_chk_clrd 1 32 "address_sel  (onrouter):     $address_sel"
    echo_chk_clrd 1 34 "URL info (Retrived):"
    [ "$remote_module_url" ]  && echo_chk_clrd 1 32 "remote_module_url:           $remote_module_url"
    [ "$remote_module_path" ] && echo_chk_clrd 1 32 "remote_module_path:          $remote_module_path"
    [ "$module_remote_name" ] && echo_chk_clrd 1 32 "module_remote_name:          $module_remote_name"

    echo
    [ "$recursive_sel" ] && {
        echo_chk_clrd 1 32 "recursive_sel: $recursive_sel"
        echo
    }
    true
}

function perform_remove_local   {
    echo "$PWD_script/" | grep "$toplevel/$sm_path/" > /dev/null 2>&1 && {
        echo_chk_clrd 1 31 "It is not possible remove the module because the current script is lanched under its directory or its sub-dirs"
    } || {

        (
            cd "$toplevel" && {
                export toplevel
                export sm_path
                git_sub_repo_local_remove.sh
                true
            } || {
                echo_chk_clrd 1 31 "\"$toplevel\" directory does not exist or is not a valid git submodule"
            }
        )

    }
}

function perform_branch_compare_status  {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            cmd_local_module.sh -d branch_status_compare $sm_path $brc_owner
            git branch
            [ "$recursive_sel" = "Recursive" ] && {
                git submodule foreach --recursive "{
                    cmd_local_module.sh -d branch_status_compare \$sm_path $brc_owner
                    git branch
                    true
                }"
            }
        }
    )
}


function perform_branch_checkout    {
    checkout_option="checkout_only"
    [ "$branch_creation_sel" = "Yes" ] && checkout_option="checkout_forced"
    (
        {
            [ -f "$toplevel/$sm_path/.git" ] ||
            [ -d "$toplevel/$sm_path/.git" ]
        } && {
            export toplevel
            export sm_path
            cd "$toplevel/$sm_path"
            cmd_local_module.sh -d $checkout_option $sm_path $sel_branch

            [ "$recursive_sel" = "Recursive" ] && {
                git submodule foreach --recursive "{
                    cmd_local_module.sh -d $checkout_option \"\$sm_path\" \"$sel_branch\"
                    true
                }"
            }
            true
        } || {
            echo_dbg_clrd 1 31 "Module selected (\"$sm_path\") is not valid"
        }
    )
}

function perform_module_status  {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            git_sub_repo_local_cmd.sh -d status

            [ "$recursive_sel" = "Recursive" ] && {
                git submodule foreach --recursive "{
                    git_sub_repo_local_cmd.sh -d status
                }"
            }
        } 
    )
}

function perform_url_check  {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            [ "$recursive_sel" = "Recursive" ] && {
                git_foreach_top_repo_remote_url_chk.sh
            } || {
                func_module_url_chk.sh -d
            }
        }
    )

}

function perform_reference_reset_config   {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path

            echo_dbg
            echo_dbg_clrd 1 33 "--------------"
            cmd_local_module.sh -d config_reset_ref_fetch $sm_path
            [ "$recursive_sel" = "Recursive" ] && {
                git submodule foreach --recursive "{
                    cmd_local_module.sh -d config_reset_ref_fetch \"\$sm_path\"
                    true
                }"
            }
        }
    )
}


function perform_reference_add_branch_config   {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path

            echo_dbg
            echo_dbg_clrd 1 33 "--------------"
            cmd_local_module.sh -d config_add_ref_fetch $sel_branch
            [ "$recursive_sel" = "Recursive" ] && {
                git submodule foreach --recursive "{
                    cmd_local_module.sh -d config_add_ref_fetch \"\$sel_branch\"
                    true
                }"
            }
        }
    )
}


function perform_reference_list_config   {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path

            echo_dbg
            echo_dbg_clrd 1 33 "--------------"
            cmd_local_module.sh -d config_list_ref_fetch 
            [ "$recursive_sel" = "Recursive" ] && {
                git submodule foreach --recursive "{
                    cmd_local_module.sh -d config_list_ref_fetch
                    true
                }"
            }
        }
    )
}


function perform_branch_status  {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            cmd_local_module.sh -d branchstatus $sm_path
            [ "$recursive_sel" = "Recursive" ] && {
                git submodule foreach --recursive "{
                    cmd_local_module.sh -d branchstatus "\$sm_path"
                    true
                }"
            }
        }
    )
}


function get_sm_path    {

    sm_path_abs=${2%/$token_1}
    sm_path=${sm_path_abs#$1/$token_2}

    parent_index=${#module_parent_path_list[@]}

    echo "$parent_index:$sm_path"

    module_parent_path_list+=($sm_path_abs)
    module_parent_path="$sm_path_abs"
}

function init_parsing_module_list   {
    module_parent_path_list=("$1")
    module_parent_path_index=0
    module_parent_path="$1"
    module_previous_path="$1"
    shift
    token_1=$1
    shift
    token_2=$1
    shift
}

function body_parsing_module_list   {
    echo "$item" | grep "$module_previous_path/" > /dev/null && {
        get_sm_path "$module_previous_path" "$item" "Child"
        module_previous_path="$sm_path_abs"
    } || {
        [ "$item" = "$PATH_REPO_MAIN" ] && {
            echo "0:repo__main"
        } || {
            while true
            do
                module_parent_path_list=(${module_parent_path_list[@]/$module_parent_path})
                module_parent_path=${module_parent_path_list[${#module_parent_path_list[@]} - 1]}
                echo "$item" | grep "$module_parent_path/"  > /dev/null && {
                    break
                }
                true
            done
            get_sm_path "$module_parent_path" "$item" "Other"
            module_previous_path="$sm_path_abs"
        }
    }
}

function add_level_to_module    {

    [ -p /dev/stdin ] && {
        init_parsing_module_list $1
        while IFS= read item; do
            body_parsing_module_list
        done
    }

}

function clean_module_abs_path_source_working_dir    {
    [ -p /dev/stdin ] && {
        while IFS= read line; do
            echo "${line%/.git}"
        done
    }
}

function get_module_abs_path_working_dir    {
    find "$PATH_REPO_MAIN" -type f -name ".git" ! '(' -path "*/.git/*" -o -path "$PATH_REPO_MAIN/.git" ')' | sort
}

function get_module_from_working_dir_2    {
    #get_module_abs_path_working_dir | clean_module_abs_path_source_working_dir | add_level_to_module "$PATH_REPO_MAIN"
    get_module_abs_path_working_dir | clean_module_abs_path_source_working_dir | add_level_to_module "$1"
}

function get_module_from_working_dir    {

    init_parsing_module_list $1 ".git"
    while IFS= read -r item; do
        body_parsing_module_list
    done < <(find "$PATH_REPO_MAIN" -type f -name ".git" ! '(' -path "*/.git/*" -o -path "$PATH_REPO_MAIN/.git" ')' | sort)

}

## function get_module_abs_path_working_dir    {
##     (
##         cd "$PATH_REPO_MAIN"
##         git submodule foreach --recursive "pwd" | grep "^/" | sort
##     )
## }

function get_module_from_git_foreach    {

    init_parsing_module_list $1
    while IFS= read -r item; do
        body_parsing_module_list
    done < <(
            cd "$PATH_REPO_MAIN"
            echo "$PATH_REPO_MAIN"
            git submodule foreach --recursive "pwd" | grep "^/" | sort
        )

}

function get_module_from_config_file    {
    git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp submodule | \
        grep ".repogroup" | cut -d. -f2 | func_module_path_abs_pipe.sh | sort | add_level_to_module "$1"
}

## function get_module_from_config_file    {
## 
##     init_parsing_module_list $1
##     while IFS= read -r item; do
##         body_parsing_module_list
##     done < <(
##             git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp submodule | \
##             grep ".repogroup" | cut -d. -f2 | func_module_path_abs_pipe.sh | sort
##         )
## 
## }

function get_module_from_dot_git_dir    {

    init_parsing_module_list $1 "config" "modules/"
    while IFS= read -r item; do
        body_parsing_module_list
    done < <(find .git/modules -type f -name config | sort)

}


function create_list_module_std_source_cfgfile    {
    echo_chk_clrd 1 33 "Waiting please ... Creating module list via config file"
    module_list_std=$(
        get_module_from_config_file "$PATH_REPO_MAIN"
    )
}

function create_list_module_std_source_foreach    {
    echo_chk_clrd 1 33 "Waiting please ... Creating module list via foreach"
    module_list_std=$(
        get_module_from_git_foreach "$PATH_REPO_MAIN"
    )
}

function create_list_module_std_source_dot_git    {
    echo_chk_clrd 1 33 "Waiting please ... Creating module list via .git folder"
    module_list_std=$(
        get_module_from_dot_git_dir ".git"
    )
}

function create_list_module_std_source_working    {
    echo_chk_clrd 1 33 "Waiting please ... Creating module list via working folder"
    module_list_std=$(
        get_module_from_working_dir_2 "$PATH_REPO_MAIN"
    )
}

function create_list_module_union {
    echo_chk_clrd 1 33 "Waiting please ... Creating module list union"
    module_list_std=$(
        { 
            echo "$module_list_via_config_file"
            echo "$module_list_via_git_foreach"
            echo "$module_list_via_find_dot_git"
            echo "$module_list_via_find_working"
        } | cat | sort | uniq
    )
}

function create_list_module_source_cfgfile    {
    echo_chk_clrd 1 33 "Waiting please ... Creating module list via config file"
    module_list_via_config_file=$(
        get_module_from_config_file "$PATH_REPO_MAIN"
    )
}

function create_list_module_source_foreach    {
    echo_chk_clrd 1 33 "Waiting please ... Creating module list via foreach"
    module_list_via_git_foreach=$(
        get_module_from_git_foreach "$PATH_REPO_MAIN"
    )
}

function create_list_module_source_dot_git    {
    echo_chk_clrd 1 33 "Waiting please ... Creating module list via .git folder"
    module_list_via_find_dot_git=$(
        get_module_from_dot_git_dir ".git"
    )
}

function create_list_module_source_working    {
    echo_chk_clrd 1 33 "Waiting please ... Creating module list via working folder"
    module_list_via_find_working=$(
        get_module_from_working_dir_2 "$PATH_REPO_MAIN"
    )
}

function add_flag_to_item_module {
    [ -p /dev/stdin ] && {
        while IFS= read item_module; do
            flag=""
            echo "$module_list_via_config_file"     | cut -d: -f2 | grep "^${item_module#*:}$" > /dev/null && flag="$flag""c" || flag="$flag""-"
            echo "$module_list_via_git_foreach"     | cut -d: -f2 | grep "^${item_module#*:}$" > /dev/null && flag="$flag""f" || flag="$flag""-"
            echo "$module_list_via_find_dot_git"    | cut -d: -f2 | grep "^${item_module#*:}$" > /dev/null && flag="$flag""g" || flag="$flag""-"
            echo "$module_list_via_find_working"    | cut -d: -f2 | grep "^${item_module#*:}$" > /dev/null && flag="$flag""w" || flag="$flag""-"

            echo "$flag:$item_module"
        done
    }
}

function continue_or__display_n_exit  {

    echo_chk_clrd 1 31 "Do you want to compare with the other source?"
    list_values=$( 
        echo "No:  Module list without compare-flag"
        echo "Yes: Module list with    compare-flag"
    )
    selecting_dash_option              "choice_sel"
    choice_sel=${choice_sel%:*}
    echo_chk_clrd 1 33 "Selected: $choice_sel"

    [ "$choice_sel" = "No" ] && {
        echo "$module_list_std" | display_module_list_pipe
        exit 0
    }

}

function perform_local_list_display_source  {
    echo "$module_list_std" | add_flag_to_item_module | display_module_list_pipe
}



function perform_remote_list {
    list_values=$(
        cd "$PATH_REPO_MAIN" && {
            cmd_storage="lsrepogroupall"
            export git_foreach_repogroup="__MAIN_GROUP__"

            cmd_remote_storage.sh chkmount && {
                cmd_remote_storage.sh $cmd_storage || {
                    exit 1
                }
            } || {
                exit 1
            }
        }
    ) || {
        exit 1
    }

    display_list
}

function perform_gitignore_update   {
    [ "$sm_path_ignore" = "all" ] && {
        cd "$toplevel/$sm_path" && {
            git_foreach_top_gitignore_sync.sh -d
        }
        true
    } || {
        cmd_local_module.sh -d gitignore "$sm_path" "$sm_path_ignore"
        true
    }
}


function GRS_cmd {

    echo_dbg
    echo_chk_clrd 1 35 "==============="
    echo_dbg
    git_sub_repo_local_cmd.sh gitstatus
    git submodule foreach --recursive "{
        git_sub_repo_local_cmd.sh gitstatus
    }"

}

function perform_pull   {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            echo_dbg
            echo_chk_clrd 1 35 "==============="
            echo_dbg
            git_sub_repo_local_cmd.sh gitpull
            GRS_cmd
        }
    )
}

function perform_fetch_merge    {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            echo_dbg
            echo_chk_clrd 1 35 "==============="
            echo_dbg
            git_sub_repo_local_cmd.sh gitfetchmerge
            GRS_cmd
        }
    )
}

function perform_status {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            GRS_cmd
        }
    )
}

function perform_push    {
    (
        # perform push
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            func_module_push.sh -d -e

            [ "$recursive_sel" = "Recursive" ] && {
                git submodule foreach --recursive "{
                    func_module_push.sh -d -e
                    true
                }"
            }
            true
        } || {
            echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid submodule git root directory"
            exit 1
        }
    )
}

function perform_archive    {
    (
        # perform push
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            git_sub_repo_local_cmd.sh archive

            [ "$recursive_sel" = "Recursive" ] && {
                git submodule foreach --recursive "{
                    git_sub_repo_local_cmd.sh archive
                    true
                }"
            }
            true
        } || {
            echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid submodule git root directory"
            exit 1
        }
    )
}

function perform_archive_importing    {
    (
        # perform push
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            git_sub_repo_local_cmd.sh archiveimporting

            [ "$recursive_sel" = "Recursive" ] && {
                git submodule foreach --recursive "{
                    git_sub_repo_local_cmd.sh archiveimporting
                    true
                }"
            }
            true
        } || {
            echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid submodule git root directory"
            exit 1
        }
    )
}

function perform_deinit_module_url_settings {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            cmd_local_module.sh -d seturldeinit $sm_path
        } || {
            echo_chk_clrd 1 31 "\"$toplevel/$sm_path\" directory does not exist or is not a valid git submodule"
        }
    )
}

function perform_url_setting    {

    cd "$toplevel/$sm_path" && {
        export toplevel
        export sm_path
        git_sub_repo_remote_url_set.sh -d -e -f $sru_priority_sel $storage_sel $protocol_sel $address_sel

        [ "$recursive_sel" = "Recursive" ] && {
            git submodule foreach --recursive "{
                git_sub_repo_remote_url_set.sh -d -e -f $sru_priority_sel $storage_sel $protocol_sel $address_sel
                true
            }"
        }
    }
}

function perform_submodule_update_init  {
    # check if submodule exists
    {
        [ -d "$sm_path_abs" ] && {
            [ -d "$sm_path_abs/.git" ] || 
            [ -f "$sm_path_abs/.git" ]
        }
    } && {
        (
            cd "$sm_path_abs"
            git submodule update --init "$sm_to_init_path" && {
                echo_chk_clrd 1 32 "OK -> \"git submodule update --init\" command has been properly performed"
            } || {
                echo_chk_clrd 1 31 "ERROR in \"git submodule update --init\" command"
            }
        )
    } || {
        echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid module git root directory"
        exit 1
    }

}

function perform_absorbing    {
    # check if submodule exists
    {
        [ -d "$toplevel" ] && {
            [ -d "$toplevel/.git" ] || 
            [ -f "$toplevel/.git" ]
        }
    } && {
        (
            export storage_sel
            export protocol_sel
            export address_sel
            export repogroup_sel
            export module_parent_sel

            export toplevel
            export sm_path
            export git_foreach_storage=$storage_sel
            export git_foreach_machine=$protocol_sel
            export git_foreach_address=$address_sel
            export git_foreach_repogroup=$repogroup_sel
            cd "$toplevel"
            git_sub_repo_local_crt_cln.sh -d addabsorb "$remote_module_url" "$sm_path" 
        )
    } || {
        echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid module git root directory"
        exit 1
    }
}

function perform_cloning    {
    # check if submodule exists
    {
        [ -d "$toplevel" ] && {
            [ -f "$toplevel/.git" ] ||
            [ -d "$toplevel/.git" ]
        }
    } && {
        (
            cd "$toplevel"
            git_sub_repo_local_crt_cln.sh -d clone "$remote_module_url" "$sm_path" || exit 1
        ) || {
            exit 1
        }
    } || {
        echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid submodule git root directory"
        exit 1
    }
}

function perform_generic_cloning    {
    # check if submodule exists
    {
        [ -d "$toplevel" ] && {
            [ -f "$toplevel/.git" ] ||
            [ -d "$toplevel/.git" ]
        }
    } && {
        (
            cd "$toplevel"
            git_sub_repo_local_crt_cln.sh -d clone "$remote_module_url" "$sm_path" || exit 1
        ) || {
            exit 1
        }
    } || {
        echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid submodule git root directory"
        exit 1
    }
}

function perform_creation {
    # check if submodule exists
    {
        [ -d "$toplevel" ] && {
            [ -d "$toplevel/.git" ] || 
            [ -f "$toplevel/.git" ]
        }
    } && {
        (
            cd "$toplevel"
            git_sub_repo_local_crt_cln.sh -d new "$remote_module_url" "$sm_path" 
        )
    } || {
        echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid module git root directory"
        exit 1
    }
}

function perform_generic_creation {
    # check if submodule exists
    {
        [ -d "$toplevel" ] && {
            [ -d "$toplevel/.git" ] || 
            [ -f "$toplevel/.git" ]
        }
    } && {
        (
            cd "$toplevel"
            git_sub_repo_local_crt_cln.sh -d genericnew "$remote_module_url" "$sm_path" 
        )
    } || {
        echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid module git root directory"
        exit 1
    }
}

function perform_commit_message    {
    echo
    echo_chk_clrd 1 32 "4. Commit message:"
    echo
    read_string                         "commit_message"
    echo_chk_clrd 1 33 "commit_message: $commit_message"
}

function perform_add_commit     {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            echo_dbg
            echo_chk_clrd 1 35 "==============="
            echo_dbg
            git_sub_repo_local_cmd.sh gitaddcommitlogstatus "$sm_path" "$commit_message"
            GRS_cmd
        }
    )
}

function perform_synchro_branch     {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            echo_dbg
            echo_chk_clrd 1 35 "==============="
            echo_dbg
            echo "Entering '$sm_path'"
            git_sub_repo_local_cmd.sh synchrobranch $brc_owner
            git submodule foreach --recursive "git_sub_repo_local_cmd.sh synchrobranch $brc_owner"
        }
    )
}

function perform_synchro_branch_check     {
    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            echo_dbg
            echo_chk_clrd 1 35 "==============="
            echo_dbg
            echo "Entering '$sm_path'"
            git_sub_repo_local_cmd.sh synchrobranchcheck $brc_owner
            git submodule foreach --recursive "git_sub_repo_local_cmd.sh synchrobranchcheck $brc_owner"
        }
    )
}

## ************************************************
## --- Branching

function func_get_owner_branch_name {

    brc_owner="$(               git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.owner.prefix  )"
    brc_owner="$brc_owner"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.owner.name    )"
    brc_owner="$brc_owner"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.owner.os      )"
    brc_owner="$brc_owner"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.owner.machine )"
    
}

function func_get_branch_name {

    brc_name="$(              git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$1.prefix  )"
    brc_name="$brc_name"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$1.name    )"
    brc_name="$brc_name"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$1.os      )"
    brc_name="$brc_name"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$1.machine )"
    
}

function func_get_branch_name_pipe {

    [ -p /dev/stdin ] && {
        while IFS= read item; do
            brc_name="$(              git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$item.prefix  )"
            brc_name="$brc_name"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$item.name    )"
            brc_name="$brc_name"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$item.os      )"
            brc_name="$brc_name"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$item.machine )"
            [ "$item" = "owner" ] && echo "$brc_name (owner)" || echo "$brc_name"
        done
    }

    
}

function func_branch_set_owner  {
    sel_branch=$brc_owner
    echo_chk_clrd 1 33 "Selected: $sel_branch"
    branch_creation_sel="Yes"
}

function func_branch_set_main  {
    sel_branch=main
    echo_chk_clrd 1 33 "Selected: $sel_branch"
    branch_creation_sel="No"
}

function func_branch_set_other    {
    echo_chk_clrd 1 32 "What branch do you want to checkout?"
    pwd_saved=$PWD
    cd "$toplevel/$sm_path" && {
        list_values=$(
            git branch | cut -c3- | grep -v "^$brc_owner$" | grep -v "^__MAIN_GROUP__$"
        )
    }
    cd "$pwd_saved"
    branch_creation_sel="No"

    selecting_dash_option         "sel_branch"
    echo_chk_clrd 1 33 "Selected: $sel_branch"
}

function func_branch_set_all    {
    echo_chk_clrd 1 32 "What branch do you want to checkout?"
    pwd_saved=$PWD
    cd "$toplevel/$sm_path" && {
        list_values=$(
            git branch | cut -c3-
        )
    }
    cd "$pwd_saved"
    branch_creation_sel="No"

    selecting_dash_option         "sel_branch"
    echo_chk_clrd 1 33 "Selected: $sel_branch"
}

function func_branch_user_config_file    {
    echo_chk_clrd 1 32 "What branch do you want to checkout?"

    list_values_pre=$(
        git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" -l | cut -d. -f2 | uniq
    )

    list_values=$(
        echo "__MAIN_GROUP__"
        for item in ${list_values_pre[@]};
        do
            func_get_branch_name $item
            echo $brc_name
        done
    )

    branch_creation_sel="No"

    selecting_dash_option         "sel_branch"
    echo_chk_clrd 1 33 "Selected: $sel_branch"
}


function func_branch_list_from_user_config_file    {
    echo_chk_clrd 1 32 "Branch list from <user_branch_config> file"
    option_list_values=$(
        echo "__MAIN_GROUP__"
        git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" -l | cut -d. -f2 | sort | uniq | func_get_branch_name_pipe | sort
    )
    selecting_option_dash_general_pipe "sel_branch"

    echo_chk_clrd 1 33 "Selected: $sel_branch"
    sel_branch=${sel_branch% (*}

}

function perform_branch_list_from_user_config_file    {
    echo_chk_clrd 1 32 "Branch list from <user_branch_config> file"
    {
        echo "__MAIN_GROUP__"
        git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" -l | cut -d. -f2 | sort | uniq | func_get_branch_name_pipe | sort
    } | display_list_pipe

}

## ************************************************
## --- Exporting variables

function func_export_variable {
    export storage_sel
    export protocol_sel
    export address_sel
    export repogroup_sel
    export module_parent_sel

    export toplevel
    export sm_path
}

## ************************************************
## --- Remote repository URL

function func_priority_select   {
    echo
    echo_chk_clrd 1 32 "2. Which priority do you want to set"
    list_values=$( 
        echo "Priority 1"
        echo "Priority 2"
        echo "Priority 3"
        echo "Priority 4"
    )

    selecting_dash_option              "sru_priority_sel"
    sru_priority_sel=${sru_priority_sel#* }
    echo_chk_clrd 1 33 "Selected: $sru_priority_sel"
}

function func_module_parent_repo_remote_url    {
    module_parent_sel=$(cmd_local_module.sh getsmpath $toplevel) || {
        module_parent_sel=$(basename $PATH_REPO_MAIN)
    }
    repogroup_sel=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$module_parent_sel.repogroup)
    [ "__MAIN_GROUP__" = $repogroup_sel ] && {
        func_repogroup_without_main
    }
    remote_module_url=$(
        cd "$PATH_REPO_MAIN" && {
            export toplevel
            export sm_path
            export git_foreach_repogroup="$repogroup_sel"
            repo_sub_storage_param_get.sh -d url
        }
    )
    echo_chk_clrd 1 32 "remote_module_url: $remote_module_url"
}

function func_repo_remote_url {
    remote_module_url=$(
        cd "$PATH_REPO_MAIN" && {
            export toplevel
            export sm_path
            export git_foreach_repogroup="$repogroup_sel"
            
            repo_sub_storage_param_get.sh -d url
        }
    )
    echo_chk_clrd 1 32 "remote_module_url: $remote_module_url"
}

function func_repourl_address {
    list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp net | grep "^net\.$protocol_sel\." | cut -d. -f3 |  cut -d' ' -f1  | grep -v "^default") && {
        num_value=$(echo "$list_values" | wc -l )
        [ $num_value -gt 1 ] && {
            echo_chk_clrd 1 32 "2.4. What address does the remote machine have?"
            selecting_dash_option  "address_sel"
        } || {
            [ $num_value -eq 1 ] && {
                echo_chk_clrd 1 32 "2.4. There is only one value for the address?"
                address_sel="$list_values"
            }
        }
        echo_chk_clrd 1 33 "Selected: $address_sel"
        export git_foreach_address="$address_sel"
    }

}

function func_repourl_machine {
    list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only protocol. | grep "^protocols\.$storage_sel\." | cut -d. -f3 | grep -v "^default")
    num_value=$(echo "$list_values" | wc -l )
    [ $num_value -gt 1 ] && {
        echo_chk_clrd 1 32 "2.3. What machine is the remote storage partition mounted on?"
        selecting_dash_option  "protocol_sel"
    } || {
        [ $num_value -eq 1 ] && {
            echo_chk_clrd 1 32 "2.3. There is only one value for the protocol?"
            protocol_sel="$list_values"
        }
    }
    echo_chk_clrd 1 33 "Selected: $protocol_sel"
    export git_foreach_machine="$protocol_sel"

}

function func_repourl_storage {
    list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only protocol | grep "^protocol" | cut -d. -f2 | uniq)
    selecting_dash_option              "storage_sel"
    echo_chk_clrd 1 33 "Selected: $storage_sel"
    export git_foreach_storage=$storage_sel

}

## ************************************************
## --- Listing modules

function func_selecting_submodules  {
    list_values=$(
        cd "$sm_path_abs"
        git config -f ".gitmodules" -l | cut -d. -f2 | sort | uniq)
    selecting_dash_option         "sm_to_init_path"
    echo_chk_clrd 1 33 "Selected: $sm_to_init_path"
}

function func_module_childs_list    {
    echo
    echo_chk_clrd_start 1 31 "List of all submodule of the module to be removed"
    cmd_local_module.sh childlist "$sm_path"
    echo_chk_clrd_end
    echo
}

function func_remote_module_name    {
    module_remote_name=$(basename $remote_module_url)


}

function func_remote_module_list    {

    list_values=$(
        cd "$PATH_REPO_MAIN" && {
            echo_chk_clrd 1 33 "Selected: $sel_remote_module_to_clone"
            {
                [ "$creation_sel"  = "LsR" ] &&
                [ "$repogroup_sel" = "all" ]
            } && {
                cmd_storage="lsrepogroupall"
                export git_foreach_repogroup="__MAIN_GROUP__"
            } || {
                cmd_storage="lsrepogroup"
                export git_foreach_repogroup="$repogroup_sel"
            }

            cmd_remote_storage.sh chkmount && {
                cmd_remote_storage.sh $cmd_storage || {
                    exit 1
                }
            } || {
                exit 1
            }
        }
    ) || {
        exit 1
    }


    selecting_dash_option         "sel_remote_module"
    echo_chk_clrd 1 33 "Selected: $sel_remote_module"

    remote_module_url_group=$(
        cd "$PATH_REPO_MAIN" && {
            export git_foreach_storage=$storage_sel
            export git_foreach_machine=$protocol_sel
            export git_foreach_address=$address_sel
            export git_foreach_repogroup=$repogroup_sel
            repo_sub_storage_param_get.sh -d urlgroup
        }
    )

    remote_module_url=$remote_module_url_group$sel_remote_module
    sm_path_abs="$module_path_abs/${sel_remote_module%.git}"
    sm_path="$module_path/${sel_remote_module%.git}"

    echo_dbg_clrd 1 33 "remote_module_url_group:   $remote_module_url_group"
    echo_dbg_clrd 1 33 "remote_module_url:         $remote_module_url"

}

## ************************************************
## --- Selecting module, its group & parent

function func_absorbing_module {

    echo 
    echo_chk_clrd 1 32 "3. Which local repo do you want to add and absorb into an existing module?"
    list_values=$(
        find "$PATH_REPO_MAIN" -name ".git" -type d  ! '(' -path "*/.git/*" -o -path "$PATH_REPO_MAIN/.git" ')'
    ) 
    echo_chk_clrd 1 34 "Number of elements: ${#list_values[@]}"
    [ "${list_values[0]}" ] && {
        selecting_dash_option         "module_to_add_absorb"
        echo_chk_clrd 1 33 "Selected: $module_to_add_absorb"
        git_file=$(basename "$module_to_add_absorb")
        [ "$git_file" = ".git" ] && {
            sm_path_abs=$(dirname "$module_to_add_absorb")
            toplevel=$(cmd_local_module.sh gettoplevel "$sm_path_abs")
            sm_path=${sm_path_abs#$toplevel/}
        }

        [ ! "$toplevel" ] && exit 1
        true
    } || {
        echo_chk_clrd 1 31 "No local repo to absorb existing"
        exit 0
    }

}

function func_cloned_module_dir {
    echo
    echo_chk_clrd 1 32 "4. Where do you want to execute the cloning operation (set the relative path respect \"smdl\" folder of its parent module previously selected)?"
    ## "Write the path, relative to \"smdl\" parent folder, where perform the cloning procedure, set a dot (\".\") if no path (i.e. folder module will be into \"smdl\")"
    ## "Cloning procedure put the cloned files into a folder called with the same name of module"
    echo
    read_string                      "module_path"

    toplevel=$(func_module_path_abs.sh "$module_parent_sel")
    [ "$module_path" = "." ] && {
        module_path="smdl"
        module_path_abs=$toplevel
    } || {
        module_path="smdl/$module_path"
        module_path_abs=$toplevel/$module_path
    }
    echo_chk_clrd 1 33 "module_path_abs: $module_path_abs"
}

function func_cloned_generic_module_dir_0 {

    # check the protocol selected
    protocol_to_check=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get protocols.$storage_sel.$protocol_sel)

    [ "$protocol_to_check" = "https:/" ] && {
        func_generic_new_module_name
    } || {
        func_cloned_generic_module_dir
    	# --- select module to clone
	    func_remote_module_list
    }
}

function func_cloned_generic_module_dir {
    echo
    echo_chk_clrd 1 32 "4. Where do you want to execute the cloning operation (set the relative path respect \"home\" folder of its parent module previously selected)?"
    echo
    read_string                      "module_path"

    toplevel=$(func_module_path_abs.sh "$module_parent_sel")
    [ "$module_path" = "." ] && {
        module_path=""
        module_path_abs=$toplevel
    } || {
        module_path="$module_path"
        module_path_abs=$toplevel/$module_path
    }
    echo_chk_clrd 1 33 "module_path_abs: $module_path_abs"
}

function func_new_module_name {
    echo
    echo_chk_clrd 1 32 "4. Which name, with the relative path respect \"smdl\" folder of its parent module, does the current module, that is going to be created, have?"
    echo
    read_string                      "module_path_name"
    echo_chk_clrd 1 33 "module name: $module_path_name"
    module_name=$(basename "$module_path_name")
    [ "$module_path_name" = "$module_name" ] &&  module_path= || module_path=$(dirname  "$module_path_name")/
    prefix=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get repogroup.$repogroup_sel.prefix)
    sm_path="smdl/$module_path$prefix$module_name"
    echo_chk_clrd 1 33 "sm_path:     $sm_path"

    toplevel=$(func_module_path_abs.sh "$module_parent_sel")
    sm_path_abs=$toplevel/$sm_path
    
    echo_chk_clrd 1 33 "sm_path_abs: $sm_path_abs"
}

function func_generic_new_module_name {
    echo
    echo_chk_clrd 1 32 "4. Which name, with the relative path, does the current module, that is going to be created, have?"
    echo
    read_string                      "module_path_name"
    echo_chk_clrd 1 33 "module name: $module_path_name"
    module_name=$(basename "$module_path_name")
    [ "$module_path_name" = "$module_name" ] &&  module_path= || module_path=$(dirname  "$module_path_name")/
    prefix=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get repogroup.$repogroup_sel.prefix)
    sm_path="$module_path$prefix$module_name"
    echo_chk_clrd 1 33 "sm_path:     $sm_path"

    toplevel=$(func_module_path_abs.sh "$module_parent_sel")
    sm_path_abs=$toplevel/$sm_path
    
    echo_chk_clrd 1 33 "sm_path_abs: $sm_path_abs"
}



function func_repo_parent_module {
    echo 
    echo_chk_clrd 1 32 "3. Which parent module does the current module that is going to be created belong to?"
    list_values=$(
        git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp submodule | grep ".repogroup __MAIN_GROUP__" | cut -d. -f2    
        git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp submodule | grep ".repogroup $repogroup_sel" | cut -d. -f2    
    )
    selecting_dash_option              "module_parent_sel"
    echo_chk_clrd 1 33 "Selected: $module_parent_sel"
}


function func_display_licensed_dir {

    toplevel=$(func_module_path_abs.sh "$module_parent_sel")
    #cat "$toplevel/LICENSED_CODE" | grep -v "^#" | grep -v "^!"
    list_file=
    echo "--------------------"
    echo "Involved directories:"
    while IFS= read -r item; do
        echo "$toplevel/$item"
        list_file=$(
            echo $list_file
            find $toplevel/$item -type f '(' -name "CMakeLists.txt" -o -name "*.cmake" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" ')'
        )
    done < <(cat "$toplevel/LICENSED_CODE" | grep -v "^#" | grep -v "^!" | grep -v "^ " | grep -v "^$")
    echo "--------------------"

    list_dir_exclude=$(cat "$toplevel/LICENSED_CODE" | grep "^!")

    for item_dir in ${list_dir_exclude[@]}
    do
        list_file=$(
            for item in ${list_file[@]}
            do
                echo "$item" | grep -v "${item_dir#*!}"
                #echo "$item"
            done
        )
    done

}

function add_or_not   {
    echo_chk_clrd 1 31 "Do you want to add license to current file \"$1\"?"
    list_values=$( 
        echo "No"
        echo "Yes"
        echo "None"
        echo "All"
    )

    selecting_dash_option              "add_sel"
    #add_choice_sel=${add_sel%:*}
    echo_chk_clrd 1 33 "Selected: $add_sel"

}
	
function del_or_not   {
    echo_chk_clrd 1 31 "Do you want to delete license to current file \"$1\"?"
    list_values=$( 
        echo "No"
        echo "Yes"
        echo "None"
        echo "All"
    )

    selecting_dash_option              "del_sel"
    #del_choice_sel=${del_sel%:*}
    echo_chk_clrd 1 33 "Selected: $del_sel"

}

function func_display_licensed_files    {

    comment="//  "
    header_license_code=()
    while IFS= read -r item; do
        header_license_code+=("$comment$item")
    done < <(cat $toplevel/LICENSE_HEADER)

    comment="#   "
    header_license_cmake=()
    while IFS= read -r item; do
        header_license_cmake+=("$comment$item")
    done < <(cat $toplevel/LICENSE_HEADER)

    line_number_license_header=$(wc -l < "$toplevel/LICENSE_HEADER")

    echo "----- "
    for item in ${list_file[@]}
    do
        file_licence=0
        file_name="$(basename $item)"
        head -6 "$item" | tail -3 | grep "Copyright (C) (2023) Marco Dau" && {
            echo "file --- \"$item\""
            file_licence=1
            {
                [ "None" != "$del_sel" ] &&
                [ "All"  != "$del_sel" ]
            } && {
                del_or_not "$file_name"
            } || true
        } || {
            echo "file +++ \"$item\""
            {
                [ "None" != "$add_sel" ] &&
                [ "All"  != "$add_sel" ]
            } && {
                add_or_not "$file_name"
            } || true
        }

        [ $file_licence -eq 1 ] && {
            {
                [ "Yes" = "$del_sel" ] ||
                [ "All" = "$del_sel" ]
            } && {
                license_del $item
                echo "Deleted"
            } || {
                echo "Nothing done"
            }
        } || {
            {
                [ "Yes" = "$add_sel" ] ||
                [ "All" = "$add_sel" ]
            } && {
                license_add $item
                echo "Added"
            } || {
                echo "Nothing done"
            }
        }
        echo "~~~~~~~~~~~~~~~~~"

    done
    echo "----- "

}

function license_del    {
    file_name=$toplevel/$(basename "$1")

    line_number=$(wc -l < "$1")

    # check the end of file
    last_char_of_file=$(tail -1 < $1 | tail -c 1)
    [ "$last_char_of_file" ] && ((line_number++))
    # [ "$last_char_of_file" ] && echo "Line with EOF" || echo "Line WITHOUT EOF"

    [ $line_number -ge $line_number_license_header ] && {

        echo "Performing action ..."
        [ $line_number -eq $line_number_license_header ] && {
            touch "$toplevel/tmp_file"
        } || {
            line_number=$((line_number-$line_number_license_header))
            tail -$line_number "$1" > "$toplevel/tmp_file"
        }
        mv "$toplevel/tmp_file" "$1"
    } || {
        echo_chk_clrd 1 31 "~v~v~v~v~v~v~v~v~"
        echo_chk_clrd 1 31 "The processed file can't contains the right license ()"
        echo_chk_clrd 1 31 "~v~v~v~v~v~v~v~v~"
    }

}

function license_add    {
    ## head -5 "$1"
    ## file_licensed=()
    ## while IFS= read -r item; do
    ##     file_licensed+=("$item")
    ## done < <(cat $1)
    ## file_name="/Users/work/ObsiDataTest/"${1##/mpfw/}

    file_name=$toplevel/$(basename "$1")

    echo "Performing action ..."
    extension=${1##*.}
    case "$extension" in
        "c"   | \
        "cpp" | \
        "h"   | \
        "hpp")
            for row_header in "${header_license_code[@]}"
            do
                echo "$row_header" >> "$toplevel/tmp_file"
            done
            ;;
        "cmake" | \
        "txt")
            for row_header in "${header_license_cmake[@]}"
            do
                echo "$row_header" >> "$toplevel/tmp_file"
            done
            ;;
    esac
    cat "$1" >> "$toplevel/tmp_file"
    mv "$toplevel/tmp_file" "$1"
}


function func_repogroup_all {
    echo_chk_clrd 1 32 "2. What kind of repo does the module belong to?"
    list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only repogroup | grep "^repogroup." | cut -d. -f2 | uniq )
    list_values=$( 
        echo "$list_values"
        echo "all"
    )

    selecting_dash_option              "repogroup_sel"
    echo_chk_clrd 1 33 "Selected: $repogroup_sel"
}

function func_repogroup_without_main {
    echo_chk_clrd 1 32 "2. What kind of repo does the module belong to?"
    list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only repogroup | grep "^repogroup." | cut -d. -f2 | uniq | grep -v "^__MAIN_GROUP__$")

    selecting_dash_option              "repogroup_sel"
    echo_chk_clrd 1 33 "Selected: $repogroup_sel"
}

function func_repogroup_with_main {
    echo_chk_clrd 1 32 "2. What kind of repo does the module belong to?"
    list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only repogroup | grep "^repogroup." | cut -d. -f2 | uniq )

    selecting_dash_option              "repogroup_sel"
    echo_chk_clrd 1 33 "Selected: $repogroup_sel"
}

function func_repomodule_gitignore {

    echo_chk_clrd 1 32 "4. Whose module do you want to set its .gitignore file?"
    list_values=$(
        cmd_local_module.sh childlist "$sm_path"
    )

    [ "${list_values[0]}" ] && {
        list_values=$(
            echo "all"
            echo "$list_values"
        )

        selecting_dash_option         "sm_path_ignore"
        echo_chk_clrd 1 33 "Selected: $sm_path_ignore"
    } || {
        echo_chk_clrd 1 31 "No childs exist"
        exit 0
    }

}


function func_repomodule_2 {

    echo_chk_clrd 1 32 "2. What module do you want to select?"
    create_list_module_std_source_foreach
    selecting_option_dash_pipe "sm_path"

    echo_chk_clrd 1 33 "Selected: $sm_path"
    sm_path=${answer_linked#*:}
    sm_path_abs=$(func_module_path_abs.sh "$sm_path")
    toplevel=${sm_path_abs%/$sm_path}

}

function func_repomodule {

    echo_chk_clrd 1 32 "2. What module do you want to select?"
    list_values=$(
        git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp submodule | grep ".repogroup $repogroup_sel" | cut -d. -f2
    )
    
    selecting_dash_option              "sm_path"
    echo_chk_clrd 1 33 "Selected: $sm_path"
    sm_path_abs=$(func_module_path_abs.sh "$sm_path")
    toplevel=${sm_path_abs%/$sm_path}

}

## ************************************************
## --- Menu & Command management
function call_procedure {

    script_to_perform_list=$(git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --get-all command."$1".script) && {
        for item in ${script_to_perform_list[@]};
        do
            eval "$item"
        done
        true
    } || {
        echo_chk_clrd 1 31 "\"$1\" has no elements"
    }

}

function call_menu {
    [ "$1" ] && menu_name=$1
    list_values=$(git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --get-all menu."$menu_name".menuitem) && {
        selecting_dash_option              "menuitem_sel"
        echo_chk_clrd 1 33 "Selected: $menuitem_sel"
        menuitem_type=$(echo $menuitem_sel | cut -d: -f1)
        echo_chk_clrd 1 33 "menuitem_type: $menuitem_type"
        menuitem_id=$(echo $menuitem_sel | cut -d: -f2)
        case "$menuitem_type" in
            "menu" )
                call_menu "$menuitem_id"
            ;;
            "command" )
                call_procedure "$menuitem_id"
            ;;
            *)
                echo
            ;;
        esac
        true
    } || {
        echo_chk_clrd 1 31 "\"$menuitem_id\" has no elements"
    }

}

call_menu "Main"
