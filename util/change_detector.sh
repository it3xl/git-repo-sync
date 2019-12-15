
if [[ $env_allow_async == 1 ]]; then
    echo '! Async (async remote refs check is used)'
    
    mkdir -p "$path_async_output"

    git ls-remote --heads "$url_1" $sync_ref_specs > "$path_async_output/remote_refs_1.txt" &
    pid_remote_refs_1=$!
    git ls-remote --heads "$url_2" $sync_ref_specs > "$path_async_output/remote_refs_2.txt" &
    pid_remote_refs_2=$!

    err_remote_refs_1=0;
    wait $pid_remote_refs_1 || err_remote_refs_1=$?
    err_remote_refs_2=0;
    wait $pid_remote_refs_2 || err_remote_refs_2=$?

    remote_refs_1=$(<"$path_async_output/remote_refs_1.txt")
    remote_refs_2=$(<"$path_async_output/remote_refs_2.txt")

    if (( $err_remote_refs_1 != 0 )); then
        echo
        echo "> Async fail | Change detection | $origin_1 | Error $err_remote_refs_1"
        echo "$remote_refs_1"
        echo ">"
    fi;
    if (( $err_remote_refs_2 != 0 )); then
        echo
        echo "> Async fail | Change detection | $origin_2 | Error $err_remote_refs_2"
        echo "$remote_refs_2"
        echo ">"
    fi;
    if (( $err_remote_refs_1 != 0 )); then
        echo
        echo "> Exit."
        exit $err_remote_refs_1;
    fi;
    if (( $err_remote_refs_2 != 0 )); then
        echo
        echo "> Exit."
        exit $err_remote_refs_2;
    fi;
else
    echo '! Sync (sync remote refs check is used)'
    
    remote_refs_2=$(git ls-remote --heads "$url_2" $sync_ref_specs)
    remote_refs_1=$(git ls-remote --heads "$url_1" $sync_ref_specs)
fi;


track_refs_1_sha=$(git for-each-ref --format="%(objectname)" "refs/remotes/$origin_1/")
track_refs_2_sha=$(git for-each-ref --format="%(objectname)" "refs/remotes/$origin_2/")

# Let's check the local checking repository is new and empty. For a fast filling of the local checking repo.
## remote_count=$(echo "$remote_refs_1" | awk 'END { print NR }';)
## track_count=$(echo "$track_refs_1_sha" | awk 'END { print NR }';)
##
mapfile -t remote_refs < <(echo "$remote_refs_1")
remote_count=${#remote_refs[@]}
mapfile -t track_refs < <(echo "$track_refs_1_sha")
track_count=${#track_refs[@]}


changes_detected=0
if [[ "$remote_refs_1" != "$remote_refs_2" \
    || "$track_refs_1_sha" != "$track_refs_2_sha" \
    || $remote_count != $track_count ]];
then
    changes_detected=1
fi


