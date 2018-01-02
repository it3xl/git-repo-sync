# Set your values below


# It is extraordinarily dangerous for your repo to do a mistake here.
# More often a mess with settings from different repos hurts you here.


# A folder-name where will be stored local repos for syncing.
project_folder=sample_repo


# A conventional prefix for refs for repo 1.
prefix_1=client_co/
#url_1=https://your-repo1-url.org/git/my_repo.git
url_1="$path_git_sync/sample_repos/remote_$prefix_1"


# A conventional prefix for refs for repo 1.
prefix_2=vendor_co-
#url_2=https://git.your-repo2-url.org/my_repo.git
url_2="$path_git_sync/sample_repos/remote_$prefix_2"


# Some branch that must exist on both sides to allow any deletion of refs.
must_exist_branch=${prefix_1}production



