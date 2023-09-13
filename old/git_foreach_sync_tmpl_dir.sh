#!/bin/bash

git submodule foreach --recursive '{
        module_name=$(basename "$PWD")
        repo_main_name=$(basename "$PATH_REPO_MAIN")
        repo_main_vscode_ws="$PATH_REPO_MAIN/$repo_main_name.code-workspace"

        [ -f "$repo_main_vscode_ws" ] && {
            echo "syncing \"$repo_main_vscode_ws\" file"
            cp "$repo_main_vscode_ws" .
            mv "./$repo_main_name.code-workspace" "./$module_name.code-workspace"
        }

        rsync -av "$PATH_REPO_MAIN/tmpl/" .
        true
    }' 
