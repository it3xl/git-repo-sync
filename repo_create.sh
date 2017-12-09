
repo_path="$1"

if [[ -f "$repo_path/.git/config" ]]; then
  exit
fi

mkdir -p "$repo_path"
cd "$repo_path"

git init


git config --local advice.pushUpdateRejected false



echo Repo created at $repo_path









