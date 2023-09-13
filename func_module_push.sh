#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_echo_selection.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

# ********************************************************
# ********************************************************

# **** Start script
echo_start_script
# **** Start script

    export git_foreach_storage=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onstorage)
    export git_foreach_machine=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onmachine)
    export git_foreach_address=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.onrouter )
    export git_foreach_repogroup=

    echo_chk_clrd 1 32 "Perfoming \"git push\" command on module \"$sm_path\""
    cmd_remote_storage.sh chkmount && {
        cmd_remote_storage.sh chkremoterepopath && {
            git push --set-upstream origin $(git branch --show-current) && {
                echo_dbg_clrd 1 32 "OK - module \"$sm_path\": \"git push\" command terminated properly"
                echo_clrd_exit 1 34 0
            } || {
                echo_chk_clrd  1 31 "ERROR - ($toplevel/$sm_path) Some issue occurred performing \"git push\" command"

                echo_chk_clrd 1 32 "Do you want to continue or exit?"

                # question
                list_values=$( 
                    echo "Continue"
                    echo "Exit"
                )
                selecting_option              "choice_sel"
                choice_sel=${choice_sel%:*}
                echo_chk_clrd 1 33 "Selected: $choice_sel"

                [ "$choice_sel" = "Exit" ] && echo_clrd_exit 1 34 4     

            }
        } || {
            [ $? -eq 3 ] && {
                module_remote_name=$(basename "$sm_path").git
                echo_chk_clrd 1 32 "Do you want to create the remote repository (\"$module_remote_name\") of the selected module/local repo \"$sm_path\" and then perform the push on it?"

                # question
                list_values=$( 
                    echo "Continue: It's all OK      -> perform the commands"
                    echo "Exit:     Wrong parameters -> stop di execution of current script"
                )
                selecting_option              "choice_sel"
                choice_sel=${choice_sel%:*}
                echo_chk_clrd 1 33 "Selected: $choice_sel"

                [ "$choice_sel" = "Exit" ] && echo_clrd_exit 1 34 0

                # action                
                cmd_remote_storage.sh newremote $module_remote_name && {
                    list_values=$(cmd_remote_storage.sh lsrepogroup) && {
                        remote_module_url=$(git config --get-all remote.origin.url)
                        group=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.repogroup ) 

                        list_option "The new list of remote module of \"$group\" group on \"$(dirname $remote_module_url)\" remote directory"
                        git push --set-upstream origin $(git branch --show-current) && {
                            echo_dbg_clrd 1 32 "OK - \"git push\" command terminated properly"
                            echo_clrd_exit 1 34 0
                        } || {
                            echo_chk_clrd 1 31 "ERROR - Some issue occurred performing \"git push\" command"
                            echo_clrd_exit 1 34 2
                        }
                    }
                } || {
                    echo_chk_clrd 1 31 "ERROR - the new remote repo \"$module_remote_name\" creation procedure is terminated with error"
                    echo_clrd_exit 1 34 1
                }
            }
        }
    }

# **** End   script
echo_end_script
# **** End   script
