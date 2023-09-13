#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh
source $PATH_REPO_MAIN_SCRP_DIR/func_config_files_chk.sh

# **** Start script
echo_start_script
# **** Start script

script_current=$(basename $0)
[ "$1" ] && {
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
    git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --name-only --get-regexp parameter.${script_current%.sh} | cut -d. -f3 > /dev/stderr
    echo_chk_clrd_end
    echo_clrd_exit 1 34 1
}


[ "$cmd" = "archive" ] && {

    str_module=$(basename $sm_path)
    bool_archive=$(git config -f "$PATH_REPO_MAIN_CONF_SMODULES" --get submodule.$sm_path.archive) && {
        echo_dbg
        echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
        echo_dbg

        [ "$bool_archive" == "true" ] && {
            str_date=$(date '+%Y%m%d')
            str_branch=$(git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --get parameter.${script_current%.sh}.archivebranch)
            str_path=$(  git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --get parameter.${script_current%.sh}.archivedir)
            str_format=$(git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --get parameter.${script_current%.sh}.archiveformat)
            str_build_number=$(git describe --tags $str_branch)
            echo "Archiving $str_module module ..."
            str_path_file="$str_path/$str_date""_$str_build_number""_$str_module.$str_format"
            echo "gz file: $str_path_file"
            echo "branch:  $str_branch"
            case "$str_format" in
                "zip")
                    #git archive $str_branch  --prefix="$str_module/" --format=zip > "$str_path_file"
                    git archive $str_branch --format=zip > "$str_path_file"
                ;;
                "tar.gz")
                    #git archive $str_branch  --prefix="$str_module/" | gzip > "$str_path_file"
                    git archive $str_branch | gzip > "$str_path_file"
                ;;
                *)
                    echo_chk_clrd 1 31 "No format selected!!"
                ;;
            esac 
        }
    }
    true

}

[ "$cmd" = "archiveimporting" ] && {

    echo_dbg
    echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
    echo_dbg
    str_module=$(basename $sm_path)
    str_path=$(  git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --get parameter.${script_current%.sh}.archivedir)
    str_format=$(git config -f "$PATH_REPO_MAIN_CONF_OBDASH" --get parameter.${script_current%.sh}.archiveformat)
    str_archive_file=$(find "$str_path" -type f -name "*$str_module.$str_format" | sort -r | head -n1)
    echo "$str_archive_file"
    unzip -uo "$str_archive_file"
}

[ "$cmd" = "gitstatus" ] && {
    echo_dbg
    git status
    echo_dbg
    echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
    echo_dbg
}


[ "$cmd" = "gitadd" ] && {
    echo_dbg
    git add .
    echo_dbg
    echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
    echo_dbg
}

[ "$cmd" = "gitcommit" ] && {
    echo_dbg
    git commit -am "Automatic Recursive Commit from \"$1\" module"
    echo_dbg
    echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
    echo_dbg
}

[ "$cmd" = "gitaddcommitlogstatus" ] && {
    echo_dbg
    git submodule foreach "{
        git_sub_repo_local_cmd.sh gitaddcommitlogstatus \"$1\" \"$2\"
    }"
    echo_chk_clrd 1 33 "------ Performing add    ---------"
    git add .
    echo_chk_clrd 1 33 "------ Performing commit ---------"
    git commit -am "AutoRecursiveCommit from <$1> module: $2"
    echo_dbg
    echo_chk_clrd 1 33 "------ Performing log    ---------"
    echo_dbg
    git log --pretty=oneline --graph --decorate --all | head -n3
    echo_dbg
    echo_dbg
    echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
    echo_dbg
}


function func_get_branch_name_pipe {

    [ -p /dev/stdin ] && {
        while IFS= read item; do
            synchro_flag=$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$item.sync ) && {
                [ "$synchro_flag" = "true" ] && {
                    brc_name="$(              git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$item.prefix  )"
                    brc_name="$brc_name"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$item.name    )"
                    brc_name="$brc_name"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$item.os      )"
                    brc_name="$brc_name"_"$(  git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" --get user.$item.machine )"
                    echo "$brc_name"
                }
            }
        done
    }
}

