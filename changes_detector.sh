
refs_repo_1=$(git ls-remote --heads "$url_1" $prefix_1/* $prefix_2/*)
refs_repo_2=$(git ls-remote --heads "$url_2" $prefix_1/* $prefix_2/*)

if [[ "$refs_repo_1" = "$refs_repo_2" ]];
then
  echo
  echo Refs are the same. Exit.
  
  exit
fi

changed_refs=$(awk -f "$path_git_sync/changed_refs.awk" <(echo "$refs_repo_1"; echo "$refs_repo_2"))



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
echo fetch_refs "${fetch_refs[@]}"










