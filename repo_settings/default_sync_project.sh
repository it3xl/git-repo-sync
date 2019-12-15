
# This is a configuration file for a synchronization project.

# ! Warning!
# It is expected that you've created clones from your remote Git repositories before you start playing with gitSync.

# You have two options to configure synchronization of your two remote Git-repositories.
# First
## You have to change variables in this file.
# Second
## You can create a copy of this file in the same folder.
## Then you have to pass the name of a newly created file to gitSync as the first parameter for every run.
## But this allows you to have multiple synchronization projects for multiple remote repo pairs.
## Example: $ ./git-sync.sh my-sync-project.sh
## Also you have two options where to store your new configuration file.
## git-sync/repo_settings/  - This is the first option.
## git-sync.repo_settings/  - This is the second option. This folder is the sibling to gitSync root folder.

# ! Note! Synchronization artifacts of your project will be saved at "git-sync/sync-projects/<name-of-this-file-without-extension>".


# Change parameters below to describe your Git remote repositories and what you want to synchronize.


# Assign real URLs to your remote Git-repos. (Sorry, it just wasn't tested with SSH)
## Example
## url_1=https://your-repo1-url.org/git/my_repo.git
## url_2=https://git.your-repo2-url.org/my_repo.git
#
# url_1=
# url_2=


# Uncomment "victim_refs_prefix" parameter to allow The Victim Refs synchronization.
# All you victim branches must have a prefix from this parameter to be recognized.
# You may change "@" to another value that is valid for Git-refs naming specification.
# @ You can always do whatever you want with The Victim Refs from any synchronized repository. 
# @ It uses "The latest action wins" conflict solving strategy.
#
# victim_refs_prefix=@


# Configure the Conventional Refs.
# @ You may limit manipulations of conventional refs for a non-owner remote repository.
# @ See further parameters.
#
# prefix_1=a/
# prefix_2=b-


# Provide a name of a branch that must always exist. It allows deletion of conventional branches from a non-owner repo.
# You can create the real branch later or change here the name at any time.
## Example: must_exist_branch=my_prefix-master
#
# must_exist_branch=${prefix_1}production


# Uncomment this variable to block unlimited manipulations with conventional refs from a non-owner repository.
#
# conventional_refs_another_side_block_history_rewrite=1





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
# Before any call to git-sync.sh or request-git-sync.sh, define in a CI-server (tool) the following environment variables
#   For the repo in $url_1
# git_cred_username_repo_1=some-login
# git_cred_password_repo_1=some-password
#   For the repo in $url_2
# git_cred_username_repo_2=another-login
# git_cred_password_repo_2=another-password


