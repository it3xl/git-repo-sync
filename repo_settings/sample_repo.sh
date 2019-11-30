
# This file will teach you how to setup a synchronization between your two Git-repositories.
# Each such file describes a pair of remote repositories that have to be synchronized.


# I believe you'll want to store a file like this somewhere else but not in my Git-repo (https://github.com/it3xl/git-sync).
# So, you can use a sibling folder "git-sync.repo_settings" next to the git-sync root folder.
# I.e.
# git-sync/repo_settings/  - I expect you are here now and are reading this text in this file.
# git-sync.repo_settings/  - put you settings file here.



# It is extraordinarily dangerous for your repos to do a mistake here.
# More often a mess with settings from different repos will make you a pain.
# Consider to create local repositories from your remoter repositories first.

# The following settings have to be set.


# An arbitrary folder-name to stored a sync stuff.
project_folder=sample_repo



# Assign here a conventional prefix for refs in your first repo. Only prefixed refs will be synced.
# To make things simpler, I demand from you to put some char at the end here.
# I prefer to use "/", "-" or "_". And I didn't test other.
prefix_1=client_co/
# Then synced branches will be looking like this "client_co/feature_x"

# Assign here a real URL to your first repo.
url_1=https://your-repo1-url.org/git/my_repo.git



# Assign here a conventional prefix for refs of your second repo. Only prefixed refs will be synced.
prefix_2=vendor_co-
# Then synced branches will be looking like this "vendor_co-abc_feature"

# Assign here a real URL to your second repo.
url_2=https://git.your-repo2-url.org/my_repo.git



# Assign a prefix for branches with conflict solving strategy "The youngest wins".
victim_branches_prefix=common@



# You have to provide some branch-name here if you want to allow deletion of conventional (synced) refs.
# You can create the real branch later or change it here at any time.
must_exist_branch=${prefix_1}production


## Integration with git-cred.sh "bash Git Credential Helper" (https://github.com/it3xl/git-sync)
# 
# git-cred allows you to use credentials from environment variables
#  that are defined automatically by Jenkins or any other Continues Integration (CI) tool.
#
# You can use git-cred as an external tool and tune everything manually.
# But this integration allows you to call initializing of git-cred only once during your git-sync project creation.
# Also it will support you during migrations and relocations of you CI.
#
## Integration steps
#
# Load Git submodules of git-sync (https://github.com/it3xl/git-sync)
#
# Assign here (i.e. in your settings file) the following variable to 1.
# use_bash_git_credential_helper=1
#
# Before any call to git-sync.sh or request-git-sync.sh, define in Jenkins the following credential environment variables
#   For the repo in $url_1
# git_cred_username_repo_1=some-login
# git_cred_password_repo_1=some-password
#   For the repo in $url_2
# git_cred_username_repo_2=another-login
# git_cred_password_repo_2=another-password




















