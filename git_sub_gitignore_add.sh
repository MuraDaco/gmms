#!/bin/bash

source $PATH_REPO_MAIN_SCRP_DIR/func_echo.sh

{
    [ ! "$1" ]            ||
    [ "$1" = "$sm_path" ]
} && {

    [ "$FILE_GITIGNORE" ] && {
    
        [ -f .gitignore ] && {
            start_line=$(grep -n "$SECTION_MARK_START" .gitignore | cut -f1 -d:)
            end_line=$(grep   -n "$SECTION_MARK_END"   .gitignore | cut -f1 -d:)
        } || {
            echo_dbg_clrd 1 31 "WARNING - .gitignore file does not exist"
            exit 1
        }
    
        [ "$start_line" = "" ] && start_line=0
        [ "$end_line"   = "" ] && end_line=0
    
        {
            [ $start_line -gt 0 ] && \
            [ $end_line   -gt 0 ] 
        } && {
            total_line=$(wc -l < .gitignore)
    
            line_to_insert_begin=$((start_line + 1))
            line_to_insert_bottom=$((total_line - start_line - 1))
    
            before_line_txt=$(head -n $line_to_insert_begin < .gitignore)
            after_line_txt=$(tail -n $line_to_insert_bottom < .gitignore)
    
            echo "$before_line_txt" > .gitignore
            cat "$FILE_GITIGNORE"  >> .gitignore
            echo "$after_line_txt" >> .gitignore
            echo_dbg_clrd 1 32 ".... end adding"
        } || {
            echo_dbg_clrd 1 31 "WARNING - No \"repo__main\" section exists or, <start mark>/<end mark> has gone "
            exit 1
        }
    
    } || {
        echo_dbg_clrd 1 33 "WARNING - No \".gitignore_modules\" file of parent module exists"
    }

}

