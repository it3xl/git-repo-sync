# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync

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

    track_refs_a=$(git for-each-ref --format="%(objectname) %(refname)" $track_ref_specs_a)
    track_refs_b=$(git for-each-ref --format="%(objectname) %(refname)" $track_ref_specs_b)

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

    # $env_awk_edition --file="$path_git_sync/../proto/proto.gawk" <(echo)
    # exit


    pre_fetch_processing='pre_fetch_processing.gawk'
    pre_proc_data=$($env_awk_edition \
        --file="$path_git_sync_util/gawk/$pre_fetch_processing" \
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

    fetch_spec_a="${pre_proc_list[0]}";
    fetch_spec_b="${pre_proc_list[1]}";
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
        exit 22;
    fi;

    if [[ $env_trace_refs == 1 ]]; then
        echo fetch_spec_a
        echo "$fetch_spec_a"
        echo fetch_spec_b
        echo "$fetch_spec_b"
        echo conv_move
        echo "$conv_move"
        echo victim_move
        echo "$victim_move"
    fi;
    # exit


    if [[ $env_allow_async == 1 && -n "$fetch_spec_a" && -n "$fetch_spec_b" ]]; then
        echo $'\n>' Fetch Async

        git fetch --no-tags $origin_a $fetch_spec_a > "$path_async_output/fetch_a.txt" &
        pid_fetch_a=$!
        git fetch --no-tags $origin_b $fetch_spec_b > "$path_async_output/fetch_b.txt" &
        pid_fetch_b=$!
        
        fetch_report_a="> Fetch $origin_a "
        wait $pid_fetch_a && fetch_report_a+="(async success)" || fetch_report_a+="(async failure)"
        fetch_report_b+="> Fetch $origin_b "
        wait $pid_fetch_b && fetch_report_b+="(async success)" || fetch_report_b+="(async failure)"
        
        echo $fetch_report_a
        echo $fetch_spec_a
        cat < "$path_async_output/fetch_a.txt"

        echo $fetch_report_b
        echo $fetch_spec_b
        cat < "$path_async_output/fetch_b.txt"
    else
        if [[ -n "$fetch_spec_a" ]]; then
            echo $'\n>' Fetch $origin_a
            echo $fetch_spec_a
            git fetch --no-tags $origin_a $fetch_spec_a
        fi;
        if [[ -n "$fetch_spec_b" ]]; then
            echo $'\n>' Fetch $origin_b
            echo $fetch_spec_b
            git fetch --no-tags $origin_b $fetch_spec_b
        fi;
    fi;


    track_refs_a=$(git for-each-ref --format="%(objectname) %(refname)" $track_ref_specs_a)
    track_refs_b=$(git for-each-ref --format="%(objectname) %(refname)" $track_ref_specs_b)

    if [[ $env_trace_refs == 1 ]]; then
        echo
        echo track_refs_a=
        echo "$track_refs_a"
        echo track_refs_b=
        echo "$track_refs_b"
    fi;
    # exit


    proc_data=$($env_awk_edition \
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

    processing_requested="${proc_list[0]}";
    remove_tracking_spec="${proc_list[1]}";
    notify_del="${proc_list[2]//$env_awk_newline_substitution/$'\n'}";

    push_spec_a="${proc_list[3]}";
    push_spec_b="${proc_list[4]}";
    notify_solving="${proc_list[5]//$env_awk_newline_substitution/$'\n'}";

    post_fetch_spec_a="${proc_list[6]}";
    post_fetch_spec_b="${proc_list[7]}";

    end_of_results="${proc_list[8]}";

    if [[ $env_trace_refs == 1 ]]; then
        echo
        echo processing_requested is "$processing_requested"
        echo remove_tracking_spec is
        echo "$remove_tracking_spec"
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
        exit 23
    fi;

    if [[ "$processing_requested" == '1' ]]; then
        ((++post_fetch_processing_num))
    fi;

    mkdir -p "$path_async_output"

    if [[ -n "$remove_tracking_spec" ]]; then
        echo $'\n>' Delete branches
        git branch --delete --force --remotes $remove_tracking_spec
    fi;

    if [[ -n "$notify_del" ]]; then
        echo $'\n>' Notify Deletion

        install -D /dev/null "$env_notify_del_file"
        
        echo > "$env_notify_del_file"
        echo "$notify_del" >> "$env_notify_del_file"
    fi;


    if [[ $env_allow_async == 1 && -n "$push_spec_a" && -n "$push_spec_b" ]]; then
        echo $'\n>' Push Async

        { git push $origin_a $push_spec_a || true; } > "$path_async_output/push_a.txt" &
        pid_push_a=$!
        { git push $origin_b $push_spec_b || true; } > "$path_async_output/push_b.txt" &
        pid_push_b=$!
        
        push_report_a="> Push $origin_a "
        wait $pid_push_a && push_report_a+="(async success)" || push_report_a+="(async failure)"
        push_report_b+="> Push $origin_b "
        wait $pid_push_b && push_report_b+="(async success)" || push_report_b+="(async failure)"
        
        echo $push_report_a
        echo $push_spec_a
        cat < "$path_async_output/push_a.txt"

        echo $push_report_b
        echo $push_spec_b
        cat < "$path_async_output/push_b.txt"
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

        git fetch --no-tags $origin_a $post_fetch_spec_a > "$path_async_output/post_fetch_a.txt" &
        pid_post_fetch_a=$!
        git fetch --no-tags $origin_b $post_fetch_spec_b > "$path_async_output/post_fetch_b.txt" &
        pid_post_fetch_b=$!
        
        post_fetch_report_a="> Post-fetch $origin_a "
        wait $pid_post_fetch_a && post_fetch_report_a+="(async success)" || post_fetch_report_a+="(async failure)"
        post_fetch_report_b+="> Post-fetch $origin_b "
        wait $pid_post_fetch_b && post_fetch_report_b+="(async success)" || post_fetch_report_b+="(async failure)"
        
        echo $post_fetch_report_a
        echo $post_fetch_spec_a
        cat < "$path_async_output/post_fetch_a.txt"

        echo $post_fetch_report_b
        echo $post_fetch_spec_b
        cat < "$path_async_output/post_fetch_b.txt"
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


