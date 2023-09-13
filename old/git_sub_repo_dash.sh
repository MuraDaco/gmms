#!/bin/bash

PWD_script="$PWD"

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_echo_selection.sh


# **** Start script
echo_start_script
# **** Start script

# *********************************
# 1. Actions on module
echo 
echo_chk_clrd 1 32 "1. What do you want to do with the submodule?"
list_values=$( 
    echo "Crt: Creating a  new one"
    echo "Cln: Cloning  an existing one"
    echo "Adb: Add & Absorb an existing one"
    echo "Psh: Push local repo to remote; if no remote then it will be created, if conflicts then local branch will might be renamed and then re-push"
    echo "Prh: Push local repo to remote recursively on all submodule"
    echo "---: --------------------------------------------"
    echo "BSt: Branch status check (name of branch or DETACHED MODE)"
    echo "BCO: Branch checkout"
    echo "RfR: Set refs parameter in branch section of \"config\" file"
    echo "---: --------------------------------------------"
    echo "SnU: Set new url in uninitialized submodule"
    echo "StU: Set new url"
    echo "SRU: Set new url recursively on all submodule"
    echo "SUP: Set new url recursively on all submodule and then push"
    echo "SRI: Set .gitignore recursively on all submodule, parent module has to have \".gitignore_module\" file properly configured"
    echo "---: --------------------------------------------"
    echo "GRS: git status recursive"
    echo "---: --------------------------------------------"
    echo "GRA: git add    recursive"
    echo "GRC: git commit recursive"
    echo "GRL: git log --pretty=oneline --graph --decorate --all  recursive"
    echo "GR_: git add -> commit -> log -> status recursive"
    echo "---: --------------------------------------------"
    echo "FMR: git fetch -> merge (recursive)"
    echo "PlR: git pull (recursive)"
    echo "---: --------------------------------------------"
    echo "Chk: check the repo remote url in all config files (there are three one)"
    echo "Crk: check the repo remote url in all config files (there are three one) recursively on all submodule"
    echo "CkS: check the submodule status"
    echo "CrS: check the submodule status recursively on all submodule"
    echo "LsL: list local submodule"
    echo "LsR: list remote submodule"
    echo "---: --------------------------------------------"
    echo "---: --------------------------------------------"
    echo "RmL: Removing a local existing one"
    echo "RmR: Removing a remote existing one"
)
selecting_option              "creation_sel"
creation_sel=${creation_sel%:*}
echo_chk_clrd 1 33 "Selected: $creation_sel"

# *********************************
# 2. repogroup of module
{
    [ "$creation_sel" = "SRU" ] ||
    [ "$creation_sel" = "SUP" ]
} && {
    echo
    echo_chk_clrd 1 32 "2. How to set parameter URL"
    list_values=$( 
        echo "SRUp: storage priority"
        echo "SRUd: storage default: the storage has a default value for \"protocol\" & \"net\""
        echo "SRUc: storage custom"
    )

    selecting_option              "sru_menu_sel"
    sru_menu_sel=${sru_menu_sel%%:*}
    echo_chk_clrd 1 33 "Selected: $sru_menu_sel"
}

# *********************************
# 2. repogroup of module
{
    [ "$sru_menu_sel" = "SRUp" ]
} && {
    echo
    echo_chk_clrd 1 32 "2. Which priority do you want to set"
    list_values=$( 
        echo "Priority 1"
        echo "Priority 2"
        echo "Priority 3"
        echo "Priority 4"
    )

    selecting_option              "sru_priority_sel"
    sru_priority_sel=${sru_priority_sel#* }
    echo_chk_clrd 1 33 "Selected: $sru_priority_sel"
}

# *********************************
# 2. repogroup of module
# {
#     [ "$creation_sel" = "SRU" ]
# } && {

    case "$creation_sel" in

        "Crt" | \
        "CtR" | \
        "Cln" | \
        "RmR" | \
        "RmL" )
            echo
            echo_chk_clrd 1 32 "2. What kind of repo does the module belong to?"
            list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only repogroup | grep "^repogroup." | cut -d. -f2 | uniq | grep -v "main" )
        ;;

        "SnU" | \
        "BSt" | \
        "BCO" | \
        "RfR" | \
        "FMR" | \
        "PlR" | \
        "LsL" | \
        "LsR" )
            echo
            echo_chk_clrd 1 32 "2. What kind of repo does the module belong to?"
            list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only repogroup | grep "^repogroup." | cut -d. -f2 | uniq )
            list_values=$( 
                echo "$list_values"
                echo "all"
            )
        ;;
        "Adb" )
        ;;
        *)
            echo
            echo_chk_clrd 1 32 "2. What kind of repo does the module belong to?"
            list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only repogroup | grep "^repogroup." | cut -d. -f2 | uniq )

        ;;

    esac

