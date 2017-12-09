
echo

deletion_allowed=1

if [[ $deletion_allowed = 1 ]]; then
  sha_repo_1=$(git show-ref refs/remotes/$origin_1/heads/$must_exist_branch --hash) || true
  sha_repo_2=$(git show-ref refs/remotes/$origin_2/heads/$must_exist_branch --hash) || true

  if [[ ( -z "$sha_repo_1" || "$sha_repo_1" != "$sha_repo_2") ]]; then
    echo '@  !!!! Deletion & recovering blocked'
    echo '@@ !!!! "Must exist branches" do not exist or not equal.'
    echo '@@ !!!! ' $must_exist_branch

    deletion_allowed=0
  fi
fi



