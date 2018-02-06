set -euf +x -o pipefail

echo
echo Start `basename $0`

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$invoke_path/set_env.sh" "$@"



echo
bash "$path_git_sync/repo_create.sh" "$path_sync_repo"
cd "$path_sync_repo"


rm -f "$env_notify_del_file"
rm -f "$env_notify_solving_file"


echo
if [[ ! -f "$env_modifications_signal_file" ]]; then
  source "$path_git_sync/change_detector.sh"

  if (( $changes_detected != 1 )); then
    echo '@' RESULT: Refs are the same. Exit.
    echo
    
    # !!! EXIT !!!
    exit
  fi
else
  echo '@' RESULT: Synchronization requested.
  
  source "$env_modifications_signal_file"
  
  rm -f "$env_modifications_signal_file"
fi


local_refs_1=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_1/")
local_refs_2=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_2/")

refspecs=$(awk \
  -f "$path_git_sync/state_to_refspec.gawk" \
  `# --lint` \
  --assign must_exist_branch=$must_exist_branch \
  --assign origin_1="$origin_1" \
  --assign origin_2="$origin_2" \
  --assign prefix_1="$prefix_1" \
  --assign prefix_2="$prefix_2" \
  --assign trace_on=1 \
  <(echo "$remote_refs_1") \
  <(echo "$remote_refs_2") \
  <(echo "$local_refs_1") \
  <(echo "$local_refs_2") \
)

mapfile -t refspec_list < <(echo "$refspecs")

del_spec="${refspec_list[1]}";
fetch_spec1="${refspec_list[2]}";
fetch_spec2="${refspec_list[3]}";
push_spec1="${refspec_list[4]}";
push_spec2="${refspec_list[5]}";
post_fetch_spec1="${refspec_list[6]}";
post_fetch_spec2="${refspec_list[7]}";
notify_del="${refspec_list[8]}";
notify_solving="${refspec_list[9]}";

mkdir -p "$path_async_output"

if [[ -n "$del_spec" ]]; then
  echo $'\n>' Delete local branch
  echo $del_spec
  git branch --delete --force --remotes $del_spec
fi;


if [[ -n "$fetch_spec1" && -n "$fetch_spec2" ]]; then
  git fetch --no-tags $origin_1 $fetch_spec1 &> "$path_async_output/fetch1.txt" &
  pid_fetch1=$!
  git fetch --no-tags $origin_2 $fetch_spec2 &> "$path_async_output/fetch2.txt" &
  pid_fetch2=$!
  
  fetch_report1="> Fetch $origin_1 "
  wait $pid_fetch1 && fetch_report1+="(async success)" || fetch_report1+="(async failure)"
  fetch_report2+="> Fetch $origin_2 "
  wait $pid_fetch2 && fetch_report2+="(async success)" || fetch_report2+="(async failure)"
  
  echo
  echo $fetch_report1
  echo $fetch_spec1
  cat < "$path_async_output/fetch1.txt"
  echo
  echo $fetch_report2
  echo $fetch_spec2
  cat < "$path_async_output/fetch2.txt"
else
  if [[ -n "$fetch_spec1" ]]; then
    echo $'\n>' Fetch $origin_1
    echo $fetch_spec1
    git fetch --no-tags $origin_1 $fetch_spec1
  fi;
  if [[ -n "$fetch_spec2" ]]; then
    echo $'\n>' Fetch $origin_2
    echo $fetch_spec2
    git fetch --no-tags $origin_2 $fetch_spec2
  fi;
fi;


if [[ -n "$notify_del" ]]; then
  install -D /dev/null "$env_notify_del_file"
  
  echo > "$env_notify_del_file"
  echo "$notify_del" >> "$env_notify_del_file"
fi;
if [[ -n "$notify_solving" ]]; then
  install -D /dev/null "$env_notify_solving_file"
  
  echo > "$env_notify_solving_file"
  echo "$notify_solving" >> "$env_notify_solving_file"
fi;


if [[ -n "$push_spec1" && -n "$push_spec2" ]]; then
  { git push --verbose $origin_1 $push_spec1 || true; } &> "$path_async_output/push1.txt" &
  pid_push1=$!
  { git push --verbose $origin_2 $push_spec2 || true; } &> "$path_async_output/push2.txt" &
  pid_push2=$!
  
  push_report1="> Push $origin_1 "
  wait $pid_push1 && push_report1+="(async success)" || push_report1+="(async failure)"
  push_report2+="> Push $origin_2 "
  wait $pid_push2 && push_report2+="(async success)" || push_report2+="(async failure)"
  
  echo
  echo $push_report1
  echo $push_spec1
  cat < "$path_async_output/push1.txt"
  echo
  echo $push_report2
  echo $push_spec2
  cat < "$path_async_output/push2.txt"
else
  if [[ -n "$push_spec1" ]]; then
    echo $'\n>' Push $origin_1
    echo $push_spec1
    git push --verbose $origin_1 $push_spec1 || true
  fi;
  if [[ -n "$push_spec2" ]]; then
    echo $'\n>' Push $origin_2
    echo $push_spec2
    git push --verbose $origin_2 $push_spec2 || true
  fi;
fi;


if [[ -n "$post_fetch_spec1" && -n "$post_fetch_spec2" ]]; then
  git fetch --no-tags $origin_1 $post_fetch_spec1 &> "$path_async_output/post_fetch1.txt" &
  pid_post_fetch1=$!
  git fetch --no-tags $origin_2 $post_fetch_spec2 &> "$path_async_output/post_fetch2.txt" &
  pid_post_fetch2=$!
  
  post_fetch_report1="> Post-fetch $origin_1 "
  wait $pid_post_fetch1 && post_fetch_report1+="(async success)" || post_fetch_report1+="(async failure)"
  post_fetch_report2+="> Post-fetch $origin_2 "
  wait $pid_post_fetch2 && post_fetch_report2+="(async success)" || post_fetch_report2+="(async failure)"
  
  echo
  echo $post_fetch_report1
  echo $post_fetch_spec1
  cat < "$path_async_output/post_fetch1.txt"
  echo
  echo $post_fetch_report2
  echo $post_fetch_spec2
  cat < "$path_async_output/post_fetch2.txt"
  
else
  if [[ -n "$post_fetch_spec1" ]]; then
    echo $'\n>' Post-fetch $origin_1
    echo $post_fetch_spec1
    git fetch --no-tags $origin_1 $post_fetch_spec1
  fi;
  if [[ -n "$post_fetch_spec2" ]]; then
    echo $'\n>' Post-fetch $origin_2
    echo $post_fetch_spec2
    git fetch --no-tags $origin_2 $post_fetch_spec2
  fi;
fi;


echo
echo End `basename $0`