##    {
##
##        [ "$creation_sel" = "RmR" ] || 
##        [ "$creation_sel" = "RmL" ] || 
##        [ "$creation_sel" = "Crt" ] || 
##        [ "$creation_sel" = "CtR" ] || 
##        [ "$creation_sel" = "Cln" ]
##    } && {
##        list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only repogroup | grep "^repogroup." | cut -d. -f2 | uniq | grep -v "main" )
##    } || {
##        list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only repogroup | grep "^repogroup." | cut -d. -f2 | uniq )
##        {
##            [ "$creation_sel" = "LsL" ] || 
##            [ "$creation_sel" = "LsR" ]
##        } && {
##            list_values=$( 
##                echo "$list_values"
##                echo "all"
##            )
##        }
##    }
    [ ! "$creation_sel" = "Adb" ] && {
        selecting_option              "repogroup_sel"
        echo_chk_clrd 1 33 "Selected: $repogroup_sel"
    }
# }

# *********************************
# 3. parent module
{
    [ "$creation_sel" = "Adb" ] 
} && {

    echo 
    echo_chk_clrd 1 32 "3. Which local repo do you want to add and absorb into an existing module?"
    list_values=$(
        find "$PATH_REPO_MAIN" -name ".git" -type d  ! '(' -path "*/.git/*" -o -path "$PATH_REPO_MAIN/.git" ')'

    )
    selecting_option              "module_to_add_absorb"
    echo_chk_clrd 1 33 "Selected: $module_to_add_absorb"
    git_file=$(basename "$module_to_add_absorb")
    [ "$git_file" = ".git" ] && {
        sm_path_abs=$(dirname "$module_to_add_absorb")
        toplevel=$(cmd_local_module.sh gettoplevel "$sm_path_abs")
        sm_path=${sm_path_abs#$toplevel/}
    }

    [ ! "$toplevel" ] && exit 1

}

# *********************************
# 3. parent module
{
    [ "$creation_sel" = "Crt" ] ||
    [ "$creation_sel" = "Cln" ] 
} && {

    echo 
    echo_chk_clrd 1 32 "3. Which parent module does the current module that is going to be created belong to?"
    list_values=$(
        git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp submodule | grep ".repogroup main" | cut -d. -f2    
        git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp submodule | grep ".repogroup $repogroup_sel" | cut -d. -f2    
    )
    selecting_option              "module_parent_sel"
    echo_chk_clrd 1 33 "Selected: $module_parent_sel"

}

# *********************************
# 4. module name (remove or info)
{
    [ "$creation_sel" = "BSt" ] || 
    [ "$creation_sel" = "BCO" ] || 
    [ "$creation_sel" = "FMR" ] || 
    [ "$creation_sel" = "RfR" ] || 
    [ "$creation_sel" = "PlR" ] || 
    [ "$creation_sel" = "SnU" ] || 
    [ "$creation_sel" = "SRI" ] || 
    [ "$creation_sel" = "GRS" ] || 
    [ "$creation_sel" = "GRA" ] || 
    [ "$creation_sel" = "GRC" ] || 
    [ "$creation_sel" = "GRL" ] || 
    [ "$creation_sel" = "GR_" ] || 
    [ "$creation_sel" = "RmL" ] ||
    [ "$creation_sel" = "LsL" ] ||
    [ "$creation_sel" = "StU" ] ||
    [ "$creation_sel" = "SRU" ] ||
    [ "$creation_sel" = "SUP" ] ||
    [ "$creation_sel" = "Psh" ] ||
    [ "$creation_sel" = "Prh" ] ||
    [ "$creation_sel" = "CkS" ] ||
    [ "$creation_sel" = "CrS" ] ||
    [ "$creation_sel" = "Chk" ] ||
    [ "$creation_sel" = "Crk" ]
} && {

    echo 
    [ "$creation_sel" = "BSt" ] && echo_chk_clrd 1 32 "4. Whose module do you want to know its own status branch and its submodules one?"
    [ "$creation_sel" = "BCO" ] && echo_chk_clrd 1 32 "4. On which module and its submodule do you want to perform the checkout operation?"
    [ "$creation_sel" = "FMR" ] && echo_chk_clrd 1 32 "4. From which module do you want to start to perform the fetch & merge operations?"
    [ "$creation_sel" = "PlR" ] && echo_chk_clrd 1 32 "4. From which module do you want to start to perform the pull operation?"
    [ "$creation_sel" = "RfR" ] && echo_chk_clrd 1 32 "4. From which module do you want to start to modify the config file to add \"fetch\" parameter?"
    [ "$creation_sel" = "SnU" ] && echo_chk_clrd 1 32 "4. Whose module do you want to modify its submodule url?"
    [ "$creation_sel" = "StU" ] && echo_chk_clrd 1 32 "4. Whose module do you want to modify the url?"
    [ "$creation_sel" = "SRU" ] && echo_chk_clrd 1 32 "4. Whose module do you want to modify the url?"
    [ "$creation_sel" = "SUP" ] && echo_chk_clrd 1 32 "4. Whose module do you want to modify the url?"
    [ "$creation_sel" = "Psh" ] && echo_chk_clrd 1 32 "4. Which module do you want to push?"
    [ "$creation_sel" = "Prh" ] && echo_chk_clrd 1 32 "4. Which module do you want to push?"
    [ "$creation_sel" = "SRI" ] && echo_chk_clrd 1 32 "4. From Which module do you want to start updating .gitignore file of its submodules?"
    [ "$creation_sel" = "GRS" ] && echo_chk_clrd 1 32 "4. Whose module do you want to know the status (by \"git status\" commnad)?"
    [ "$creation_sel" = "GRA" ] && echo_chk_clrd 1 32 "4. Whose module do you want to perform the \"git add\" command?"
    [ "$creation_sel" = "GRC" ] && echo_chk_clrd 1 32 "4. Whose module do you want to perform the \"git commit\" command?"
    [ "$creation_sel" = "GRL" ] && echo_chk_clrd 1 32 "4. Whose module do you want to perform the \"git log\" command?"
    [ "$creation_sel" = "GR_" ] && echo_chk_clrd 1 32 "4. Whose module do you want to perform the \"git add -> commit -> log -> status\" command?"
    [ "$creation_sel" = "RmL" ] && echo_chk_clrd 1 32 "4. Which module do you want to remove?"
    [ "$creation_sel" = "LsL" ] && echo_chk_clrd 1 32 "4. List of local module"
    [ "$creation_sel" = "CkS" ] && echo_chk_clrd 1 32 "4. List of local module"
    [ "$creation_sel" = "CrS" ] && echo_chk_clrd 1 32 "4. List of local module"
    [ "$creation_sel" = "Chk" ] && echo_chk_clrd 1 32 "4. List of local module"
    [ "$creation_sel" = "Crk" ] && echo_chk_clrd 1 32 "4. List of local module"

    {
        [ "$creation_sel"  = "LsL" ] &&
        [ "$repogroup_sel" = "all" ]
    } && {
        list_values=$(
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp submodule | grep ".repogroup" | cut -d. -f2-3
        )
        list_values=$(
            echo "======  Parsing \"remote_device_modules\" config file ======================="
            echo "$list_values"
            echo
            echo "======  Using <find \"$PATH_REPO_MAIN\" -name \".git\" -type f> command ======================="
            time find "$PATH_REPO_MAIN" -name ".git" -type f ! '(' -path "*/.git/*" -o -path "$PATH_REPO_MAIN/.git" ')'
            time find "$PATH_REPO_MAIN" -name ".git" -type f
        )
    } || {
        list_values=$(
            git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get-regexp submodule | grep ".repogroup $repogroup_sel" | cut -d. -f2    
        )
    }

    [ "$creation_sel" = "LsL" ] && {
        display_list 1 33 "$list_values"
        exit 0
    }

    selecting_option              "sm_path"
    echo_chk_clrd 1 33 "Selected: $sm_path"
    sm_path_abs=$(func_module_path_abs.sh "$sm_path")
    toplevel=${sm_path_abs%/$sm_path}
}

# *********************************
# 4. module name (create local)
{
    [ "$creation_sel" = "SRI" ]
} && {

    echo_chk_clrd 1 32 "4. Whose module do you want to set its .gitignore file?"
    list_values=$(
        cmd_local_module.sh childlist "$sm_path"
        echo "all"
    )

    selecting_option              "sm_path_ignore"
    echo_chk_clrd 1 33 "Selected: $sm_path_ignore"
    [ "$sm_path_ignore" = "all" ] && {
        sm_path_ignore=
    }

}

# *********************************
# 4. module name (create local)
{
    [ "$creation_sel" = "GR_" ]
} && {

    echo
    echo_chk_clrd 1 32 "4. Commit message:"
    echo
    read_string                         "commit_message"
    echo_chk_clrd 1 33 "commit_message: $commit_message"
}

# *********************************
# 4. module name (create local)
{
    [ "$creation_sel" = "Crt" ]
} && {
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

# *********************************
# 4. module name (create remote)
[ "$creation_sel" = "CtR" ] && {
    echo
    echo_chk_clrd 1 32 "4. What is the name of the new remote module (without neither prefix nor postfix)?"

    echo
    read_string                      "module_remote_name"
    module_remote_name=$(basename "$module_remote_name")
    prefix=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get repogroup.$repogroup_sel.prefix)
    module_remote_name=$prefix$module_remote_name".git"

    echo_chk_clrd 1 33 "module_remote_name: $module_remote_name"
}

# *********************************
# 4. module path (for cloning)
[ "$creation_sel" = "Cln" ] && {
    echo
    echo_chk_clrd 1 32 "4. Where do you want to execute the cloning operation (set the relative path respect \"smdl\" folder of its parent module previously selected)?"

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


# *********************************
# 5. Remote storage device/partition parameters
{
    [ "$creation_sel" = "StU" ] ||
    [ "$creation_sel" = "SRU" ] ||
    [ "$creation_sel" = "SUP" ] ||
    [ "$creation_sel" = "LsR" ] ||
    [ "$creation_sel" = "RmR" ] ||
    [ "$creation_sel" = "Crt" ] ||
    [ "$creation_sel" = "Adb" ] ||
    [ "$creation_sel" = "CtR" ] ||
    [ "$creation_sel" = "Cln" ] 
} && {

    {
        [ ! "$sru_menu_sel" = "SRUp" ]
    } && {

        # *********************************
        # 5. Name of remote storage
        echo
        [ "$creation_sel" = "StU" ] && {
            echo_chk_clrd 1 32 "2.2. Which remote \"Storage\" device/partition do you want the selected module to locate in to?"
        }
        [ "$creation_sel" = "Adb" ] && {
            echo_chk_clrd 1 32 "2.2. Which remote \"Storage\" device/partition do you want the selected module to locate in to?"
        }
        {
            [ "$creation_sel" = "SRU" ] ||
            [ "$creation_sel" = "SUP" ] 
        } && {
            echo_chk_clrd 1 32 "2.2. Which remote \"Storage\" device/partition do you want the selected module to locate in to?"
        }
        [ "$creation_sel" = "Crt" ] && {
            echo_chk_clrd 1 32 "2.2. Which remote \"Storage\" device/partition do you want the current new module to locate in to?"
        }
        [ "$creation_sel" = "CtR" ] && {
            echo_chk_clrd 1 32 "2.2. Which remote \"Storage\" device/partition do you want the current new module to locate in to?"
        }
        [ "$creation_sel" = "Cln" ] && {
            echo_chk_clrd 1 32 "2.2. From which remote \"Storage\" device/partition do you want to clone the module?"
        }
        [ "$creation_sel" = "RmR" ] && {
            echo_chk_clrd 1 32 "2.2. Where is the remote repo you want to remove located?"
        }
        [ "$creation_sel" = "LsR" ] && {
            echo_chk_clrd 1 32 "2.2. List of remote \"Storage\" device/partition"
        }
        list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only protocol | grep "^protocol" | cut -d. -f2 | uniq)
        selecting_option              "storage_sel"
        echo_chk_clrd 1 33 "Selected: $storage_sel"
        export git_foreach_storage=$storage_sel
    }

    {
        [ ! "$sru_menu_sel" = "SRUp" ] &&
        [ ! "$sru_menu_sel" = "SRUd" ]
    } && {

        # *********************************
        # 6. Protocol/Machine (where the remote storage is mounted)
        echo
        list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp --name-only protocol. | grep "^protocols\.$storage_sel\." | cut -d. -f3 | grep -v "^default")
        num_value=$(echo "$list_values" | wc -l )
        [ $num_value -gt 1 ] && {
            echo_chk_clrd 1 32 "2.3. What machine is the remote storage partition mounted on?"
            selecting_option  "protocol_sel"
        } || {
            [ $num_value -eq 1 ] && {
                echo_chk_clrd 1 32 "2.3. There is only one value for protocol?"
                protocol_sel="$list_values"
            }
        }
        echo_chk_clrd 1 33 "Selected: $protocol_sel"
        export git_foreach_machine="$protocol_sel"
    }

    {
        [ ! "$sru_menu_sel" = "SRUp" ] &&
        [ ! "$sru_menu_sel" = "SRUd" ]
    } && {

        # *********************************
        # 6. Network (address of remote machine when is needed)
        echo
        list_values=$(git config -f "$PATH_REPO_MAIN_CONF_STORAGES" --get-regexp net | grep "^net\.$protocol_sel\." | cut -d. -f3 |  cut -d' ' -f1  | grep -v "^default") && {
            num_value=$(echo "$list_values" | wc -l )
            [ $num_value -gt 1 ] && {
                echo_chk_clrd 1 32 "2.4. What address does the remote machine have?"
                selecting_option  "address_sel"
            } || {
                [ $num_value -eq 1 ] && {
                    echo_chk_clrd 1 32 "2.4. There is only one value for address?"
                    address_sel="$list_values"
                }
            }
            echo_chk_clrd 1 33 "Selected: $address_sel"
            export git_foreach_address="$address_sel"
        }
    }

}

