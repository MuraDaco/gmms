#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh


# **** Start script
echo_start_script
# **** Start script

parent_module=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get     submodule.$sm_path.parent ) && {

    echo_dbg_clrd 1 32 "parent_module:    $parent_module"
    echo_dbg_clrd 1 32 "toplevel:         $toplevel"
    echo_dbg_clrd 1 32 "sm_path_abs:      $toplevel/$sm_path"
    echo_dbg_clrd 1 32 "sm_path:          $sm_path"
    echo_dbg

    echo_dbg_clrd 1 33 "\"$PWD\" is the current directory where all commands of the procedure will be performed"
   
    [ -f "$sm_path/.git" ] && {
        submodule_git_folder=$(cat "$sm_path/.git")
        submodule_git_folder=$PATH_REPO_MAIN/.git/${submodule_git_folder#*/.git/}

        
        [ -d "$submodule_git_folder" ] && {
            echo_dbg_clrd 1 33 "The \".git\" directory of \"$sm_path\" submodule is: \"$submodule_git_folder\""
        } || {
            echo_dbg_clrd 1 33 "The \".git\" directory of \"$sm_path\" submodule \"$submodule_git_folder\" does not exist"
        }
    }

    echo_chk
    echo_chk_clrd 1 33 "Step 1 -> removing submodule section in \"remote_device_modules\" config file"
    cmd_local_module.sh remove "$sm_path"

    echo_chk
    echo_chk_clrd 1 33 "Step 2 -> Executing \"deinit\" submodule \"$sm_path\" procedure"
    git submodule deinit -f "$sm_path" && {
        echo_chk_clrd 1 32 "OK - \"git submodule deinit -f ... \" command is succesfully executed"
    } || {
        echo_chk_clrd 1 31  "WARNING - No valid \"sm_path\" (\"$sm_path\") parameter"
    }

    echo_chk
    echo_chk_clrd 1 33 "Step 3 -> remove section from \".git/config\" config file"
    git config --remove-section submodule."$sm_path"  > /dev/null 2>&1 && {
        echo_chk_clrd 1 32 "OK - Forcefully removed submodule section in \".git/config\" config file by \"git config\" command performing"
    } || {
        echo_chk_clrd 1 32 "OK - Submodule section was properly removed by \"deinit\" command"
    }

    echo_chk
    echo_chk_clrd 1 33 "Step 4 -> remove section from \".gitmodules\" config file"
    git config -f .gitmodules --remove-section submodule."$sm_path"  > /dev/null 2>&1 && {
        echo_chk_clrd 1 32 "OK - Forcefully removed submodule section in \".gitmodules\" config file by \"git config\" command performing"
    } || {
        echo_chk_clrd 1 32 "OK - Submodule section was properly removed by \"deinit\" command"
    }

    echo_chk
    echo_chk_clrd 1 33 "Step 5 -> removing \"$sm_path\" working folder by \"git rm -f\" command"
    [ -d "$sm_path" ] && {
        git rm -f "$sm_path" && {
            echo_chk_clrd 1 32 "OK - Properly removed \"$sm_path\" working module folder by \"git rm -f ... \" command "
        } || {
            echo_dbg_clrd 1 31 "WARNING - Some issues executing <git rm -f \"$sm_path\"> command "

            [ -d "$sm_path" ] && {
                echo_dbg_clrd 1 33 "Forcefully removing submodule by \"rm -rf\" command"
                rm -rf "$sm_path" && {
                    echo_chk_clrd 1 32 "OK - the \"$sm_path\" folder is properly removed"
                } || {
                    echo_chk_clrd 1 31 "WARNING - Some issues occurred during the \"$sm_path\" folder removing"
                }
            } || {
                echo_chk_clrd 1 32 "OK - The \"$sm_path\" submodule folder was properly removed by \"git rm -f\" command"
            }
        }
    } || {
        echo_chk_clrd 1 32 "OK - The \"$sm_path\" folder does not exist, is already removed"
    }

    echo_chk
    echo_chk_clrd 1 33 "Step 6 -> remove the \".git\" hidden folder (\"$submodule_git_folder\") of submodule \"$sm_path\""
    [ "$submodule_git_folder" ] && {
        rm -rf "$submodule_git_folder" && {
            echo_chk_clrd 1 32 "OK - the \"$submodule_git_folder\" folder is properly removed"
        } || {
            echo_chk_clrd 1 31 "WARNING - Some issues occurred during the \"$submodule_git_folder\" folder removing"
        }
    } || {
        echo_chk_clrd 1 32 "OK - The \".git\" hidden folder does not exist, is already removed"
    }

    echo_chk
    echo_chk_clrd 1 33 "Step 7 -> unstaging"
    git status | grep "new file" | grep "$sm_path" && git restore --staged "$sm_path"
    echo_chk

    true

} || {
    echo_chk_clrd 1 31       "No valid module \"$sm_path\" is given"
    echo_clrd_exit 1 34 1
}


# **** Start script
echo_start_script
# **** Start script

