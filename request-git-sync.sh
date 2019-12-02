set -euf +x -o pipefail

echo
echo Start `basename $0`

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$invoke_path/util/set_env.sh" "$@"

rm -f "$env_modifications_signal_file"
rm -f "$env_modifications_signal_file_1"
rm -f "$env_modifications_signal_file_2"

echo
source "$path_git_sync_util/repo_create.sh"
cd "$path_sync_repo"

source "$path_git_sync_util/restore-after-crash.sh"

source "$path_git_sync_util/change_detector.sh"

echo
if (( $changes_detected == 1 )); then
  install -D /dev/null "$env_modifications_signal_file"
  install -D /dev/null "$env_modifications_signal_file_1"
  install -D /dev/null "$env_modifications_signal_file_2"
  
  # Passing of remote refs to prevent excessive network requesting.
  echo "$remote_refs_1" >> "$env_modifications_signal_file_1"

  echo "$remote_refs_2" >> "$env_modifications_signal_file_2"
  
  echo '@' RESULT: Synchronization requested.
else
  echo '@' RESULT: Refs are the same. Exit.
  echo
  
  exit
fi


echo
echo End `basename $0`
