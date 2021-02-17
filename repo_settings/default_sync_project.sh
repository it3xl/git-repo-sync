# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync
#
## Post your questions on https://github.com/it3xl/git-repo-sync/issues
## I will be glad to explain the ambiguities and to improve this instruction for others.


# Configure location of your remote Git repositories.
#
url_a=https://example.com/git/my_repo.git
#
url_b='/c/my-folder/my-local-git-repo-folder'

# Don't sync all branches. Synchronize branches with the following prefix.
#
# victim_branches_prefix=@

# Prevent catastrophe!
# Don't sync repositories without the specified branch in the same Git-tree (same or related commits).
# 
# sync_enabling_branch=it3xl_git_repo_sync_enabled

# Limit branch manipulations for another repository side.
# See "Conventional Syncing strategy" below.
#
# side_a_conventional_branches_prefix=client-
# side_b_conventional_branches_prefix=vendor-


# Automation integration. See details below
#
# git_sync_project_folder=my-sync-project
#
# use_bash_git_credential_helper=1


#
##
### Descriptions & Explanations
##
#


## This Configuration File
#
# Variables mentioned in this file configure synchronization of two remote Git-repositories.
# Use the following options to configure your synchronization.
#
## Uncomment and modify required variables in this file.
#
## Create a copy of this file in one of the following locations
# * git-repo-sync/repo_settings
# * git-repo-sync/../git-repo-sync.repo_settings
# Pass the name of your copied file to git-sync.sh as the first parameter for every run.
# Invocation example: $ ./git-sync.sh  my-sync-project.sh
#
## Create a copy of this file in an arbitrary location.
# Pass its full path to git-sync.sh as the first parameter for every run.
# Or use a relative to "git-repo-sync" path.
#
## Declare the variables in your script or environment.
# Warning! Your configuration file will be ignored if your parent environment
#  or calling script have the git_sync_project_folder variable.

## url_a
## url_b
# Let's call your two synchronized remote Git repositories as sides A and B.
# Then url_a and url_b variables point to git remote repositories of the A and B sides accordingly.
# It could be an URL or a file path (SSH addresses wasn't tested yet).
# For paths on Windows use the following notation
# url_a="/c/my-folder/my-git-local-repo-folder"

## victim_branches_prefix
# Limit branches which will be synchronized under a Victim Syncing strategy.
# If undefined or empty then all branches will be synced.
# (except conventionally prefixed branches described below)
#
## The Victim Syncing strategy.
# You can do whatever you want with such branches from both remote sides (repositories).
# In case of a conflict, any last action will win.
# You can relocate it to any position or delete, etc.
# You can move a branch back in history if you sync your repos regularly.
#
# The most common value is "@".
# Examples: @dev, @dev-staging, @test, @test-staging

## sync_enabling_branch
# Represents any branch name.
# The git-repo-sync will check that such a branch exist in both remote repositories
# and that it has the same or related commits, i.e. located in the same Git-tree).
# This will protect you from occasional adhesion of unrelated git-repositories.
# Git may store many independent projects in the same repository and this is uncommon behavior for many users.
#
# We advise to use it3xl_git_repo_sync_enabled to make it explicit to others that their Git-repo is syncing with another remote repo.
# Examples: master, @test, client-prod, vendor-master, it3xl_git_repo_sync_enabled

## side_a_conventional_branches_prefix
# Branches with a prefix from this variable will be owned by the repo from "url_a". Let's call it A side.
#
## side_b_conventional_branches_prefix
# Branches with a prefix from this variable will be owned by the repo from "url_b". Let's call it B side.
#
# Branches with such prefixes will be updated under the Conventional Syncing strategy.
# You can define both or one variable.
#
## The Conventional Syncing strategy
# On repo of the owning side: You can do whatever you want with such branches.
# On repo of another side: You can do fast-forward updates and merges.
# You can move such a branch back in Git-history from an non-owning side if you run git-repo-sync regularly.
# All conflicts will be solved in favor of the owning side.
#
# Example of prefix pairs: client-, vendor-; a-, b-; microsoft/, google/


## git_sync_project_folder
# It defines a folder in which your sync-project artifacts will be stored inside of "git-repo-sync/sync-projects/".
# In the absence of git_sync_project_folder, its value will be taken from the name of a provided configuration file.
#
# Warning! Your configuration file will be ignored if your parent environment
#  or calling script have this variable. In this case, all required variables must be configured in the parent environment.


## use_bash_git_credential_helper=1
# This variables enables using of the "git-cred", the "bash Git Credential Helper" from https://github.com/it3xl/bash-git-credential-helper
# 
# Git-cred allows you to use Git-credential values from environment variables
#  which are defined automatically by any Continues Integration (CI/CD) tool.
#
# You can use "git-cred" as an external tool and tune everything manually.
# But configuring it here allows you to initialize git-cred only once.
# BTW, "git-cred" allows a free relocation of your installation "git-repo-sync" folder.
#
# * Before using git-cred you must complete the following steps.
#
# ** Load Git sub-modules inside of your "git-repo-sync" folder (https://github.com/it3xl/git-repo-sync)
#
# ** Before any call to "git-sync.sh" or to "request-git-sync.sh", define the following environment variables in your CI/CD automation server or tool
#   For the repo in $url_a
# git_cred_username_repo_a=some-login
# git_cred_password_repo_a=some-password
#   For the repo in $url_b
# git_cred_username_repo_b=another-login
# git_cred_password_repo_b=another-password
#
# ** Assign use_bash_git_credential_helper variable to 1.


