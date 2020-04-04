# git-repo-sync

## Synchronization of Remote Git-repositories

**git-repo-sync** synchronizes git-branches between two remote Git-repositories.

With **git-repo-sync** you forget that your teams have two remote Git-repository.

* Only Git-branches with prefixes will be synchronized. You can configure this prefixes.
* Requires Git and bash installed on your machine. (It could be updated to work with outdated Git, bash and AWK.)
* It has two automated conflict solving strategies which are described below.
* All possible Git-operations and synchronizatons are fully covered by auto tests.
* It is resilient for HTTP fails and interruptions. (Usage with SSH wasn't tested yet.)
* Has integration with **bash Git Credential Helper [git-cred](https://github.com/it3xl/bash-git-credential-helper)**
* It doesn't synchronize Git-tags. (Some popular Git-servers block manipulations with Git-tags.)
* You can work on the same Git-branch simultaneously in different remote Git-repositories.
* Prevention of an occasional deletion of an entire repository.
* Prevention of occasional deletions by sinchronizaion of unrelated remote Git-repositories.
* Arbitrary history rewriting.
* Moving branches back in history.
* A single sync pass is enough in all circumstances.
* For autumation servers. For greater readability, you can separate the [verification](https://github.com/it3xl/git-repo-sync/blob/master/request-git-sync.sh) and synchronization phases across different projects.

## How it works

* You should configure 4 or more inviroment variables of **git-repo-sync** as described in this [default synchronization project](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh).
* Run [git-sync.sh](https://github.com/it3xl/git-repo-sync/blob/master/git-sync.sh) periodically.
* Intervals of synchronization from one minute to several hours will be enough. It is not a trouble to run it once in a week.
* For automation servers. After every syncronization, analyse notification files to send notifications about branch deletions or conflict solving.

## Prefixes Examples

* <b>@</b>dev
* <b>company-A-</b>prod
* <b>vendor/</b>master
* <b>@</b>test-stand
* <b>client-</b>uat-stand

## Auto Conflicts Solving Strategies

Conflict solving strategy will be applyed based on [prefixes]https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh of your branches.

### Victim

For a Git-branch, the most recent action will win. Even moving of a Git-branch back in history.

### Conventional




## Required Specifications

* Use any \*nix or Window machine.
* Install Git.
* For \*nix users - do not use outdated versions of bash.
* Tune any automation to invocate **git-repo-sync** periodically - crons, schedulers, Jenkins, GitLab-CI, etc.

## Contatcs

[it3xl.ru](http://it3xl.ru).
