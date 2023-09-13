# --------------------------------------
# ****** _____ OPTIONS MANAGEMENT ******

case "$1" in
    --module | -m)
        shift
        
    ;;
    *)
        [ $unknown_par_exit -eq 1 ] \
        && { # exit because there are unknown parameters 
             echo_dbg "check \"$option_short\" option: unknown parameters!! Exit 1"; exit 1;      } \
        || { # continue to check other options
             echo_dbg "check \"$option_short\" option: no known parameters - continue !!"; break; }
    ;;
esac

# ****** END - OPTIONS MANAGEMENT ******
# --------------------------------------
