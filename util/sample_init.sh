
echo Start `basename "$BASH_SOURCE"`

url_local="$path_project_root/material_repos"

# Overrides settings' file values.
url_1="$url_local/remote_$prefix_1_safe"
url_2="$url_local/remote_$prefix_2_safe"

url_local_1="$url_local/local_$prefix_1_safe"
url_local_2="$url_local/local_$prefix_2_safe"

initial_commit_branch=initial-commit
second_branch=${prefix_2}develop
non_conflicting_common_branch=${prefix_victims}non-conflicting
conflicting_common_branch=${prefix_victims}conflicting
non_conflicting_common_branch_one_side=${prefix_victims}non-conflicting-one-side

if [[ ! -f "$url_1/config" ]]; then
  echo
  echo '@ Creation of sample repos. 2 remote & 2 local'

  rm -rf "$url_local"

  echo
  echo "@@ Creating 1 remote repo"
  mkdir -p "$url_1"
  cd "$url_1"
  git init --bare
  git symbolic-ref HEAD refs/heads/$must_exist_branch



  echo
  echo "@@ Creating 1 local repo"
  git clone "$url_1" "$url_local_1"
  cd "$url_local_1"

  echo
  echo "@@ 1 local repo initial commit"
  git checkout -b $must_exist_branch
  touch .gitignore
  git add --all
  git commit -m "Initial commit"

  # Creation of testing branches on the initial commit.
  git branch $initial_commit_branch
  git branch $second_branch
  git branch $non_conflicting_common_branch
  git branch $conflicting_common_branch

  echo
  echo "@@ 1 local repo. A test file commit"
  echo test file >> test_file.txt
  git add --all
  git commit -m "Test file commit"

  echo
  echo "@@ 1 local repo. Pushing to 1 remote repo"
  git push --all "origin"



  echo
  echo "@@ Creationg 2 remote repo by copying from 1 remote repo"
  cp -r "$url_1"/ "$url_2"/
  cd "$url_2"
  git symbolic-ref HEAD refs/heads/$second_branch

  

  echo
  echo "@@ 1 local repo. Adding of non-conflicting common branch"
  cd "$url_local_1"
  git switch $non_conflicting_common_branch
  echo $non_conflicting_common_branch >> non-conflicting-on-client.txt
  git add --all
  git commit -m "Non-conflicting common branch change. On client"

  echo
  echo "@@ 1 local repo. Adding conflicting common branch created first"
  git switch $conflicting_common_branch
  echo $conflicting_common_branch on client >> conflicting-on-client.txt
  git add --all
  git commit -m "Conflicting common branch change. On client"

  echo
  echo "@@ 1 local repo. Pushing to 1 remote repo"
  git push --all "origin"



  echo
  echo "@@ Creating 2 local repo"
  git clone "$url_2" "$url_local_2"
  cd "$url_local_2"

  echo
  echo "@@ 2 local repo. Ohter test file commit"
  echo other test file >> other_test_file.txt
  git add --all
  git commit -m "Other test file commit"

  echo
  echo "@@ 2 local repo. Adding non-conflicting common branch existed only in the second repo"
  git switch $initial_commit_branch
  git branch $non_conflicting_common_branch_one_side
  git switch $non_conflicting_common_branch_one_side
  echo $non_conflicting_common_branch_one_side on vendor >> non-conflicting-on-vendor.txt
  git add --all
  git commit -m "Non-conflicting common branch change. Branch exist only in the vender repo."

  echo
  echo "@@ 2 local repo. Adding conflicting common branch in second repo"
  git switch $conflicting_common_branch
  echo $conflicting_common_branch on vendor >> conflicting-on-client.txt
  git add --all
  git commit -m "Conflicting common branch change."

  echo
  echo "@@ Pushing from 2 local repo to 2 remote repo"
  git push --all "origin"

fi

echo
echo End `basename "$BASH_SOURCE"`








