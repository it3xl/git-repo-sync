
remote_refs_1=$(git ls-remote --heads "$url_1" $prefix_1* $prefix_2*)
remote_refs_2=$(git ls-remote --heads "$url_2" $prefix_1* $prefix_2*)

local_refs_1_sha=$(git for-each-ref --format="%(objectname)" "refs/remotes/$origin_1/")
local_refs_2_sha=$(git for-each-ref --format="%(objectname)" "refs/remotes/$origin_2/")

# Let's check the local repository is new and empty. For a fast filling of the local repo.
remote_count=$(echo "$remote_refs_1" | awk 'END { print NR }';)
local_count=$(echo "$local_refs_1_sha" | awk 'END { print NR }';)

changes_detected=0
if [[ "$remote_refs_1" != "$remote_refs_2" \
      || "$local_refs_1_sha" != "$local_refs_2_sha" \
      || $remote_count != $local_count ]];
then
  changes_detected=1
fi