# *********************************
# 7. Export parameter to use 
#    - "repo_sub_storage_param_get.sh" script
#    - "cmd_remote_storage.sh" script
# export git_foreach_storage=$storage_sel
# export git_foreach_machine="$protocol_sel"
# export git_foreach_address="$address_sel"
# export git_foreach_repogroup="$repogroup_sel"


## # *********************************
## # 4. module name (remove or info)
## {
##     [ "$creation_sel" = "Psh" ] ||
##     [ "$creation_sel" = "Prh" ]
## } && {
## 
##     # check the current url 
##     export git_foreach_storage=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onstorage)
##     export git_foreach_machine=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onmachine)
##     export git_foreach_address=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onrouter )
## 
##     cd "$toplevel/$sm_path" && {
##         export toplevel
##         export sm_path
##         remote_module_url=$(repo_sub_storage_param_get.sh url)
##     }
## 
## }
## 

# *********************************
# 8. new remote repo (check info)
{
    [ "$creation_sel" = "CtR" ]
} && {

    cd "$toplevel/$sm_path" && {
        export toplevel
        export sm_path
        remote_module_group_path=$(repo_sub_storage_param_get.sh groupremotepath)
        remote_module_path=$remote_module_group_path$module_remote_name
        echo 
        echo_chk_clrd 1 32 "remote_module_path: $remote_module_path"
    }

}


