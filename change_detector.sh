
remote_refs_1=$(git ls-remote --heads "$url_1" $prefix_1* $prefix_2*)
remote_refs_2=$(git ls-remote --heads "$url_2" $prefix_1* $prefix_2*)

local_refs_1_sha=$(git for-each-ref --format="%(objectname)" "refs/remotes/$origin_1/")
local_refs_2_sha=$(git for-each-ref --format="%(objectname)" "refs/remotes/$origin_2/")

changes_detected=0
if [[ "$remote_refs_1" != "$remote_refs_2" \
      || "$local_refs_1_sha" != "$local_refs_2_sha" ]]; then
  echo figase
  changes_detected=1
fi


