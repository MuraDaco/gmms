#!/bin/bash

[ "$PATH_REPO_MAIN" ] && {
    [ -d "$1" ] && {
        module_name=$(basename "$1")
        repo_main_name=$(basename "$PATH_REPO_MAIN")
        repo_main_vscode_ws="$PATH_REPO_MAIN/$repo_main_name.code-workspace"

        [ -f "$repo_main_vscode_ws" ] && {
            cp "$repo_main_vscode_ws" "$1"
            mv "$1/$repo_main_name.code-workspace" "$1/$module_name.code-workspace"
        }
        
    } || {
        echo "ERROR - no valid parameter is given - set submodule path"
        exit 1
    }
} || {
    echo "ERROR - \"PATH_REPO_MAIN\" variable is not defined"
    exit 1
}
