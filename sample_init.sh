
echo Start `basename "$BASH_SOURCE"`

url_local="$path_git_sync/sample_repos"
url_local_1="$url_local/local_$prefix_1"
url_local_2="$url_local/local_$prefix_2"

first_branch=$must_exist_branch
second_branch=${prefix_2}develop

export must_exist_branch=$first_branch


if [[ ! -f "$url_1/config" ]]; then
  echo
  echo '@ Creation of sample repos. 2 remote & 2 local'

  rm -rf "$url_local"

  echo
  echo "@@ 1 remote repo"
  mkdir -p "$url_1"
  cd "$url_1"
  git init --bare
  git symbolic-ref HEAD refs/heads/$first_branch

  echo
  echo "@@ 1 local repo"
  git clone "$url_1" "$url_local_1"
  cd "$url_local_1"

  echo
  echo "@@ 1 local repo initial commit"
  git checkout -b $first_branch
  touch .gitignore
  git add --all
  git commit -m "Initial commit"
  git branch $second_branch

  echo
  echo "@@ 1 local repo. A test file commit"
  echo test file >> test_file.txt
  git add --all
  git commit -m "Test file commit"

  echo
  echo "@@ 1 local repo. Pushing to 1 remote repo"
  git push --all "origin"


  echo
  echo "@@ 2 remote repo by copying from 1 remote repo"
  cp -r "$url_1"/ "$url_2"/
  cd "$url_2"
  git symbolic-ref HEAD refs/heads/$second_branch

  echo
  echo "@@ 2 local repo"
  git clone "$url_2" "$url_local_2"
  cd "$url_local_2"

  echo
  echo "@@ 2 local repo. Ohter test file commit"
  echo other test file >> other_test_file.txt
  git add --all
  git commit -m "Other test file commit"

  echo
  echo "@@ Pushing from 2 local repo to 2 remote repo"
  git push --all "origin"

fi

echo
echo End `basename "$BASH_SOURCE"`








