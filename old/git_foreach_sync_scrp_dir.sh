#!/bin/bash

git submodule foreach --recursive '{
        rsync -av --delete $PATH_REPO_MAIN_SCRP_DIR/sync/ $FOLDER_SCRP_DIR/sync
        echo
        echo "PATH_REPO_MAIN: $PATH_REPO_MAIN"
        echo
        true
    }' 
