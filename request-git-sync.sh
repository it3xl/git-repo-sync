set -euf +x -o pipefail

echo
echo Start $(basename $BASH_SOURCE)

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$invoke_path/util/set_env.sh" "$@"

rm -f "$env_modifications_signal_file"
rm -f "$env_modifications_signal_file_a"
rm -f "$env_modifications_signal_file_b"

echo
source "$path_git_sync_util/repo_create.sh"
cd "$path_sync_repo"

source "$path_git_sync_util/restore-after-crash.sh"

source "$path_git_sync_util/change_detector.sh"

echo
if (( $changes_detected == 1 )); then
    install -D /dev/null "$env_modifications_signal_file"
    install -D /dev/null "$env_modifications_signal_file_a"
    install -D /dev/null "$env_modifications_signal_file_b"
    
    # Passing of remote refs to prevent excessive network requesting.
    echo "$remote_refs_a" >> "$env_modifications_signal_file_a"

    echo "$remote_refs_b" >> "$env_modifications_signal_file_b"
    
    echo '@' RESULT: Synchronization requested.
else
    echo '@' RESULT: Refs are the same. Exit.
    echo
    
    # exit
fi


echo
echo End $(basename $BASH_SOURCE)
