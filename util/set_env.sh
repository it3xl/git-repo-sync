# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync

# echo;echo Start `basename "$BASH_SOURCE"`

[[ ${git_sync_env_initialized:+var_is_not_empty} ]] || {

    function need_interrupt_app(){
        func=process_need_interrupt_app
        [[ "$(type -t $func)" == 'function' ]] && {
            $func
        } || {
            echo "@@ Error! Application interruption wasn't processed."
            echo "@@ Be aware of the above error."
        }
    }; export -f need_interrupt_app

    function git_fail(){
        operation=$1
        origin=$2
        exit_code=$3
        info=${4:-}

        func=process_git_fail
        [[ "$(type -t $func)" == 'function' ]] && {
            $func $operation $origin $exit_code $info
        } || {
            echo "@@ git-operation-failed: git $operation $origin; with $exit_code exit code; $info"
        }
    }; export -f git_fail

    function git_sync_env_run_settings_script(){

        local file_name_repo_settings="${1-}"

        [[ ! "$file_name_repo_settings" ]] && {
            file_name_repo_settings="default_sync_project.sh"

            echo "Info. No configuration file in the first parameter. $file_name_repo_settings file will be used."
        }

        relative_settings_file="$path_git_sync/$file_name_repo_settings"
        relative_sibling_settings_file="$path_git_sync/../git-repo-sync.repo_settings/$file_name_repo_settings"

        absolute_settings_file="$file_name_repo_settings"
        subfolder_settings_file="$path_git_sync/repo_settings/$file_name_repo_settings"
        

        if [[ -f "$relative_settings_file" ]]; then
            echo Settings. Using relative config file. $relative_settings_file
            source "$relative_settings_file"
        elif [[ -f "$relative_sibling_settings_file" ]]; then
            echo Settings. Injecting sibling relative config file. $relative_sibling_settings_file
            source "$relative_sibling_settings_file"
        elif [[ -f "$absolute_settings_file" ]]; then
            echo Settings. Using absolute config file. $absolute_settings_file
            source "$absolute_settings_file"
        elif [[ -f "$subfolder_settings_file" ]]; then
            echo Settings. Using repo_settings subfolder config file. $subfolder_settings_file
            source "$subfolder_settings_file"
        else
            echo "Error! Exit! The first parameter must be an absolute path, relative path or a name of a file with your sync-project repo settings."
            echo The '"'$file_name_repo_settings'"' is not recognized as a file.

            exit 101;
        fi

        env_project_folder=$(basename ${file_name_repo_settings%.*})
    }

    function git_sync_env_init(){

        git_sync_env_initialized=$(date +%T)
        export git_sync_env_initialized

        export path_git_sync="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )"
        export path_git_sync_util="$path_git_sync/util"

        export env_awk_edition=${env_awk_edition:-gawk}

        type $env_awk_edition 2> /dev/null || {
            echo
            echo "Error! Exit!"
            echo
            echo "  @ Our tool is optimized to work with gawk. I.e. GNU Awk (env_awk_edition = $env_awk_edition)"
            echo "  @ You need to install gawk as we didn't adopted other AWK editions yet."
            edition_of_awk=$(awk -W version 2> /dev/null | head -n 1)
            echo "  @ Your current awk is - '$edition_of_awk'"

            echo
            echo "  @ Run the gawk command yourself as some shells show a hint on how to install it."
            echo

            exit 102;
        }

        # AWKPATH is env variable of GAWK that is used by the @include directive.
        # We need to set AWKPATH because our current directory commonly points points out to the sync Git repo, not our GAWK scripts.
        export AWKPATH="$path_git_sync_util/gawk"

        if [[ ${git_sync_project_folder:+1} ]]; then
            echo 'Info. Taking configuration from a parent environment as git_sync_project_folder is defined'

            env_project_folder=$git_sync_project_folder
        else
            echo 'Info. Seeking a configuration file provided in the first parameter as git_sync_project_folder isn''t defined'

            git_sync_env_run_settings_script "$@"
        fi

        if [[ ! ${url_a:+1} ]]; then missed_repo_settings+="url_a  "; fi
        if [[ ! ${url_b:+1} ]]; then missed_repo_settings+="url_b  "; fi

        if [[ ${missed_repo_settings:+1} ]]; then
            echo "Error! Exit! The following repo properties must be set:  $missed_repo_settings";

            exit 103;
        fi


        sync_enabling_branch=${sync_enabling_branch:-}

        pref_a_conv=${side_a_conventional_branches_prefix:-}
        pref_b_conv=${side_b_conventional_branches_prefix:-}

        # If this var is empty, then we ignore the Victim branches functionality and its "The latest action wins" conflict solving strategy.
        pref_victim=${victim_branches_prefix:-}

        conventional_prefixes_trace_values="
        pref_a_conv is '$pref_a_conv'
        pref_b_conv is '$pref_b_conv'"

        if [[ "$pref_a_conv" && "$pref_a_conv" == "$pref_b_conv" ]]; then
            echo "Error! Exit! We expected you to assign different values for conventional ref prefixes. $conventional_prefixes_trace_values"

            exit 104;
        fi;

        prefixes_trace_values="
        pref_victim is '$pref_victim' $conventional_prefixes_trace_values"

        if [[ "$pref_victim" \
            && ( "$pref_a_conv" == "$pref_victim" \
                || "$pref_b_conv" == "$pref_victim" ) ]];
        then
            echo "Error! Exit! We expect that the victim ref prefix have letters different from conventional ref prefixes. $prefixes_trace_values"

            exit 105;
        fi;
        
        export origin_a=origin_a
        export origin_b=origin_b

        all_tracks_refspec_a="refs/remotes/$origin_a"
        all_tracks_refspec_b="refs/remotes/$origin_b"

        if [[ "$pref_victim" ]]; then
            sync_ref_specs="${pref_a_conv:+${pref_a_conv}*  }${pref_b_conv:+${pref_b_conv}*  }${pref_victim:+${pref_victim}*  }$sync_enabling_branch"

            track_refspecs_a="${pref_a_conv:+refs/remotes/$origin_a/${pref_a_conv}*  }`
                            `${pref_b_conv:+refs/remotes/$origin_a/${pref_b_conv}*  }`
                            `${pref_victim:+refs/remotes/$origin_a/${pref_victim}*  }`
                            `${sync_enabling_branch:+refs/remotes/$origin_a/$sync_enabling_branch}"

            track_refspecs_b="${pref_a_conv:+refs/remotes/$origin_b/${pref_a_conv}*  }`
                            `${pref_b_conv:+refs/remotes/$origin_b/${pref_b_conv}*  }`
                            `${pref_victim:+refs/remotes/$origin_b/${pref_victim}*  }`
                            `${sync_enabling_branch:+refs/remotes/$origin_b/$sync_enabling_branch}"
        else
            echo 'Info. *All-branches-sync mode! Use "..._prefix" configuration parameters to limit synced branches.'

            sync_ref_specs=;
            track_refspecs_a=$all_tracks_refspec_a
            track_refspecs_b=$all_tracks_refspec_b
        fi

        export sync_ref_specs

        export track_refspecs_a
        export track_refspecs_b

        export pref_a_conv
        export url_a
        export pref_b_conv
        export url_b
        export pref_victim
        export sync_enabling_branch

        export use_bash_git_credential_helper=${use_bash_git_credential_helper-}

        export git_sync_pass_num=0
        export git_sync_pass_num_required=0
        export post_fetch_processing_num=0

        # The way we receive data from gawk we can't use new line char in the output. So we are using a substitution.
        export env_awk_newline_substitution='|||||'

        env_allow_async=${env_allow_async:-1}
        # env_allow_async=0
        export env_allow_async

        env_trace_refs=${env_trace_refs:-0}
        # env_trace_refs=1
        export env_trace_refs

        env_allow_multiple_sync_passes=${env_allow_multiple_sync_passes:-0}
        
        # These vars can be used for debugging and testing purposes.
        export env_awk_trace_on=1
        export env_process_if_refs_are_the_same=0

        path_project_root="$path_git_sync/sync-projects/$env_project_folder"
        export path_sync_repo="$path_project_root/sync_repo"
        # Catches outputs of the fork-join async implementation.
        export path_async_output="$path_project_root/async_output"
        signal_files_folder=file-signals
        export env_modifications_signal_file="$path_project_root/$signal_files_folder/there-are-modifications"
        export env_modifications_signal_file_a="$path_project_root/$signal_files_folder/there-are-modifications_a"
        export env_modifications_signal_file_b="$path_project_root/$signal_files_folder/there-are-modifications_b"
        export env_notify_del_file="$path_project_root/$signal_files_folder/notify_del"
        export env_notify_solving_file="$path_project_root/$signal_files_folder/notify_solving"

        export git_cred="$path_git_sync_util/bash-git-credential-helper/git-cred.sh"

    }
    git_sync_env_init "$@"

    source "$path_git_sync_util/set_base_logic.sh"
}



# echo End `basename "$BASH_SOURCE"`
