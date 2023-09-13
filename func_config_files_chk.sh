

[ "$PATH_REPO_MAIN_CONF_STORAGES" ]   || {
    echo_dbg_clrd 1 31 "ERROR - config storage    file has not been defined"
    exit 1
}

[ "$PATH_REPO_MAIN_CONF_SMODULES" ] || {
    echo_dbg_clrd 1 31 "ERROR - config submodules file has not been defined"
    exit 1
}

true
