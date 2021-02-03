set -euf +x -o pipefail


function delete_project_repo_and_exit() {
    echo Deletion of "$path_sync_repo" to allow restart git-cred initializing.
    rm -rf "$path_sync_repo"
    
    echo Interruption on error.
    
    exit 1;
}

function create_sync_repo(){
    if [[ -f "$path_sync_repo/.git/config" ]]; then
        return
    fi

    echo @ `basename "$BASH_SOURCE"` started

    mkdir -p "$path_sync_repo"
    cd "$path_sync_repo"

    git init

    git config --local advice.pushUpdateRejected false
    #git config --local core.logAllRefUpdates

    git remote add $origin_a "$url_a"
    git remote add $origin_b "$url_b"


    [[ "$use_bash_git_credential_helper" == "1" ]] && {
        echo Initializing git-cred as use_bash_git_credential_helper is set to $use_bash_git_credential_helper

        if [[ ! -f "$git_cred" ]]; then
            echo
            echo Error! Exit! You have to update/download Git-SubModules of git-repo-sync project to use $git_cred
            echo Run '"'git submodule init\; git submodule update --recursive'"' in the root folder of git-repo-sync.
            echo Or comment out '"'use_bash_git_credential_helper=1'"' in your sync project settings file.
            echo
            
            delete_project_repo_and_exit
        fi
        
        GIT_CRED_DO_NOT_EXIT=1
        
        source "$git_cred"  init  repo_a  $url_a
        [[ $GIT_CRED_FAILED != 0 ]] && delete_project_repo_and_exit
        
        source "$git_cred"  init  repo_b  $url_b
        [[ $GIT_CRED_FAILED != 0 ]] && delete_project_repo_and_exit
    }


    echo Repo created at $path_sync_repo

    echo @ `basename "$BASH_SOURCE"` ended
}
create_sync_repo







