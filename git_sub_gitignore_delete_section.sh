#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh

{
    [ ! "$1" ]            ||
    [ "$1" = "$sm_path" ]
} && {

    [ -f .gitignore ] && {
        start_line=$(grep -n "$SECTION_MARK_START" .gitignore | cut -f1 -d:)
        end_line=$(grep   -n "$SECTION_MARK_END"   .gitignore | cut -f1 -d:)
    
        echo_dbg_clrd 1 33 "start_line: -> $start_line"
        echo_dbg_clrd 1 33 "end_line:   -> $end_line"
    
        [ "$start_line" = "" ] && start_line=0
        [ "$end_line"   = "" ] && end_line=0
    
        {
            [ $start_line -gt 0 ] &&
            [ $end_line   -gt 0 ] 
        } && {
        
            total_line=$(wc -l < .gitignore)
            ignore_file=$(cat .gitignore)
            before_start=${ignore_file%"$SECTION_MARK_START"*}
            after__end=${ignore_file##*"$SECTION_MARK_END"}
    
            [ $start_line -gt 1 ] && {
                echo "$before_start"  > .gitignore
                [ $end_line -lt $total_line ] || {
                    echo "$after__end"   >> .gitignore
                }
            } || {
                [ $end_line -eq $total_line ] && {
                    echo_dbg_clrd 1 36 "WARNING - Perhaps .gitignore file is empty "
                    rm .gitignore
                    touch .gitignore
                } || {
                    echo "$after__end"   > .gitignore
                }
            }
    
        } || {
            echo_dbg_clrd 1 31 "WARNING - No section exists or <start mark>/<end mark> has gone "
        }
    
    
    } || {
        echo_dbg_clrd 1 33 "WARNING - .gitignore file does not exist and now it will be created"
        touch .gitignore
    }

}