function func_perform_synchro_branch_check  {
    commit_first_line=$(git log --pretty=oneline --graph --decorate --all | head -n1) && {
        echo_dbg_clrd 1 32  "OK ----> git log"
    } || {
        echo_dbg_clrd 1 31  "ERROR -> git log"
    }
    commit_first_line=${commit_first_line%%)*},
    commit_first_line=${commit_first_line#*(}
    branch_failed_local=0
    branch_failed_remote=0
    owner_branch_local=false
    owner_branch_remote=false
    main_branch_local=false
    main_branch_remote=false
    branch_list=$(
        echo "main"
        git config -f "$PATH_REPO_MAIN_CONF_BRANCHES" -l | cut -d. -f2 | sort | uniq | func_get_branch_name_pipe | sort
        )
    
    for check_branch in ${branch_list[@]}
    do
        {
            [ "$check_branch" = "$1"   ] ||
            [ "$check_branch" = "main" ]
        } && {
            echo "$commit_first_line" | grep " $check_branch," > /dev/null && {
                # owner branch
                [ "$check_branch" = "$1"   ] && owner_branch_local=true || {
                    [ "$check_branch" = "main" ] && main_branch_local=true
                }
                true
            } || {
                ((branch_failed_local++))
            }
        }

        echo "$commit_first_line" | grep " origin/$check_branch," > /dev/null && {
            # owner branch
            [ "$check_branch" = "$1"   ] && owner_branch_remote=true || {
                [ "$check_branch" = "main" ] && main_branch_remote=true || {
                    other_branch_remote=$check_branch
                }
            }
            true
        } || {
            ((branch_failed_remote++))
        }
    done 

}

function func_perform_synchro_branch  {

    synchro_performed=false

    # performing syncro/merge from "other remote branch"
    {
        [ "$other_branch_remote" ]           && 
        [ "$owner_branch_local"  = "false" ]
    } && {
        echo_chk_clrd 1 36 "------ performing syncro/merge from \"other remote branch\"    ---------"
        git checkout $1 && {
            git merge "origin/$other_branch_remote"
            synchro_performed=true
            owner_branch_local=true
        }
    } 

    # performing syncro/push to "owner remote branch"
    {
        [ "$owner_branch_local"  = "true"  ] &&
        [ "$owner_branch_remote" = "false" ]
    } && {
        echo_chk_clrd 1 36 "------ performing syncro/push to \"owner remote branch\"    ---------"
        git checkout $1 && {
            git push
            synchro_performed=true
        }
    } 

    # performing syncro/merge from "owner local branch" or "main remote branch" to "main local branch"
    {
        [ "$owner_branch_local"  = "true"  ] &&
        [ "$main_branch_local"   = "false" ]
    } && {
        echo_chk_clrd 1 36 "------ performing syncro/merge from \"owner local branch\" or \"main remote branch\" to \"main local branch\"    ---------"
        git checkout main && {
            [ "$main_branch_remote" = "true" ] && {
                git merge
                true
                synchro_performed=true
            } || {
                git merge $1
                synchro_performed=true
                main_branch_local=true
            }
        }

    } 

    # performing syncro/push to "main remote branch"
    {
        [ "$main_branch_local"  = "true"  ] &&
        [ "$main_branch_remote" = "false" ]
    } && {
        echo_chk_clrd 1 36 "------ performing syncro/push to \"main remote branch\"    ---------"
        git checkout main && {
            git push
            synchro_performed=true
        }
    } 


}

function func_status_synchro_branch_display {
    [ $branch_failed_local -eq 0 ] && {
        echo_chk_clrd 1 32 "local  - Synchro OK - all branches are synchronized"
    } || {
        [ "$owner_branch_local" = "true" ] && {
            [ "$main_branch_local" = "true" ] && {
                echo_chk_clrd 1 33 "local  - Synchro OK but ... the other user is not yet synchronized"
            } || {
                echo_chk_clrd 1 35 "local  - Synchro at half - \"main\" branch is not yet synchronized"
            }
        } || {
            echo_chk_clrd 1 31 "local  - Synchro ALL OFF - YOU MUST SYNCHRONIZE YOUR OWNER BRANCH"
        }
    }

    [ $branch_failed_remote -eq 0 ] && {
        echo_chk_clrd 1 32 "remote - Synchro OK - all branches are synchronized"
    } || {
        [ "$owner_branch_remote" = "true" ] && {
            [ "$main_branch_remote" = "true" ] && {
                echo_chk_clrd 1 33 "remote - Synchro OK but ... the other user is not yet synchronized"
            } || {
                echo_chk_clrd 1 35 "remote - Synchro at half - \"main\" branch is not yet synchronized"
            }
        } || {
            echo_chk_clrd 1 31 "remote - Synchro ALL OFF - YOU MUST SYNCHRONIZE YOUR OWNER BRANCH"
        }
    }


    echo_chk_clrd 1 36 "git log ... > $commit_first_line <"
    echo_dbg

}