# # *********************************
# # 4. module name (create remote)
# [ "$creation_sel" = "RmR" ] && {
# 
#     module_remote_name=$(basename $remote_module_path)
#     echo_chk_clrd 1 33 "module_remote_name: $module_remote_name"
# }



# *********************************
# 8. new local repo (check info)
[ "$creation_sel" = "Adb" ] && {
    module_parent_sel=$(cmd_local_module.sh getsmpath $toplevel)
    repogroup_sel=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$module_parent_sel.repogroup)
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

# *********************************
# 8. new local repo (check info)
[ "$creation_sel" = "Crt" ] && {
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

# *********************************
# 9. Module to clone
{
    [ "$creation_sel" = "LsR" ] ||
    [ "$creation_sel" = "RmR" ] ||
    [ "$creation_sel" = "Cln" ] 
} && {

    [ "$creation_sel" = "LsR" ] && echo_chk_clrd 1 32 "2.4. List of remote module"
    [ "$creation_sel" = "RmR" ] && echo_chk_clrd 1 32 "2.4. What module do you want to remove?"
    [ "$creation_sel" = "Cln" ] && echo_chk_clrd 1 32 "2.4. What module do you want to clone?"

    list_values=$(
        cd "$PATH_REPO_MAIN" && {
            echo_chk_clrd 1 33 "Selected: $sel_remote_module_to_clone"
            {
                [ "$creation_sel"  = "LsR" ] &&
                [ "$repogroup_sel" = "all" ]
            } && {
                cmd_storage="lsrepogroupall"
                export git_foreach_repogroup="main"
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

    [ "$creation_sel" = "LsR" ] && {
        display_list 1 33 "$list_values"
        exit 0
    } || {
        selecting_option              "sel_remote_module"
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


}

# *********************************
# 4. module name (create remote)
[ "$creation_sel" = "RmR" ] && {


    module_remote_name=$(basename $remote_module_url)

    echo_chk_clrd 1 33 "module_remote_name: $module_remote_name"
}

# *********************************
# 9. Info summary
echo
echo_chk_clrd 1 32 "$creation_sel"
echo_chk_clrd 1 32 "toplevel:           $toplevel"
echo_chk_clrd 1 32 "module_path_abs:    $module_path_abs"
echo_chk_clrd 1 32 "sm_path_abs:        $sm_path_abs"
echo_chk_clrd 1 32 "sm_path:            $sm_path"
echo_chk_clrd 1 32 "remote_module_url:  $remote_module_url"
echo_chk_clrd 1 32 "remote_module_path: $remote_module_path"
echo
echo_chk_clrd 1 32 "onstorage  -> storage:            $storage_sel"
echo_chk_clrd 1 32 "onmachine  -> protocol_sel:       $protocol_sel"
echo_chk_clrd 1 32 "onrouter   -> address_sel:        $address_sel"
echo_chk_clrd 1 32 "storage    -> storage:            $storage_sel"
echo_chk_clrd 1 32 "repogroup  -> repogroup_sel:      $repogroup_sel"
echo_chk_clrd 1 32 "parent     -> module_parent_sel:  $module_parent_sel"

[ "$creation_sel" = "RmL" ] && {
    echo
    echo_chk_clrd_start 1 31 "List of all submodule of the module to be removed"
    cmd_local_module.sh childlist "$sm_path"
    echo_chk_clrd_end
    echo
}

# *********************************
# 9. Wait to permit the info check
{
    [ "$creation_sel" = "FMR" ] ||
    [ "$creation_sel" = "PlR" ] ||
    [ "$creation_sel" = "GR_" ] ||
    [ "$creation_sel" = "Crt" ] ||
    [ "$creation_sel" = "CtR" ] ||
    [ "$creation_sel" = "Cln" ] ||
    [ "$creation_sel" = "Adb" ] ||
    [ "$creation_sel" = "StU" ] ||
    [ "$creation_sel" = "SRU" ] ||
    [ "$creation_sel" = "SUP" ] ||
    [ "$creation_sel" = "Psh" ] ||
    [ "$creation_sel" = "Prh" ] ||
    [ "$creation_sel" = "RmL" ] ||
    [ "$creation_sel" = "RmR" ] 
} && {

    echo
    echo_chk_clrd 1 31 "2. Check the above list of parameter, then select your choice?"
    list_values=$( 
        echo "Continue: It's all OK      -> perform the commands"
        echo "Exit:     Wrong parameters -> stop di execution of current script"
    )
    selecting_option              "choice_sel"
    choice_sel=${choice_sel%:*}
    echo_chk_clrd 1 33 "Selected: $choice_sel"

    [ "$choice_sel" = "Exit" ] && exit 0

}

# *********************************
# 10. Perfoming actions


# *********************************
# 10. Update "remote_module_device" config file
{
    [ "$creation_sel" = "SRI" ]
} && {

    {
        [ "$creation_sel" = "SRI" ]
    } && (
        [ "$sm_path_ignore" ] && {
            cmd_local_module.sh -d gitignore "$sm_path" "$sm_path_ignore"
        } || {
            cd "$toplevel/$sm_path" && {
                git_foreach_top_gitignore_sync.sh -d
            }
        }
    )

}

# *********************************
# 10. Update "remote_module_device" config file
{
    [ "$creation_sel" = "GRA" ]
} && {

    {
        [ "$creation_sel" = "GRA" ]
    } && (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            echo_dbg
            echo_chk_clrd 1 35 "==============="
            echo_dbg
            git_sub_repo_local_cmd.sh gitadd
            {
                [ "$creation_sel" = "GRA" ]
            } && {
                git submodule foreach --recursive "{
                    git_sub_repo_local_cmd.sh gitadd
                }"
            }
        }
    )

}

# *********************************
# 10. Update "remote_module_device" config file
{
    [ "$creation_sel" = "GRC" ]
} && {

    {
        [ "$creation_sel" = "GRC" ]
    } && (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            echo_dbg
            echo_chk_clrd 1 35 "==============="
            echo_dbg
            git_sub_repo_local_cmd.sh gitcommit "$sm_path"
            {
                [ "$creation_sel" = "GRC" ]
            } && {
                git submodule foreach --recursive "{
                    git_sub_repo_local_cmd.sh gitcommit \"$sm_path\"
                }"
            }
        }
    )

}

# *********************************
# 10. Update "remote_module_device" config file
{
    [ "$creation_sel" = "GRL" ]
} && {

    {
        [ "$creation_sel" = "GRL" ]
    } && (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            echo_dbg
            echo_chk_clrd 1 35 "==============="
            echo_dbg
            git_sub_repo_local_cmd.sh gitlog
            {
                [ "$creation_sel" = "GRL" ]
            } && {
                git submodule foreach --recursive "{
                    git_sub_repo_local_cmd.sh gitlog
                }"
            }
        }
    )
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

