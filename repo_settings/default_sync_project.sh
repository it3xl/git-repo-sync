
# This is a configuration file for your synchronization project of two remote Git repositories.

# ! Warning!
# It is expected that you've created clones from your remote Git repositories before you start playing with gitSync.

# You have the following options to configure synchronization of your two remote Git-repositories.

## Uncomment and set the following variables in this file.

## Call your script file in which you have declared the variables and added git-sync.sh invocation.

## Declare the variables in your environment and then call git-sync.sh from there.

## Create a copy of this file and pass the copied file name to git-sync.sh as the first parameter for every run.
### Your file will be searched in the following folders:
### git-repo-sync/repo_settings/  - This is the first option.
### git-repo-sync.repo_settings/  - This is the second option. This folder is the sibling to gitSync root folder.
### Example: $ ./git-sync.sh my-sync-project.sh

## Create a copy of this file and pass the copied file absolute path to git-sync.sh as the first parameter for every run.


# ! Note! Synchronization artifacts of your project will be saved at "git-sync/sync-projects/<name-of-configuration-file-without-extension>".


# Change parameters below to describe your Git remote repositories and what you want to synchronize.


# Assign real URLs to your remote Git-repos. (Sorry, it just wasn't tested with SSH)
## Example
## url_a=https://your-repo1-url.org/git/my_repo.git
## url_b=https://git.your-repo2-url.org/my_repo.git
#
# url_a=
# url_b=


# Uncomment "pref_victim" parameter to allow The Victim Refs synchronization.
# All you victim branches must have a prefix from this parameter to be recognized.
# You may change "@" to another value that is valid for Git-refs naming specification.
# @ You can always do whatever you want with The Victim Refs from any synchronized repository. 
# @ It uses "The latest action wins" conflict solving strategy.
#
# pref_victim=@


# Configure the Conventional Refs.
# @ You may limit manipulations of conventional refs for a non-owner remote repository.
# @ See further parameters.
#
# pref_a_conv=a/
# pref_b_conv=b-


# Provide a name of a branch that must always exist. It allows deletion of conventional branches from a non-owner repo.
# You can create the real branch later or change here the name at any time.
## Example: must_exist_branch=my_prefix-master
#
# must_exist_branch=${pref_a_conv}production






## Integration with git-cred - "bash Git Credential Helper" (https://github.com/it3xl/git-sync)
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
# Before any call to git-sync.sh or request-git-sync.sh, define the following environment variables in a CI-server (tool)
#   For the repo in $url_a
# git_cred_username_repo_a=some-login
# git_cred_password_repo_a=some-password
#   For the repo in $url_b
# git_cred_username_repo_b=another-login
# git_cred_password_repo_b=another-password


