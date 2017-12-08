
echo Start `basename "$BASH_SOURCE"`


url_local_1="$path_git_sync/sample_repos/local_$prefix_1"
url_local_2="$path_git_sync/sample_repos/local_$prefix_2"

first_branch=$must_exist_branch
second_branch=$prefix_2/develop

export must_exist_branch=$first_branch


if [[ ! -f "$url_1/config" ]]; then
  
  mkdir -p "$url_1"
  cd "$url_1"
  git init --bare
  git symbolic-ref HEAD refs/heads/$first_branch

  git clone "$url_1" "$url_local_1"
  cd "$url_local_1"
  git checkout -b $first_branch
  touch .gitignore
  
  git add --all
  git commit -m "Initial commit"
  git branch $second_branch
  
  echo test file >> test_file.txt
  git add --all
  git commit -m "Test file commit"
  
  git push --all "origin"
  
  cp -r "$url_1"/ "$url_2"/
  cd "$url_2"
  git symbolic-ref HEAD refs/heads/$second_branch
  
  git clone "$url_2" "$url_local_2"
  cd "$url_local_2"

  echo other test file >> other_test_file.txt
  git add --all
  git commit -m "Other test file commit"
  git push --all "origin"

fi

echo End `basename "$BASH_SOURCE"`








