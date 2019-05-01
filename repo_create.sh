set -euf +x -o pipefail

echo
echo Start `basename "$BASH_SOURCE"`

repo_path="$1"


[[ "$use_bash_git_credential_helper" == "1" ]] && {
  echo As use_bash_git_credential_helper variable is set to $use_bash_git_credential_helper
  echo we will initialize git-cred.sh

  if [[ ! -f "$git_cred" ]]; then
    echo Error! Exit! You have to update/download Git-submodules of git-sync project to use $git_cred
    echo Or delete "use_bash_git_credential_helper=1" from your sync project settings file.
  
    exit 1
  fi
  
  source "$git_cred"  init  repo_1  $url_1
  source "$git_cred"  init  repo_2  $url_2
}


if [[ -f "$repo_path/.git/config" ]]; then
  exit
fi

mkdir -p "$repo_path"
cd "$repo_path"

git init

git config --local advice.pushUpdateRejected false
#git config --local core.logAllRefUpdates

git remote add $origin_1 "$url_1"
git remote add $origin_2 "$url_2"


if [[ -f "$path_git_sync/repo_create.local.sh" ]]; then
  source "$path_git_sync/repo_create.local.sh"
fi


echo Repo created at $repo_path


echo End `basename "$BASH_SOURCE"`






