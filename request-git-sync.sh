set -euf +x -o pipefail

echo
echo Start `basename $0`

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$invoke_path"/set_env.sh "$@"

rm -f "$env_modifications_signal_file"

echo
bash "$path_git_sync"/repo_create.sh "$path_sync_repo"
cd "$path_sync_repo"

source "$path_git_sync"/change_detector.sh

echo
if (( $changes_detected == 1 )); then
  install -D /dev/null "$env_modifications_signal_file"
  echo '@' RESULT: Synchronization requested.
else
  echo '@' RESULT: Refs are the same. Exit.
fi

echo


echo End `basename $0`
