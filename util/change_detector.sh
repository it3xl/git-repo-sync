# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync

if [[ $env_allow_async == 1 ]]; then
    echo '! Async (async remote refs checks are used)'
    
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
    echo '! Sync (sync remote refs checks are used)'
    
    remote_refs_b=$(git ls-remote --heads "$url_b" $sync_ref_specs)
    remote_refs_a=$(git ls-remote --heads "$url_a" $sync_ref_specs)
fi;


track_refs_a=$(git for-each-ref --format="%(objectname) %(refname)" $track_ref_specs_a)
track_refs_b=$(git for-each-ref --format="%(objectname) %(refname)" $track_ref_specs_b)

## remote_count=$(echo "$remote_refs_a" | awk 'END { print NR }';)
## track_count=$(echo "$track_refs_a" | awk 'END { print NR }';)

export remote_refs_a;
export remote_refs_b;
export track_refs_a;
export track_refs_b;

changes_detected=$($env_awk_edition --file="$path_git_sync_util/gawk/change_detector.gawk")
echo

