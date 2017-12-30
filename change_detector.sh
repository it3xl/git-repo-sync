
remote_refs_1=$(git ls-remote --heads "$url_1" $prefix_1* $prefix_2*)
remote_refs_2=$(git ls-remote --heads "$url_2" $prefix_1* $prefix_2*)

if [[ "$remote_refs_1" = "$remote_refs_2" ]];
then
  echo
  echo Refs are the same. Exit.

  exit
fi


local_refs_1=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_1/$prefix_1")
local_refs_2=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_2/$prefix_2")





local_refs_1="f6f779723b4705ce1b87e073406eb8c65c47d814__ refs/remotes/$origin_1/client_co/production
b87ba25222618a07a2ed839a613022fcc6f85cf3 refs/remotes/$origin_1/vendor_co/develop"

local_refs_2="f6f779723b4705ce1b87e073406eb8c65c47d814 refs/remotes/$origin_2/client_co/production
b87ba25222618a07a2ed839a613022fcc6f85cf3 refs/remotes/$origin_2/vendor_co/develop"




changed_refs=$(awk \
  -f "$path_git_sync/changed_refs.awk" \
  `#echo --lint` \
  --assign must_exist_branch=$must_exist_branch \
  --assign remote_1="$origin_1" \
  --assign remote_2="$origin_2" \
  --assign local_1="$prefix_1" \
  --assign local_2="$prefix_2" \
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
