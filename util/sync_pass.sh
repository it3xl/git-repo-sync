
function sync_pass(){
    ((++git_sync_pass_num))

    if (( ${changes_detected:-1} != 1 )); then
        # echo '@' Previous sync-pass din not find any changes.
        
        if [[ $env_process_if_refs_are_the_same != 1 ]]; then
            # echo '@' Sync-pass $git_sync_pass_num was interrupted as refs are equal
            return;
        fi;
    fi

    if [[ ! -f "$env_modifications_signal_file" ]]; then
        source "$path_git_sync_util/change_detector.sh"

        if (( $changes_detected != 1 )); then
            echo '@' RESULT: Refs are the same.
            
            if [[ $env_process_if_refs_are_the_same != 1 ]]; then
                echo '@' Sync-pass $git_sync_pass_num was interrupted as refs are equal
                return;
            fi;
        fi
    else
        changes_detected=1

        echo '@' RESULT: Synchronization requested.
        
        remote_refs_a=$(<"$env_modifications_signal_file_a")
        remote_refs_b=$(<"$env_modifications_signal_file_b")
        
        rm -f "$env_modifications_signal_file"
        rm -f "$env_modifications_signal_file_a"
        rm -f "$env_modifications_signal_file_b"
    fi


    ((++git_sync_pass_num_required))
    echo '!' Running $git_sync_pass_num_required sync pass

    track_refs_a=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_a/")
    track_refs_b=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_b/")

    if [[ $env_trace_refs == 1 ]]; then
        echo
        echo remote_refs_a=
        echo "$remote_refs_a"
        echo remote_refs_b=
        echo "$remote_refs_b"
        echo track_refs_a=
        echo "$track_refs_a"
        echo track_refs_b=
        echo "$track_refs_b"
    fi;

    # gawk --file="$path_git_sync_util/gawk/proto.gawk" <(echo)
    # exit


    pre_fetch_processing='pre_fetch_processing.gawk'
    pre_proc_data=$(gawk --file="$path_git_sync_util/gawk/$pre_fetch_processing" \
        <(echo "$remote_refs_a") \
        <(echo "$remote_refs_b") \
        <(echo "$track_refs_a") \
        <(echo "$track_refs_b") \
    )

    if [[ $env_trace_refs == 1 ]]; then
        echo
        echo pre_proc_data is
        echo "$pre_proc_data"
    fi;
    # exit

    mapfile -t pre_proc_list < <(echo "$pre_proc_data")

    fetch_spec1="${pre_proc_list[0]}";
    fetch_spec2="${pre_proc_list[1]}";
    conv_move="${pre_proc_list[2]//$env_awk_newline_substitution/$'\n'}";
    victim_move="${pre_proc_list[3]//$env_awk_newline_substitution/$'\n'}";
    end_of_results="${pre_proc_list[4]}";

    # Let's export for an usage in post_fetch_processing.gawk.
    export conv_move
    export victim_move

    end_of_results_expected='{[end-of-results]}';
    # This comparison must have double quotes on the second operand. Otherwise it doesn't work.
    if [[ $end_of_results != "$end_of_results_expected" ]]; then
        echo '@' ERROR: An unexpected internal processing results end. Exit.
        echo
        
        # !!! EXIT !!!
        exit 2002;
    fi;

    if [[ $env_trace_refs == 1 ]]; then
        echo fetch_spec1
        echo "$fetch_spec1"
        echo fetch_spec2
        echo "$fetch_spec2"
        echo conv_move
        echo "$conv_move"
        echo victim_move
        echo "$victim_move"
    fi;
    # exit


    if [[ $env_allow_async == 1 && -n "$fetch_spec1" && -n "$fetch_spec2" ]]; then
        echo $'\n>' Fetch Async

        git fetch --no-tags $origin_a $fetch_spec1 > "$path_async_output/fetch1.txt" &
        pid_fetch1=$!
        git fetch --no-tags $origin_b $fetch_spec2 > "$path_async_output/fetch2.txt" &
        pid_fetch2=$!
        
        fetch_report1="> Fetch $origin_a "
        wait $pid_fetch1 && fetch_report1+="(async success)" || fetch_report1+="(async failure)"
        fetch_report2+="> Fetch $origin_b "
        wait $pid_fetch2 && fetch_report2+="(async success)" || fetch_report2+="(async failure)"
        
        echo $fetch_report1
        echo $fetch_spec1
        cat < "$path_async_output/fetch1.txt"

        echo $fetch_report2
        echo $fetch_spec2
        cat < "$path_async_output/fetch2.txt"
    else
        if [[ -n "$fetch_spec1" ]]; then
            echo $'\n>' Fetch $origin_a
            echo $fetch_spec1
            git fetch --no-tags $origin_a $fetch_spec1
        fi;
        if [[ -n "$fetch_spec2" ]]; then
            echo $'\n>' Fetch $origin_b
            echo $fetch_spec2
            git fetch --no-tags $origin_b $fetch_spec2
        fi;
    fi;


    track_refs_a=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_a/")
    track_refs_b=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_b/")

    if [[ $env_trace_refs == 1 ]]; then
        echo
        echo track_refs_a=
        echo "$track_refs_a"
        echo track_refs_b=
        echo "$track_refs_b"
    fi;
    # exit


    proc_data=$(gawk \
        --file="$path_git_sync_util/gawk/post_fetch_processing.gawk" \
        `# --lint` \
        <(echo "$remote_refs_a") \
        <(echo "$remote_refs_b") \
        <(echo "$track_refs_a") \
        <(echo "$track_refs_b") \
    )

    mapfile -t proc_list < <(echo "$proc_data")

    if [[ $env_trace_refs == 1 ]]; then
        echo
        echo proc_data is
        echo "$proc_data"
    fi;
    # exit

    del_spec="${proc_list[0]}";
    notify_del="${proc_list[1]//$env_awk_newline_substitution/$'\n'}";

    push_spec_a="${proc_list[2]}";
    push_spec_b="${proc_list[3]}";
    notify_solving="${proc_list[4]//$env_awk_newline_substitution/$'\n'}";

    post_fetch_spec_a="${proc_list[5]}";
    post_fetch_spec_b="${proc_list[6]}";

    end_of_results="${proc_list[7]}";

    if [[ $env_trace_refs == 1 ]]; then
        echo
        echo del_spec is
        echo "$del_spec"
        echo notify_del is
        echo "$notify_del"
        echo push_spec_a is
        echo "$push_spec_a"
        echo push_spec_b is
        echo "$push_spec_b"
        echo notify_solving is
        echo "$notify_solving"
        echo post_fetch_spec_a is
        echo "$post_fetch_spec_a"
        echo post_fetch_spec_b is
        echo "$post_fetch_spec_b"
    fi;
    # exit

    end_of_results_expected='{[end-of-results]}';
    # This comparison must have double quotes on the second operand. Otherwise it doesn't work.
    if [[ $end_of_results != "$end_of_results_expected" ]]; then
        echo '@' ERROR: An unexpected internal processing results end. Exit.
        echo
        
        # !!! EXIT !!!
        exit 2003
    fi;


    mkdir -p "$path_async_output"

    if [[ -n "$del_spec" ]]; then
        echo $'\n>' Delete branches
        #echo $del_spec
        git branch --delete --force --remotes $del_spec
    fi;

    if [[ -n "$notify_del" ]]; then
        echo $'\n>' Notify Deletion

        install -D /dev/null "$env_notify_del_file"
        
        echo > "$env_notify_del_file"
        echo "$notify_del" >> "$env_notify_del_file"
    fi;


    if [[ $env_allow_async == 1 && -n "$push_spec_a" && -n "$push_spec_b" ]]; then
        echo $'\n>' Push Async

        { git push $origin_a $push_spec_a || true; } > "$path_async_output/push1.txt" &
        pid_push1=$!
        { git push $origin_b $push_spec_b || true; } > "$path_async_output/push2.txt" &
        pid_push2=$!
        
        push_report1="> Push $origin_a "
        wait $pid_push1 && push_report1+="(async success)" || push_report1+="(async failure)"
        push_report2+="> Push $origin_b "
        wait $pid_push2 && push_report2+="(async success)" || push_report2+="(async failure)"
        
        echo $push_report1
        echo $push_spec_a
        cat < "$path_async_output/push1.txt"

        echo $push_report2
        echo $push_spec_b
        cat < "$path_async_output/push2.txt"
    else
        if [[ -n "$push_spec_a" ]]; then
            echo $'\n>' Push $origin_a
            echo $push_spec_a
            git push $origin_a $push_spec_a || true
        fi;
        if [[ -n "$push_spec_b" ]]; then
            echo $'\n>' Push $origin_b
            echo $push_spec_b
            git push $origin_b $push_spec_b || true
        fi;
    fi;

    if [[ -n "$notify_solving" ]]; then
        echo $'\n>' Notify Solving

        install -D /dev/null "$env_notify_solving_file"
        
        echo > "$env_notify_solving_file"
        echo "$notify_solving" >> "$env_notify_solving_file"
    fi;


    if [[ $env_allow_async == 1 && -n "$post_fetch_spec_a" && -n "$post_fetch_spec_b" ]]; then
        echo $'\n>' Post-fetch Async

        git fetch --no-tags $origin_a $post_fetch_spec_a > "$path_async_output/post_fetch1.txt" &
        pid_post_fetch1=$!
        git fetch --no-tags $origin_b $post_fetch_spec_b > "$path_async_output/post_fetch2.txt" &
        pid_post_fetch2=$!
        
        post_fetch_report1="> Post-fetch $origin_a "
        wait $pid_post_fetch1 && post_fetch_report1+="(async success)" || post_fetch_report1+="(async failure)"
        post_fetch_report2+="> Post-fetch $origin_b "
        wait $pid_post_fetch2 && post_fetch_report2+="(async success)" || post_fetch_report2+="(async failure)"
        
        echo $post_fetch_report1
        echo $post_fetch_spec_a
        cat < "$path_async_output/post_fetch1.txt"

        echo $post_fetch_report2
        echo $post_fetch_spec_b
        cat < "$path_async_output/post_fetch2.txt"
    else
        if [[ -n "$post_fetch_spec_a" ]]; then
            echo $'\n>' Post-fetch $origin_a
            echo $post_fetch_spec_a
            git fetch --no-tags $origin_a $post_fetch_spec_a
        fi;
        if [[ -n "$post_fetch_spec_b" ]]; then
            echo $'\n>' Post-fetch $origin_b
            echo $post_fetch_spec_b
            git fetch --no-tags $origin_b $post_fetch_spec_b
        fi;
    fi;
}
sync_pass


