# git-repo-sync

## Synchronization of Remote Git-repositories

**git-repo-sync** synchronizes git-branches between two remote Git-repositories.  
You can synchronize as many pairs of repositories as you need.

With this tool, your two remote repositories will be behaving as a single remote Git-repository.  
You can imagine this as a two entry points for a single remote Git-repository.

* Developers can work on the same Git-branch simultaneously in different remote Git-repositories.
* Only Git-branches with conventional prefixes will be synchronized. You should configure these prefixes in
  * victim_branches_prefix [variable](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh)
  * side_a_conventional_branches_prefix [variable](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh)
  * side_b_conventional_branches_prefix [variable](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh)
* **git-repo-sync** requires only Git, bash and gAWK installed on your machine.
  * On Windows, GNU Awk (gAWK) is already included in Git installation together with **bash**.
  * It could be updated to work with outdated Git, bash and other AWK editions.
* With a single copy of **git-repo-sync** you can synchronize as many pairs of Git-repositories as you want. Every pair is a sync project.
* All possible Git-operations and synchronizations are fully covered by auto tests.
* You can access your Git remote repos by URLs or by file paths.
  * Usage with SSH wasn't tested yet but someday I will try to use it.
* It is resilient for HTTP fails and interruptions.
* It doesn't synchronize Git-tags. (Some popular Git-servers block manipulations with Git-tags.)
* It has protections from an occasional deletion of an entire repository.
* There is a protections from deletion or replacing of Git-branches by occasional synchronization of unrelated remote Git-repositories.
* Arbitrary rewriting of history is supported.
* You even may move branches back in history.
* It has two automated conflict solving strategies which are described below.

### Automation Servers Support
* **git-repo-sync** works with remote Git repositories asynchronously, by default.
* it works faster under \*nix OS-es because bash on Windows could be slower.
* A single synchronization pass will be enough in all circumstances.
* For greater readability, you can separate verification and synchronization phases across different projects.
* Multiple configuration capabilities are supported.
* **git-repo-sync** has integration with **bash Git Credential Helper - [git-cred](https://github.com/it3xl/bash-git-credential-helper)**
* You shouldn't do anything in case of connectivity fails. Continue to run **git-repo-sync** and everything will be restored automatically.

## How To Start

* You should configure 4 or more environment variables of **git-repo-sync** as described in this [default synchronization project](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) file.
* Let's protect your repositories from occasional deletion and other problems. Assignee an existing branch name to the **sync_enabling_branch** variable. Otherwise you have to create **it3xl-git_repo_sync-enabled** branch in your non empty remote repositories.
* Run [git-sync.sh](https://github.com/it3xl/git-repo-sync/blob/master/git-sync.sh) periodically.
* Intervals of synchronization from one minute to several hours will be enough. This is not a problem if you run it once a week or even a month.  
But the more often you sync, the less often automatic conflict solving is used.

## I do everything manually

In this case, take the following steps.

* Push changes to your remote Git-repository
* Sync your two repositories by running [git-sync.sh](https://github.com/it3xl/git-repo-sync/blob/master/git-sync.sh)
* Check what conflicts were during your last sync. See **notify_solving** file at 
`git-repo-sync/sync-projects/<your-sync-project-name>/file-signals/`
* Ask your team members to repeat these conflicting (rejected) commits or merges after updating of their local repos.

## How To - Automation servers
* After every synchronization, analyze notification files to send notifications about branch deletions or conflict solving.  
See `git-repo-sync/sync-projects/<your-sync-project-name>/file-signals/`
  * `notify_solving` - for conflict solving
  * `notify_del` - for deletions
* See [instructions](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) on how to configure synchronization for another pair of remote Git repositories.
* Number of pairs is unlimited. Every pair is a separate project.

## Prefixes Examples

* `@`dev
* `company-A-`prod
* `vendor/`master
* `@`test-stand
* `client-`uat-stand

## Auto Conflicts Solving Strategies

A conflict solving strategy will be applied based on prefixes of your branches. See how to configure these [prefixes](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh).  
This approach is called **Convention-Over-Git**.

### Victim Strategy

For a Git-branch, the most recent action will win in case of a conflict. Even moving of a Git-branch back in a history.  

This means that everyone can do whatever they want with such branches.  
You can relocate it to any position, move it back, delete, etc.

**Warning** for your branch assigned to **sync_enabling_branch** variable.  
If this branch name has no prefix from mentioned prefixes then it will be synchronized under the Victim strategy.

### Conventional Strategy

Conventional strategy solves conflicting Git-commits in your favor.  
It limits number of possible operations on your Git-branches for your partner from another remote Git-repository.  
And vice versa.

Let's call your two synchronized remote Git-repositories as sides.  
Let's agree that every side owns its own prefix for Git-branches.  
Then let's call branches with these prefixes as Conventional branches.  

You can do whatever you want with Conventional branches from your owning side, i.e. repository.  
But you can only do "forward updating commits" and merges for non-owned branches from another side.

## Required Specification

* Use any \*nix or Window machine.
* Install Git (for Windows, include bash during Git installation).
* For \*nix users
  * do not use outdated versions of bash.
  * check that gAWK (GNU AWK) is installed on your machine.
* Tune any automation to run **git-repo-sync** periodically - crones, schedulers, Jenkins, GitLab-CI, etc.  
Or run it yourself.

## Thoughts

You are welcomed to share your thoughts, for example in [issues](https://github.com/it3xl/git-repo-sync/issues)

## Contacts

[it3xl.ru](http://it3xl.ru)
