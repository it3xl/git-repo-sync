
use_fork_join_check=1
if (( $use_fork_join_check == 1)); then
  echo '! Async (async remote refs check is used)'
  
  mkdir -p "$path_async_output"

  git ls-remote --heads "$url_1" $prefix_1* $prefix_2* > "$path_async_output/remote_refs_1.txt" &
  pid_remote_refs_1=$!
  git ls-remote --heads "$url_2" $prefix_1* $prefix_2* > "$path_async_output/remote_refs_2.txt" &
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
  
  remote_refs_2=$(git ls-remote --heads "$url_2" $prefix_1* $prefix_2*)
  remote_refs_1=$(git ls-remote --heads "$url_1" $prefix_1* $prefix_2*)
fi;


local_refs_1_sha=$(git for-each-ref --format="%(objectname)" "refs/remotes/$origin_1/")
local_refs_2_sha=$(git for-each-ref --format="%(objectname)" "refs/remotes/$origin_2/")

# Let's check the local repository is new and empty. For a fast filling of the local repo.
## remote_count=$(echo "$remote_refs_1" | awk 'END { print NR }';)
## local_count=$(echo "$local_refs_1_sha" | awk 'END { print NR }';)
##
mapfile -t remote_refs < <(echo "$remote_refs_1")
remote_count=${#remote_refs[@]}
mapfile -t local_refs < <(echo "$local_refs_1_sha")
local_count=${#local_refs[@]}


changes_detected=0
if [[ "$remote_refs_1" != "$remote_refs_2" \
      || "$local_refs_1_sha" != "$local_refs_2_sha" \
      || $remote_count != $local_count ]];
then
  changes_detected=1
fi


