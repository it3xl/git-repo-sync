set -euf +x -o pipefail

echo
echo Start `basename $0`

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$invoke_path"/set_env.sh "$@"

echo
bash "$path_git_sync"/repo_create.sh "$path_sync_repo"

cd "$path_sync_repo"

source "$path_git_sync"/change_detector.sh



local_refs_1=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_1/$prefix_1")
local_refs_2=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_2/$prefix_2")

changed_refs=$(awk \
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
echo ------------------ Changed refs: ------------------
echo "$changed_refs"
echo ___________________________________________________







echo End `basename $0`
