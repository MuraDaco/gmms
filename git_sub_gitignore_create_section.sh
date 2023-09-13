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
            echo_dbg_clrd 1 31 "WARNING - .gitignore file does not exist and now it will be created"
            exit 1
        }
    
    
    
    
    
        {
            [ "$start_line" = "" ] && \
            [ "$end_line"   = "" ] 
        } && {
        
            [ -f .gitignore ] && gitignore_file=$(cat .gitignore)
            echo "$SECTION_MARK_START"  > .gitignore
            echo                       >> .gitignore
            echo                       >> .gitignore   
            echo                       >> .gitignore   
            echo "$SECTION_MARK_END"   >> .gitignore
            echo "$gitignore_file"     >> .gitignore
    
        } || {
            echo_dbg_clrd 1 31 "WARNING - One of the two marker or both exists"
        }
    
    } || {
        echo_dbg_clrd 1 33 "WARNING - No \".gitignore_modules\" file of parent module exists"
    }

}
