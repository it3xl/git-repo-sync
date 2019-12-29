set -euf +x -o pipefail

#echo
#echo Start `basename $0`

invoke_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$invoke_path/util/set_env.sh" "$@"



echo
source "$path_git_sync_util/repo_create.sh"
cd "$path_sync_repo"


rm -f "$env_notify_del_file"
rm -f "$env_notify_solving_file"

source "$path_git_sync_util/restore-after-crash.sh"


source "$path_git_sync_util/sync_pass.sh"
source "$path_git_sync_util/sync_pass.sh"


echo
echo @ RESULT: Successfully completed with $git_sync_pass_num_required sync-pass'/'es.
#echo
#echo End `basename $0`
