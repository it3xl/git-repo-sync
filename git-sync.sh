set -euf +x -o pipefail

echo
echo Start `basename $0`

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$invoke_path"/set_env.sh "$@"

echo
bash "$path_git_sync"/repo_create.sh "$path_sync_repo"

cd "$path_sync_repo"


# cd to sync repo.
#git checkout -f bfa44a557c727bcc5caf3bd49b3226f49b9c13d1 --



source "$path_git_sync"/deletion_allowability.sh
source "$path_git_sync"/changes_detector.sh

















echo End `basename $0`































