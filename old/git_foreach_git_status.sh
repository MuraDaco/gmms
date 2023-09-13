#!/bin/bash

git submodule foreach --recursive '{
    echo
    echo "***************** start \"$name\" module"
    echo
    git status
    }'
