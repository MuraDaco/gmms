#!/bin/bash

[ "$PATH_REPO_MAIN" ] && {
    [ -d "$1/$FOLDER_SCRP_DIR" ] || mkdir "$1/$FOLDER_SCRP_DIR"

    [ -d "$1" ] && {
        rsync -av --delete $PATH_REPO_MAIN_SCRP_DIR/sync/ "$1"/$FOLDER_SCRP_DIR/sync
    } || {
        echo "ERROR - no valid parameter is given - set submodule path"
        exit 1
    }
} || {
    echo "ERROR - \"PATH_REPO_MAIN\" variable is not defined"
    exit 1
}
