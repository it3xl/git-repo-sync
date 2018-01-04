set -euf +x -o pipefail

echo
echo Start `basename $0`

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$invoke_path"/set_env.sh "$@"

echo
bash "$path_git_sync"/repo_create.sh "$path_sync_repo"

cd "$path_sync_repo"

source "$path_git_sync"/change_detector.sh


local_refs_1=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_1/")
local_refs_2=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_2/")

echo
echo local_refs_1
echo "$local_refs_1"
echo
echo local_refs_2
echo "$local_refs_2"
echo

refspecs=$(awk \
  -f "$path_git_sync/state_to_refspec.awk" \
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

echo
echo ------------------ Git refspecs: ------------------
echo "$refspecs"
echo ___________________________________________________
echo

mapfile -t refspec_list < <(echo "$refspecs")

del_spec="${refspec_list[1]}";
if [[ -n "$del_spec" ]]; then
  echo git branch --delete --force --remotes "$del_spec"
  git branch --delete --force --remotes "$del_spec"
fi;

fetch1_spec="${refspec_list[2]}";
if [[ -n "$fetch1_spec" ]]; then
  echo git fetch $origin_1 $fetch1_spec
  git fetch $origin_1 $fetch1_spec
fi;
fetch2_spec="${refspec_list[3]}";
if [[ -n "$fetch2_spec" ]]; then
  echo git fetch $origin_2 $fetch2_spec
  git fetch $origin_2 $fetch2_spec
fi;

push1_spec="${refspec_list[4]}";
if [[ -n "$push1_spec" ]]; then
  echo git push $origin_1 $push1_spec
  git push $origin_1 $push1_spec || true
fi;
push2_spec="${refspec_list[5]}";
if [[ -n "$push2_spec" ]]; then
  echo git push $origin_2 $push2_spec
  git push $origin_2 $push2_spec || true
fi;

post_fetch1_spec="${refspec_list[6]}";
if [[ -n "$post_fetch1_spec" ]]; then
  echo git fetch $origin_1 $post_fetch1_spec
  git fetch $origin_1 $post_fetch1_spec
fi;
post_fetch2_spec="${refspec_list[7]}";
if [[ -n "$post_fetch2_spec" ]]; then
  echo git fetch $origin_2 $post_fetch2_spec
  git fetch $origin_2 $post_fetch2_spec
fi;


echo End `basename $0`
