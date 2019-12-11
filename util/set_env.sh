echo
echo Start `basename "$BASH_SOURCE"`

# The $invoke_path variable comes from an external script.
export path_git_sync="$invoke_path"
export path_git_sync_util="$path_git_sync/util"

# AWKPATH is env variable of GAWK that is used by the @include directive.
# We need to set AWKPATH because our current directory commonly points points out to the sync Git repo, not our GAWK scripts.
export AWKPATH="$path_git_sync_util/gawk"

file_name_repo_settings="${1-}"

run_sample=0
[[ $# -eq 0 ]] && {
  # If there is no the first input parameter, then use with sample repos.
  run_sample=1
  file_name_repo_settings="sample_repo.sh"
}

relative_settings_file="$path_git_sync/$file_name_repo_settings"
absolute_settings_file="$file_name_repo_settings"
subfolder_settings_file="$path_git_sync/repo_settings/$file_name_repo_settings"
if [[ -f "$relative_settings_file" ]]; then
  echo Settings. Using relative. $relative_settings_file
  source "$relative_settings_file"
elif [[ -f "$absolute_settings_file" ]]; then
  echo Settings. Using absolute. $absolute_settings_file
  source "$absolute_settings_file"
elif [[ -f "$subfolder_settings_file" ]]; then
  echo Settings. Using repo_settings subfolder. $subfolder_settings_file
  source "$subfolder_settings_file"
else
  echo "Error! Exit! The first parameter must be an absolute path, relative path or a name of a file with your sync-project repo settings."
  echo The '"'$file_name_repo_settings'"' is not recognized as a file.
  
  exit 1;
fi

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

if [[ ! ${prefix_victims:+1} ]]; then
  # If this var is empty, then we ignore "The latest wins" conflict solving strategy.
  prefix_victims=
fi;

if [[ $prefix_1 == $prefix_2 \
    || $prefix_1 == $prefix_victims \
    || $prefix_2 == $prefix_victims ]];
then
  echo "Error! Exit! We expect that you assign different letters for all prefixes."
  echo "prefix_1 is $prefix_1"
  echo "prefix_2 is $prefix_2"
  echo "prefix_victims is $prefix_victims"

  exit 3
fi;

export prefix_1
export url_1
export prefix_2
export url_2
export prefix_victims
export must_exist_branch

prefix_1_safe=${prefix_1: : -1}
prefix_1_safe=${prefix_1_safe//\//-}
export prefix_1_safe

prefix_2_safe=${prefix_2: : -1}
prefix_2_safe=${prefix_2_safe//\//-}
export prefix_2_safe

export origin_1=orig_1_$prefix_1_safe
export origin_2=orig_2_$prefix_2_safe

export use_bash_git_credential_helper=${use_bash_git_credential_helper-}

# The way we receive data from gawk we can't use new line char in the output. So we are using a substitution.
export env_awk_newline_substitution='|||||'

export env_allow_async=0
export env_trace_refs=1
export env_awk_trace_on=1
export env_process_if_refs_are_the_same=1

path_project_root="$path_git_sync/sync-projects/$project_folder"
export path_sync_repo="$path_project_root/sync_repo"
# Catches outputs of the fork-join async implementation.
export path_async_output="$path_project_root/async_output"
signal_files_folder=file-signals
export env_modifications_signal_file="$path_project_root/$signal_files_folder/there-are-modifications"
export env_modifications_signal_file_1="$path_project_root/$signal_files_folder/there-are-modifications_1"
export env_modifications_signal_file_2="$path_project_root/$signal_files_folder/there-are-modifications_2"
export env_notify_del_file="$path_project_root/$signal_files_folder/notify_del"
export env_notify_solving_file="$path_project_root/$signal_files_folder/notify_solving"

export git_cred="$path_git_sync_util/bash-git-credential-helper/git-cred.sh"

(( $run_sample == 1 )) && {
  source "$path_git_sync_util/sample_init.sh";
}



echo End `basename "$BASH_SOURCE"`
