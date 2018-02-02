echo
echo Start `basename "$BASH_SOURCE"`

# The $invoke_path variable comes from an external script.
export path_git_sync="$invoke_path"

file_name_repo_settings="${1-}"

run_sample=0
[[ $# -eq 0 ]] && {
  # If there is no the first input parameter, then use with sample repos.
  run_sample=1
  file_name_repo_settings="sample_repo.sh"
}

folder_name_repo_settings=repo_settings
file_repo_settings="$path_git_sync/$folder_name_repo_settings/$file_name_repo_settings"
if [[ ! -f "$file_repo_settings" ]]; then
  echo "Error! Exit! The first parameter must be a name of a file from the folder $folder_name_repo_settings."
  echo "See an example how to fill it with repo's environment variables."
  exit 1;
fi
source "$file_repo_settings"

if [[ ! ${project_folder:+1} ]]; then missed_repo_settings+="project_folder "; fi
if [[ ! ${prefix_1:+1} ]]; then missed_repo_settings+="prefix_1 "; fi
if [[ ! ${url_1:+1} ]]; then missed_repo_settings+="url_1 "; fi
if [[ ! ${prefix_2:+1} ]]; then missed_repo_settings+="prefix_2 "; fi
if [[ ! ${url_2:+1} ]]; then missed_repo_settings+="url_2 "; fi

if [[ ${missed_repo_settings:+1} ]]; then echo "Error! Exit! The following repo properties must be set: $missed_repo_settings"; fi
if [[ ! ${must_exist_branch:+1} ]]; then echo 'Warning! The deletion will not be working without setting the must_exist_branch property'; fi

if [[ ${missed_repo_settings:+1} ]]; then
  exit 2
fi


export prefix_1
export url_1
export prefix_2
export url_2
export must_exist_branch

prefix_1_safe=${prefix_1: : -1}
prefix_2_safe=${prefix_2: : -1}
export prefix_1_safe=${prefix_1_safe//\//-}
export prefix_2_safe=${prefix_2_safe//\//-}

export origin_1=orig_1_$prefix_1_safe
export origin_2=orig_2_$prefix_2_safe

path_project_root="$path_git_sync/sync-projects/$project_folder"
export path_sync_repo="$path_project_root/sync_repo"
# Catches outputs of the fork-join async implementation.
export path_async_output="$path_project_root/async_output"
signal_files_folder=file-signals
export env_modifications_signal_file="$path_project_root/$signal_files_folder/there-are-modifications"
export env_notify_del_file="$path_project_root/$signal_files_folder/notify_del"
export env_notify_solving_file="$path_project_root/$signal_files_folder/notify_solving"

(( $run_sample == 1 )) && {
  source "$path_git_sync/sample_init.sh";
}



echo End `basename "$BASH_SOURCE"`
