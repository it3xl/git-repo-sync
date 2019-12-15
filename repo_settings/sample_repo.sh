
# This is a configuration file for a sample synchronization project.
# You have to create a copy of this file.

# You have two options where to store your new configuration file.
# You can put it next to this file (sample_repo.sh).
# Or you can create a sibling folder named "git-sync.repo_settings" next to the git-sync root folder.
# I.e.
# git-sync/repo_settings/  - This is the first option.
# git-sync.repo_settings/  - This is the second option.

# Change parameters below to describe your Git remote repositories that you want to synchronize.

# ! Warning!
# It is expected that you've created clones from your remote Git repositories before you start to play with gitSync.


# It is an arbitrary folder-name to stored your sync project in "git-sync/sync-projects/ folder".
#
project_folder=sample_repo


# Comment the Victim Refs parameter to disable this type of synchronization.
# You can always do whatever you want with the Victim Refs from any synchronized repository. 
# It uses "The latest action wins" conflict solving strategy.
#
#victim_refs_prefix=@


# Configure the Conventional Refs.
#
# Assign here a prefix for refs in your first repo.
#
prefix_1=a/

# Assign real URL to your first repo.
#
url_1=https://your-repo1-url.org/git/my_repo.git



# Assign here a prefix for refs of your second repo.
#
prefix_2=b-

# Assign real URL to your second repo.
url_2=https://git.your-repo2-url.org/my_repo.git






# To allow deletion of branches, provide here some branch-name.
# You can create the real branch later or change it here at any time.
#
must_exist_branch=${prefix_1}production



# Uncomment this variable to block unlimited manipulations from another side.
# We have two types of refs. Victim and Conventional.
# Conventional refs separa
#
#
# conventional_refs_another_side_block_history_rewrite=1



## Integration with git-cred.sh "bash Git Credential Helper" (https://github.com/it3xl/git-sync)
# 
# git-cred allows you to use credentials from environment variables
#  that are defined automatically by any Continues Integration (CI) tool.
#
# You can use git-cred as an external tool and tune everything manually.
# But configuring it here allows you to initialize git-cred only once during your git-sync project creation.
# Also it supports seamlessly migrations and relocations of you CI.
#
## Integration steps
#
# Load Git sub-modules of git-sync (https://github.com/it3xl/git-sync)
#
# Assign here the following variable to 1.
#
# use_bash_git_credential_helper=1
#
# Before any call to git-sync.sh or request-git-sync.sh, define in a CI-server (tool) the following environment variables
#   For the repo in $url_1
# git_cred_username_repo_1=some-login
# git_cred_password_repo_1=some-password
#   For the repo in $url_2
# git_cred_username_repo_2=another-login
# git_cred_password_repo_2=another-password




















