
remote_refs_1=$(git ls-remote --heads "$url_1" $prefix_1* $prefix_2*)
remote_refs_2=$(git ls-remote --heads "$url_2" $prefix_1* $prefix_2*)

local_refs_1=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_1/")
local_refs_2=$(git for-each-ref --format="%(objectname) %(refname)" "refs/remotes/$origin_2/")

changes_detected=0
if [[ "$remote_refs_1" != "$remote_refs_2" || "$local_refs_1" != "$local_refs_2" ]]; then
  changes_detected=1
fi


