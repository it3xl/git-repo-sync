
# !Warning!
#
# If you want your remote Git-repositories to be synchronized by this tool then they have to have
#   it3xl-git_repo_sync-enabled   branch on the same commit (i.e. the same SHA).
# Exception, if you're synchronizing an empty Git-repository with a repository that has this branch.
# You can change this branch name by changing a value of the variable sync_enabling_branch.
#
# sync_enabling_branch=it3xl-git_repo_sync-enabled


# This is a configuration file for your synchronization project of two remote Git repositories.
#
# You have the following options to configure synchronization of your two remote Git-repositories.
#
## Uncomment and set the following variables in this file.
#
## Call your script file in which you have declared the variables and added git-sync.sh invocation.
#
## Declare the variables in your environment and then call git-sync.sh from there.
#
## Create a copy of this file and pass the copied file name to git-sync.sh as the first parameter for every run.
### Your file will be searched in the following folders:
### git-repo-sync/repo_settings/  - This is the first option.
### git-repo-sync.repo_settings/  - This is the second option. This folder is the sibling to gitSync root folder.
### Example: $ ./git-sync.sh my-sync-project.sh
#
## Create a copy of this file and pass the copied file absolute path to git-sync.sh as the first parameter for every run.


# ! Note! Synchronization artifacts of your project will be saved at "git-sync/sync-projects/<name-of-configuration-file-without-extension>".


# Change variables below to describe your Git remote repositories and how you want to synchronize.

# Assign real URLs to your remote Git-repos. (Sorry, it just wasn't tested with SSH)
## Example
## url_a=https://your-repo1-url.org/git/my_repo.git
## url_b=https://git.your-repo2-url.org/my_repo.git
#
# url_a=
# url_b=

# Configure a prefix of the Victim Ref Sync functionality if you wish to use this type of syncing.
#
# victim_branches_prefix=@

# Configure prefixes of the Conventional Ref Sync functionality if you wish to use this type of syncing.
#
# side_a_conventional_branches_prefix=a-
# side_b_conventional_branches_prefix=b-



# !Additional configuration notes!

# Integration with git-cred, the "bash Git Credential Helper" from https://github.com/it3xl/git-sync
# 
# The git-cred allows you to use credential values from environment variables
#  that are defined automatically by any Continues Integration (CI) tool.
#
# You can use git-cred as an external tool and tune everything manually.
# But configuring it here allows you to initialize git-cred only once during your git-repo-sync project creation.
# Also git-cred supports seamlessly migrations and relocations of your CI tool.
#
# Integration steps
#
# Load Git sub-modules of git-sync (https://github.com/it3xl/git-sync)
#
# Before any call to git-sync.sh or request-git-sync.sh, define the following environment variables in your CI-server (tool)
#   For the repo in $url_a
# git_cred_username_repo_a=some-login
# git_cred_password_repo_a=some-password
#   For the repo in $url_b
# git_cred_username_repo_b=another-login
# git_cred_password_repo_b=another-password
#
# Assign the following variable to 1.
#
# use_bash_git_credential_helper=1


