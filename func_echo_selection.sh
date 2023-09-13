# ********************************************************
function read_selection {
    while IFS= read -r answer
    do
        {
            [ -n "$answer" ] &&
            [ "$answer" -eq "$answer" ] 2>/dev/null
        } && {
            # parameter is an integer
            [ $answer -le $max_option ] && break || echo "Value too great"
        }
    done < /dev/stdin
}

# ********************************************************
function read_dash_selection {
    while IFS= read -r answer
    do
        {
            [ -n "$answer" ] &&
            [ "$answer" -eq "$answer" ] 2>/dev/null
        } && {
            # parameter is an integer
            [ $answer -le $max_option ] && break || echo "Value too great"
        } || {
            [ "$answer" = "q" ] && exit 0 || echo "String value not permitted"
        }
    done < /dev/stdin
}

# ********************************************************
function get_string_space   {
    tmp_id=$2
    [ $((tmp_id%2)) -eq 0 ] && char="." || char="-"
    string_space="$char"
    counter=$1
    while true
    do
        [ $counter -eq 0 ] && break || ((counter--))
        string_space="$string_space   $char"
    done
}

# ********************************************************
function display_module_list_pipe {
    echo_chk_clrd 1 33 "Below the list of possible value:"
    item_id=0
    while IFS= read item; do
        ((item_id++))
        first_field=$(echo $item | cut -d: -f1)
        {
            [ -n "$first_field" ] &&
            [ "$first_field" -eq "$first_field" ] 2>/dev/null
        } && {
            item_level=$first_field
            get_string_space $item_level $item_id
            module_sm_path=${item##*:}
            echo_clrd 1 33 "$string_space($item_level) $module_sm_path"
        } || {
            compare_string="$first_field"
            item_level=$(echo $item | cut -d: -f2)
            get_string_space $item_level $item_id
            module_sm_path=${item##*:}
            [ $compare_string = "cfgw" ] && {
                echo_clrd 1 33 "$string_space($item_level) $module_sm_path"
            } || {
                echo_clrd 1 31 "$string_space($item_level) $module_sm_path <$compare_string>"
            }
        }
    done | cat -n
}

# ********************************************************
function display_module_list {
    echo_chk_clrd 1 33 "Below the list of possible value:"
    echo "$(
        for item in ${list_values[@]}
        do
            compare_string=$(echo $item | cut -d: -f1)
            item_level=$(echo $item | cut -d: -f2)
            get_string_space $item_level
            module_sm_path=${item##*:}
            [ $compare_string = "cfgw" ] && {
                echo_clrd 1 33 "$string_space<$item_level>$module_sm_path"
            } || {
                echo_clrd 1 31 "$string_space<$item_level>$module_sm_path <$compare_string>"
            }
        done
    )" | cat -n
}

# ********************************************************
function display_list {
    echo_chk_clrd_start 1 33 "Below the list of possible value:"
    echo "$list_values" | cat -n
    echo_chk_clrd_end
}

# ********************************************************
function display_list_pipe {
    echo_chk_clrd_start 1 33 "Below the list of possible value:"
    while IFS= read item; do
        echo "$item" 
    done | cat -n
    echo_chk_clrd_end
}

# ********************************************************
function selecting_option {
    echo_chk_clrd_start 1 33 "Below the list of possible value:"
    echo "$list_values" | cat -n
    max_option=$(echo "$list_values" | wc -l)
    echo_chk_clrd_end
    read_selection $max_option
    result=$(echo "$list_values" | head -n$answer | tail -1)
    eval "$1=\"$result\""
    eval result=\"\$$1\"
    echo_clrd_2 1 32 "result: " 1 31 "$result"
}

# ********************************************************
function selecting_dash_option {
    echo_chk_clrd_start 1 33 "Below the list of possible value:"
    echo "$list_values" | cat -n
    max_option=$(echo "$list_values" | wc -l)
    echo_chk_clrd_end
    read_dash_selection $max_option
    result=$(echo "$list_values" | head -n$answer | tail -1)
    eval "$1=\"$result\""
    eval result=\"\$$1\"
    echo_clrd_2 1 32 "result: " 1 31 "$result"
}

# ********************************************************
function selecting_option_dash_pipe {

    echo "$module_list_std" | display_module_list_pipe
    max_option=$(echo "$module_list_std" | wc -l)
    read_dash_selection $max_option
    answer_linked=$(echo "$module_list_std" | head -n$answer | tail -1)
    eval "$1=\"$answer_linked\""
    eval answer_linked=\"\$$1\"
    echo_clrd_2 1 32 "answer_linked: " 1 31 "$answer_linked"

}


# ********************************************************
function selecting_option_dash_general_pipe {

    echo "$option_list_values" | display_list_pipe
    max_option=$(echo "$option_list_values" | wc -l)
    read_dash_selection $max_option
    answer_linked=$(echo "$option_list_values" | head -n$answer | tail -1)
    eval "$1=\"$answer_linked\""
    eval answer_linked=\"\$$1\"
    echo_clrd_2 1 32 "answer_linked: " 1 31 "$answer_linked"

}


# ********************************************************
function echo_parameter_value {
    #eval "$1=\"$result\""
    eval result=\"\$$1\"
    echo_clrd_2 1 32 "$1: " 1 31 "$result"
}

# ********************************************************
function list_option {
    echo
    echo_chk_clrd_start 1 33 "$1"
    echo "$list_values" | cat -n
    echo_chk_clrd_end
}



# ****
# from git_sub_repo_dash.sh

# ********************************************************
function read_string {
    while IFS= read -r answer
    do
        [ "$answer" ] && break
    done < /dev/stdin

    answer=${answer%/}

    eval "$1=\"$answer\""
    eval result=\"\$$1\"
    echo_clrd_2 1 32 "result: " 1 31 "$result"
}

