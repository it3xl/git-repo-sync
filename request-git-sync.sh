set -euf +x -o pipefail

echo
echo Start `basename $0`

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$invoke_path/set_env.sh" "$@"

rm -f "$env_modifications_signal_file"

echo
source "$path_git_sync/repo_create.sh" "$path_sync_repo"
cd "$path_sync_repo"

source "$path_git_sync/change_detector.sh"

echo
if (( $changes_detected == 1 )); then
  install -D /dev/null "$env_modifications_signal_file"
  
  # Passing of remote refs to prevent excessive network requesting.
  echo > "$env_modifications_signal_file"
  echo "remote_refs_1=\"$remote_refs_1\"" >> "$env_modifications_signal_file"
  echo >> "$env_modifications_signal_file"
  echo "remote_refs_2=\"$remote_refs_2\"" >> "$env_modifications_signal_file"
  echo >> "$env_modifications_signal_file"
  
  echo '@' RESULT: Synchronization requested.
else
  echo '@' RESULT: Refs are the same. Exit.
  echo
  
  exit
fi


echo
echo End `basename $0`