# *********************************
# 10. Update "remote_module_device" config file
{
    [ "$creation_sel" = "GRS" ]
} && {

    {
        [ "$creation_sel" = "GRS" ]
    } && (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            GRS_cmd
        }
    )

}

# *********************************
# 10. Update "remote_module_device" config file
{
    [ "$creation_sel" = "GR_" ]
} && {

    {
        [ "$creation_sel" = "GR_" ]
    } && (
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

# *********************************
# 10. Update "remote_module_device" config file
{
    [ "$creation_sel" = "FMR" ]
} && {

    {
        [ "$creation_sel" = "FMR" ]
    } && (
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

# *********************************
# 10. Update "remote_module_device" config file
{
    [ "$creation_sel" = "PlR" ]
} && {

    {
        [ "$creation_sel" = "PlR" ]
    } && (
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

# *********************************
# 10. Update "remote_module_device" config file
{
    [ "$creation_sel" = "StU" ] ||
    [ "$creation_sel" = "SRU" ] ||
    [ "$creation_sel" = "SUP" ]
} && {

    {
        [ "$creation_sel" = "StU" ] ||
        [ "$creation_sel" = "SRU" ] ||
        [ "$creation_sel" = "SUP" ]
    } && (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            git_sub_repo_remote_url_set.sh -d -e -f $sru_priority_sel $storage_sel $protocol_sel $address_sel

            {
                [ "$creation_sel" = "SRU" ] ||
                [ "$creation_sel" = "SUP" ]
            } && {
                git submodule foreach --recursive "{
                    git_sub_repo_remote_url_set.sh -d -e -f $sru_priority_sel $storage_sel $protocol_sel $address_sel
                    true
                }"
            }
        }
    )

}

# *********************************
# 10. Update "remote_module_device" config file
{
    [ "$creation_sel" = "Crt" ] ||
    [ "$creation_sel" = "Cln" ]
} && {

    export storage_sel
    export protocol_sel
    export address_sel
    export repogroup_sel
    export module_parent_sel

    export toplevel
    export sm_path

}


{
    [ "$creation_sel" = "Adb" ] 
} && {

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

# *********************************
# 10. Cretaing new local repo
{
    [ "$creation_sel" = "Crt" ] 
} && {

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

# *********************************
# 10. Cloning remote repo in local
{
    [ "$creation_sel" = "Cln" ] 
} && {
    # check if submodule exists
    {
        [ -d "$toplevel" ] && {
            [ -f "$toplevel/.git" ] ||
            [ -d "$toplevel/.git" ]
        }
    } && {
        (
            cd "$toplevel"
            git_sub_repo_local_crt_cln.sh clone "$remote_module_url" "$sm_path" || exit 1
        ) || {
            exit 1
        }
    } || {
        echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid submodule git root directory"
        exit 1
    }
}


# *********************************
# 9. Pushing
{
    [ "$creation_sel" = "SUP" ] ||
    [ "$creation_sel" = "Psh" ] ||
    [ "$creation_sel" = "Prh" ] 
} && {

    (
        # perform push
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            func_module_push.sh -d -e

            {
                [ "$creation_sel" = "SUP" ] ||
                [ "$creation_sel" = "Prh" ] 
            } && {
                git submodule foreach --recursive "{
                    func_module_push.sh -d -e
                }"
                [ $? -eq 4 ] && exit 4
                true
            }
            true
        } || {
            echo_chk_clrd 1 31 "The \"$toplevel\" directory does not exist or is not a valid submodule git root directory"
            exit 1
        }
    )



}


# *********************************
# 9. Creating new empty remote repo
{
    [ "$creation_sel" = "CtR" ] 
} && {

    cmd_remote_storage.sh chkmount && {
        cmd_remote_storage.sh newremote $module_remote_name && {
            list_values=$(cmd_remote_storage.sh lsrepogroup) && {
                list_option "The new list of remote module of \"$repogroup_sel\" group "
            }

        } || {
            echo_chk_clrd 1 31 "ERROR - the new remote repo \"$module_remote_name\" creation procedure is terminated with error"
            exit 1
        }

    } || {
        echo_chk_clrd 1 31 "ERROR - No remote storage is mounted"
        exit 1
    }
}

# *********************************
# 9. Creating new empty remote repo
{
    [ "$creation_sel" = "RmR" ] 
} && {

    (
        cd "$PATH_REPO_MAIN" && {
            export git_foreach_storage=$storage_sel
            export git_foreach_machine=$protocol_sel
            export git_foreach_address=$address_sel
            export git_foreach_repogroup=$repogroup_sel

            echo_dbg_clrd 1 33 "storage_sel:   $storage_sel"
            echo_dbg_clrd 1 33 "protocol_sel:  $protocol_sel"
            echo_dbg_clrd 1 33 "address_sel:   $address_sel"
            echo_dbg_clrd 1 33 "repogroup_sel: $repogroup_sel"

            cmd_remote_storage.sh -d chkmount && {
                cmd_remote_storage.sh -d removeremoterepo $module_remote_name && {
                    echo_dbg_clrd 1 32 "OK - the remote repo \"$module_remote_name\" has been removed properly"
                } || {
                    echo_chk_clrd 1 31 "ERROR - the remote repo \"$module_remote_name\" has not been removed"
                    exit 1
                }

            } || {
                echo_chk_clrd 1 31 "ERROR - No remote storage is mounted"
                exit 1
            }
        }
    )
}



# *********************************
# 9. Check url info
{
    [ "$creation_sel" = "Crt" ] ||
    [ "$creation_sel" = "StU" ] ||
    [ "$creation_sel" = "Cln" ] ||
    [ "$creation_sel" = "Chk" ]
} && {

    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            func_module_url_chk.sh -d
        }
    )
}

# *********************************
# 9. Check url info
{
    [ "$creation_sel" = "Crk" ]
} && {

    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            git_foreach_top_repo_remote_url_chk.sh
        } 
    )
}

