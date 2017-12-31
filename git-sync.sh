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
  -f "$path_git_sync/changed_refs.awk" \
  `#echo --lint` \
  --assign must_exist_branch=$must_exist_branch \
  --assign remote_1="$origin_1" \
  --assign remote_2="$origin_2" \
  --assign local_1="$prefix_1" \
  --assign local_2="$prefix_2" \
  --assign debug_on=1 \
  <(echo "$remote_refs_1") \
  <(echo "$remote_refs_2") \
  <(echo "$local_refs_1") \
  <(echo "$local_refs_2") \
)



echo
echo ------------------ Changed refs: ------------------
echo "$changed_refs"
echo ___________________________________________________



declare -a fetch_refs;
declare -a sync_refs;
#declare -A resolve_refs;
for r in $changed_refs; do
  fetch_refs+=("+$r:$r");
  sync_refs+=("$r:$r");
  #resolve_refs+=('"%s" ' "+$r:$r");
done

echo
#echo fetch_refs "${fetch_refs[@]}"














echo End `basename $0`
