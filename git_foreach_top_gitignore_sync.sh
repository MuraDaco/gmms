#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh

module_name=$(basename $PWD)
# **** Start script
echo_start_script $module_name
# **** Start script

export SECTION_MARK_START="# ____ Start ____ $module_name"
export SECTION_MARK_END="# ____ End   ____ $module_name"
[ -f ".gitignore_modules" ] && {
    echo_dbg_clrd 1 32 "OK - .gitignore_modules file exists"
    export FILE_GITIGNORE="$PWD/.gitignore_modules"
} || {
    echo_dbg_clrd 1 33 "WARNING - (PWD: $PWD) .gitignore_modules file does not exist"
    export FILE_GITIGNORE=
}


git submodule foreach --recursive "{
    git_sub_gitignore_delete_section.sh  -d
    git_sub_gitignore_create_section.sh  -d
    git_sub_gitignore_add.sh             -d
    git_foreach_top_gitignore_sync.sh    -d
    true
    }"
    

# **** End   script
echo_end_script $module_name
# **** End   script
