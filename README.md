# git-repo-sync

## Synchronization of Remote Git-repositories

**git-repo-sync** synchronizes git-branches between two remote Git-repositories.

With this tool, you will forget that you have two remote Git-repositories for the same software product.  
The repositories will be behaving as a single remote Git-repository.  
You can imagine this as a two entry points for a single remote Git-repository.

* Only Git-branches with conventional prefixes will be synchronized. You have to configure this [prefixes](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh).
  * victim_branches_prefix  
  * side_a_conventional_branches_prefix  
  * side_b_conventional_branches_prefix
* You can work on the same Git-branch simultaneously in different remote Git-repositories.
* With a single copy of **git-repo-sync** you can synchronize as many Git-repository pairs as you want. Every pair is a sync project.
* **git-repo-sync** requires only Git and bash installed on your machine. (It could be updated to work with outdated Git, bash and AWK.)
* All possible Git-operations and synchronizatons are fully covered by auto tests.
* It has two automated conflict solving strategies which are described below.
* It is resilient for HTTP fails and interruptions. (Usage with SSH wasn't tested yet.)
* It doesn't synchronize Git-tags. (Some popular Git-servers block manipulations with Git-tags.)
* Prevention of an occasional deletion of an entire repository.
* Prevention of occasional deletions by sinchronizaion of unrelated remote Git-repositories.
* Arbitrary rewriting of history is supported.
* You even may move branches back in history.
* A single sync pass is enough in all circumstances.
* **git-repo-sync** works with remote Git repositories asynchronously, by default.

### Autumation Servers Support
* For greater readability, you can separate verification and synchronization phases across different projects.
* Multiple configuration capabilities are supported.
* **git-repo-sync** has integration with **bash Git Credential Helper [git-cred](https://github.com/it3xl/bash-git-credential-helper)**

## How To Start

* You should configure 4 or more inviroment variables of **git-repo-sync** as described in this [default synchronization project](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) file.
* Run [git-sync.sh](https://github.com/it3xl/git-repo-sync/blob/master/git-sync.sh) periodically.
* Intervals of synchronization from one minute to several hours will be enough. This is not a problem if you run it once a week or even a month.

## How To - Automation servers
* After every syncronization, analyse notification files to send notifications about branch deletions or conflict solving.
* See instructions on how to configure synchronization for another pair of remote Git repositories.
* Number of pairs is unlimited. Every pair is a separate project.

## Prefixes Examples

* `@`dev
* `company-A-`prod
* `vendor/`master
* `@`test-stand
* `client-`uat-stand

## Auto Conflicts Solving Strategies

A conflict solving strategy will be applyed based on prefixes of your branches. See how to configure these [prefixes](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh).

### Victim Strategy

For a Git-branch, the most recent action will win in case of a conflict. Even moving of a Git-branch back in a history.  

This means that everyone can do whatever they want with such branches.  
You can relocate it to any position, move it back, delete, etc.

### Conventional Strategy

Let's call your two synchronized remote Git-repositories as sides.  
Let's agree that every side owns its own prefix for Git-branches.  
Then let's call branches with these prefixes as Conventional branches.  
You can do whatever you want with Conventional branches from the owning side, i.e. repository.  
And you can only do "forward updating commits" and merges from a non-owning side.

## Required Specification

* Use any \*nix or Window machine.
* Install Git (for Windows, include bash during Git installation).
* For \*nix users - do not use outdated versions of bash.
* Tune any automation to invocate **git-repo-sync** periodically - crons, schedulers, Jenkins, GitLab-CI, etc.  
Or do it yourself.

## Contatcs

[it3xl.ru](http://it3xl.ru)