# *********************************
# 9. Check url info
{
    [ "$creation_sel" = "Crt" ] ||
    [ "$creation_sel" = "CkS" ] ||
    [ "$creation_sel" = "CrS" ]
} && {

    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            git_sub_repo_local_cmd.sh -d status

            [ "$creation_sel" = "CrS" ] && {
                git submodule foreach --recursive "{
                    git_sub_repo_local_cmd.sh -d status
                }"
            }
        } 
    )
}

# *********************************
# 9. Remove local repo/module
{
    [ "$creation_sel" = "RmL" ] 
} && {

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

# *********************************
# 9. set url for deinit sub-modules; this command is not recursively
{
    [ "$creation_sel" = "SnU" ] 
} && {

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

# *********************************
# 9. set url for deinit sub-modules; this command is not recursively
{
    [ "$creation_sel" = "BSt" ] 
} && {


    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path
            cmd_local_module.sh -d branchstatus $sm_path
            git submodule foreach --recursive "{
                cmd_local_module.sh -d branchstatus "\$sm_path"
                true
            }"
        }
    )

}

# *********************************
# 9. set url for deinit sub-modules; this command is not recursively
{
    [ "$creation_sel" = "BCO" ]
} && {

    (
        {
            [ -f "$toplevel/$sm_path/.git" ] ||
            [ -d "$toplevel/$sm_path/.git" ]
        } && {
            export toplevel
            export sm_path
            cd "$toplevel/$sm_path"
            cmd_local_module.sh -d branchstatus $sm_path
            branch_current=$(git symbolic-ref --short -q HEAD) && {
                echo_dbg_clrd 1 32 "Current branch is: $branch_current (\"$sm_path\" module)"
                git submodule foreach --recursive "{
                    cmd_local_module.sh -d checkout \"\$sm_path\" \"$branch_current\"
                    true
                }"
            } || {
                echo_dbg_clrd 1 31 "Reference Module \"$1\", from which to retrive the branch name is in DETACHED MODE"
            }
        } || {
                echo_dbg_clrd 1 31 "Module selected (\"$sm_path\") is not valid"
        }
    )

}

# *********************************
# 9. set url for deinit sub-modules; this command is not recursively
{
    [ "$creation_sel" = "RfR" ]
} && {

    (
        cd "$toplevel/$sm_path" && {
            export toplevel
            export sm_path

            echo_dbg
            echo_dbg_clrd 1 33 "--------------"
            cmd_local_module.sh -d configfetch $sm_path
            git submodule foreach --recursive "{
                cmd_local_module.sh -d configfetch \"\$sm_path\"
                true
            }"
        }
    )

}

# **** End   script
echo_end_script
# **** End   script

