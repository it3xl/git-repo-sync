
if [[ $env_allow_async == 1 ]]; then
    echo '! Async (async remote refs check is used)'
    
    mkdir -p "$path_async_output"

    git ls-remote --heads "$url_a" $sync_ref_specs > "$path_async_output/remote_refs_a.txt" &
    pid_remote_refs_a=$!
    git ls-remote --heads "$url_b" $sync_ref_specs > "$path_async_output/remote_refs_b.txt" &
    pid_remote_refs_b=$!

    err_remote_refs_a=0;
    wait $pid_remote_refs_a || err_remote_refs_a=$?
    err_remote_refs_b=0;
    wait $pid_remote_refs_b || err_remote_refs_b=$?

    remote_refs_a=$(<"$path_async_output/remote_refs_a.txt")
    remote_refs_b=$(<"$path_async_output/remote_refs_b.txt")

    if (( $err_remote_refs_a != 0 )); then
        echo
        echo "> Async fail | Change detection | $origin_a | Error $err_remote_refs_a"
        echo "$remote_refs_a"
        echo ">"
    fi;
    if (( $err_remote_refs_b != 0 )); then
        echo
        echo "> Async fail | Change detection | $origin_b | Error $err_remote_refs_b"
        echo "$remote_refs_b"
        echo ">"
    fi;
    if (( $err_remote_refs_a != 0 )); then
        echo
        echo "> Exit."
        exit $err_remote_refs_a;
    fi;
    if (( $err_remote_refs_b != 0 )); then
        echo
        echo "> Exit."
        exit $err_remote_refs_b;
    fi;
else
    echo '! Sync (sync remote refs check is used)'
    
    remote_refs_b=$(git ls-remote --heads "$url_b" $sync_ref_specs)
    remote_refs_a=$(git ls-remote --heads "$url_a" $sync_ref_specs)
fi;


track_refs_a_sha=$(git for-each-ref --format="%(objectname)" "refs/remotes/$origin_a/")
track_refs_b_sha=$(git for-each-ref --format="%(objectname)" "refs/remotes/$origin_b/")

# Let's check the local checking repository is new and empty. For a fast filling of the local checking repo.
## remote_count=$(echo "$remote_refs_a" | awk 'END { print NR }';)
## track_count=$(echo "$track_refs_a_sha" | awk 'END { print NR }';)
##
mapfile -t remote_refs < <(echo "$remote_refs_a")
remote_count=${#remote_refs[@]}
mapfile -t track_refs < <(echo "$track_refs_a_sha")
track_count=${#track_refs[@]}


changes_detected=0
if [[ "$remote_refs_a" != "$remote_refs_b" \
    || "$track_refs_a_sha" != "$track_refs_b_sha" \
    || $remote_count != $track_count ]];
then
    changes_detected=1
fi


