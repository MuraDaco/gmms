#!/bin/bash


function echo_chk_clrd {
    echo -e "\033[$1;$2m""dbg msg on stderr -> $3""\033[0;0m" > /dev/stderr
}

function echo_chk_clrd_start {
    echo -e "\033[$1;$2m""$3" > /dev/stderr
}

function echo_chk_clrd_end {
    echo -e "\033[0;0m" > /dev/stderr
}


echo
echo_chk_clrd 1 33 "Executing: \"`basename $0`\" script"
echo_chk_clrd 1 35 "**** START script ************"
echo

[ "$1" ] && {
    export git_foreach_storage="$1"
}

[ "$2" ] && {
    export git_foreach_machine="$2"
}

[ "$3" ] && {
    export git_foreach_address="$3"
}

[ "$4" ] && {
    export sm_path="$4"
} || {
    echo_chk_clrd       1 31 "This command strictly requires four parameters in the following order:"
    echo_chk_clrd_start 1 33 "1. Storage device/partition                                  - for example: \"mypass_2\""
    echo                     "2. Machine (where storage device is mounted)                 - for example: \"onarch\""
    echo                     "3. Address by which getting the connection to remote machine - for example: \"netcp\""
    echo                     "4. Relative Path of submodule                                - for example: \"tstmodules/tst_prj_1\""
    echo
    echo                     "`basename $0` mypass_2 onarch netcp \"tstmodules/tst_prj_1\""
    echo_chk_clrd_end
    exit 1
}

repo_sub_storage_param_get.sh
repo_sub_storage_param_get.sh machine
repo_sub_storage_param_get.sh protocol
repo_sub_storage_param_get.sh address
repo_sub_storage_param_get.sh mount
repo_sub_storage_param_get.sh url
repo_sub_storage_param_get.sh reporemotepath
repo_sub_storage_param_get.sh group
repo_sub_storage_param_get.sh groupremotepath

echo
echo_chk_clrd 1 34 "**** END   script ************"
echo_chk_clrd 1 36 "Ending:    \"`basename $0`\" script"
echo
