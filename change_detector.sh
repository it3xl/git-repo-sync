
remote_refs_1=$(git ls-remote --heads "$url_1" $prefix_1* $prefix_2*)
remote_refs_2=$(git ls-remote --heads "$url_2" $prefix_1* $prefix_2*)

if [[ "$remote_refs_1" = "$remote_refs_2" ]];
then
  echo
  echo Refs are the same. Exit.

  exit
fi