[ "$cmd" = "synchrobranchcheck" ] && {
    echo_dbg
    ## git submodule foreach "{
    ##     git_sub_repo_local_cmd.sh synchro_check \"$1\"
    ## }"
    echo_chk_clrd 1 33 "------ Performing Check    ---------"
    echo_dbg

    func_perform_synchro_branch_check $1

    func_status_synchro_branch_display

    echo_dbg
    echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
    echo_dbg
}

[ "$cmd" = "synchrobranch" ] && {
    echo_dbg

    echo_chk_clrd 1 33 "------ Performing Check    ---------"
    func_perform_synchro_branch_check $1


    echo_chk_clrd 1 33 "------ Performing Syncro    ---------"
    func_perform_synchro_branch $1

    # performing checkout on "owner branch"
    echo_chk_clrd 1 33 "------ Performing checkout on \"owner branch\" $1   ---------"
    git checkout $1

    [ "$synchro_performed" = "true" ] && {
        echo_chk_clrd 1 33 "------ Performing Check    ---------"
        func_perform_synchro_branch_check $1
        func_status_synchro_branch_display
    }

    echo_dbg
    echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
    echo_dbg
}

[ "$cmd" = "gitfetchmerge" ] && {
    echo_dbg
    git submodule foreach "{
        git_sub_repo_local_cmd.sh gitfetchmerge
    }"
    echo_chk_clrd 1 33 "------ Performing fetch    ---------"
    git fetch
    echo_chk_clrd 1 33 "------ Performing merge ---------"
    git merge
    echo_dbg
    echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
    echo_dbg
}


[ "$cmd" = "gitpull" ] && {
    echo_dbg
    git submodule foreach "{
        git_sub_repo_local_cmd.sh gitpull
    }"
    echo_chk_clrd 1 33 "------ Performing pull    ---------"
    git pull
    echo_dbg
    echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
    echo_dbg
}


[ "$cmd" = "gitlog" ] && {
    echo_dbg
    git log --pretty=oneline --graph --decorate --all | head -n3
    echo_dbg
    echo_chk_clrd 1 35 "=============== $toplevel/$sm_path"
    echo_dbg
}



[ "$cmd" = "status" ] && {
    echo_dbg_clrd 1 33  "Executing \"$cmd\" command ..."
    # check current folder
    {
        [ ! "$PWD" = "$PATH_REPO_MAIN"    ] &&
        [   "$PWD" = "$toplevel/$sm_path" ] 
    } && {
        [ -f ".git" ] && {
            hidden_git_folder=$(cat .git)
            hidden_git_folder=$PATH_REPO_MAIN/.git/${hidden_git_folder#*/.git/}
            [ -d "$hidden_git_folder" ] && {
                echo_dbg
                echo_chk_clrd 1 32 "OK - The \"$sm_path\" submodule has been correctly absorbed"
            } || {
                echo_dbg
                echo_chk_clrd 1 31 "WARNING - Some issue in \"$sm_path\" submodule adding procedure: \".git\" file exists but the \"$hidden_git_folder\" folder does not"
                echo_dbg
            }
        } || {
            echo_dbg
            echo_chk_clrd 1 31 "WARNING - The \"$sm_path/.git\" git submodule file does not exist"
            echo_dbg
            echo_clrd_exit 1 34 1
        }

        path_on_parent_gitmodules=$(git config -f $toplevel/.gitmodules --get-all submodule."$sm_path".path) && {
            echo_chk_clrd 1 32 "OK - The \"$sm_path\" section in parent \".gitmodule\" file exists"
        } || {
            echo_chk_clrd 1 31 "WARNING - The \"$sm_path\" section in parent \".gitmodule\" file has not \"path\" variable or perhaps does not exist"
        }

        active_on_parent_config=$(
            cd $toplevel
            git config --get-all submodule."$sm_path".active
        ) && {
            echo_chk_clrd 1 32 "OK - The \"$sm_path\" section in parent \"config\" file exists"
        } || {
            echo_chk_clrd 1 31 "WARNING - The \"$sm_path\" section in parent \"config\" file has not \"active\" variable or perhaps does not exist"
        }

        echo_clrd_exit 1 34 0
    } || {
        echo_dbg
        echo_chk_clrd 1 33 "Warning - Launch the current command (\"`basename $0`\") under the git root directory of the \"$sm_path\" submodule"
        echo_clrd_exit 1 34 1
    }
}


# **** End   script
echo_end_script
# **** End   script
