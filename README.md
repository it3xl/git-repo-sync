# git-repo-sync

## Synchronization of Remote Git-repositories

The **git-repo-sync** synchronizes branches between two remote Git-repositories.<br/>
It is like you have two entry points to a single repository and your two remote Git-repositories will be behaving as a single repository.<br/>

The main idea of this tool is to install, auto-run periodically and forget.

## How it works (short version)

Copy **git-repo-sync** somewhere

    git clone https://github.com/it3xl/git-repo-sync.git

Let **git-repo-sync** know location of your remote Git repositories.<br/>
Modify `url_a` and `url_b` variables in [default_sync_project.sh](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh).<br/>
You can use URL-s and file paths.

    url_a=https://example.com/git/my_repo.git
    #
    url_b='/c/my-folder/my-local-git-repo-folder'

Run periodically `git-sync.sh` which is located in the root of **git-repo-sync**.<br/>
The `git-sync.sh` will tell you if there are any troubles. The main among them is you need to update awk to gAWK on Ubuntu.

What if you're working on the same branch with another teammate who is working through the other side repository.<br/>
What if you both commit at the same time.<br/>
The **git-repo-sync** will decide who wins and who loses in this conflict.<br/>
Let's say if you run **git-repo-sync** once in 2 minutes.<br/>
Then update your local Git-repository ater 2 minutes and check your last commit.<br/>
The losing commit will be deleted from both your remote repositories and will only remain in your local repository.<br/>
Nothing wrong with it. Just repeat your commite above the winning commit of your teammate.<br/>
*This is a quite rare situation in the Agile World and more related to the Waterfall development, but you have to know.*

### Linux

Run `git-sync.sh` and it tell you what to do.<br/>
In most cases you have to install gAWK. This applies to Ubuntu.<br/>
Docker Alpine Linux images require *bash* and *gAWK* to be installed.<br/>
You have to update the *bash* if you use an extra old Linux distro.

### I'm the Windows guy

Ha! You're lucky. Unlike Linux guys, you have to do nothing and have five options to run **git-repo-sync**.

Open PowerShell or CMD in the **git-repo-sync** folder and run one of three.

    "C:\Program Files\Git\bin\bash.exe" git-sync.sh
    "C:\Program Files\Git\usr\bin\bash.exe" git-sync.sh
    "C:\Program Files\Git\git-bash.exe" git-sync.sh

Or you can reinstall Git and integrate the bash into your Windows during installation.

Or you can try to update the PATH environment variable. Try to add the following (that wasn't tested by me)

    ;C:\Program Files\Git\cmd;C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\usr\bin

### Do not synchronize all branches

Despite that there are [fare cases](https://github.com/it3xl/git-repo-sync/issues/3#issuecomment-771494886) when it is useful to sync all branches, this is not always a good idea.<br/>
Some well know Git-servers block some branches in different ways. Some of them create trash branches that you don not want to see synchronized.<br/>
Also, this mode is new and there hasn't been much feedback yet.

So, you can syncronize only branches that have special prefixes.<br/>
You could configure these prefixes in [default_sync_project.sh](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) configuration file<br/>
And this prefixes are related to correspondent *synchronization strategies*.

### The Victim Sync Strategy

By deafult all branches are synced unde the Victim Synchronization Strategy.<br/>
You can do whatever you want with such branches from both remote sides (repositories).<br/>
In case of commit conflicts, any newest commit will win.<br/>
You can relocate branches to any position, delete and move them back in history if you run **git-repo-sync** regularly.<br/>
Use the following variable to limit synced branches.

    victim_branches_prefix=@

The most common value is "@".
Examples: @dev, @dev-staging, @test, @test-staging


### The Conventional Sync Strategy

By this strategy you limit what your teammates may do from another side repository.

Branches with the following prefix will be owned by the repo from [url_a](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) variable. Let's call it *A side*.

    side_a_conventional_branches_prefix=client-

Branches with the following prefix will be owned by the repo from [url_b](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) variable. Let's call it *B side*.

    side_b_conventional_branches_prefix=vendor-

Other examples of prefix pairs: `a-`, `b-`; `microsoft/`, `google/`;

On the owning side repo: You can do whatever you want with such branches.

On repo of another side:<br/>
You can do fast-forward updates and merges.<br/>
You can move such branches back in Git-history if you run git-repo-sync regularly.

All commit conflicts will be solved in favor of the owning side.<br/>

### Notes
* Usage of SSH wasn't tested.
* **git-repo-sinc** is resilient for HTTP fails and interruptions.
* It has protections from an occasional deletion of your entire repository.
* There is a protections from deletion or replacing of Git-branches by occasional synchronization of unrelated remote Git-repositories.
* Arbitrary rewriting of history is supported.
* You even may move branches back in history.
* With a single installation of **git-repo-sync** you can synchronize as many pairs of Git-repositories as you want. Every pair is a sync project.
* It doesn't synchronize Git-tags. (Some popular Git-servers block manipulations with Git-tags.)
* I've dropped unprefixed branches support and configuring for simplicity.

### Installation

(It is under writing since 2021.02.18)

### Configuring

(It is under writing since 2021.02.18)

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
* Let's protect your repositories from occasional deletion and other problems. Assignee an existing branch name to the **sync_enabling_branch** variable. Otherwise you have to create **it3xl_git_repo_sync_enabled** branch in your non empty remote repositories.
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
If this branch name doesn't have a prefix from the mentioned prefixes, it will be synchronized according to the Victim strategy.

### Conventional Strategy

Conventional strategy solves conflicting Git-commits in your favor.  
And it limits number of possible operations on your Git-branches for your partner from his remote Git-repository.  
And vice versa.

Let's call some two synchronized remote Git-repositories as sides.  
Let's agree that every side owns its own prefix for Git-branches.  

You can do whatever you want with branches that your side owns.  
But you can only do "forward updating commits" and merges for non-owned branches of another side.

## Required Specification

* Use any \*nix or Window machine.
* Install Git (for Windows, include bash during Git installation).
* For \*nix users
  * do not use outdated versions of bash.
  * check that gAWK (GNU AWK) is installed on your machine. Consider [this case](https://askubuntu.com/questions/561621/choosing-awk-version-on-ubuntu-14-04/561626#561626) if you are going to update mAWK to gAWK on Ubuntu.
* Tune any automation to run **git-repo-sync** periodically - crones, schedulers, Jenkins, GitLab-CI, etc.  
Or run it yourself.

## Thoughts

You are welcomed to share your thoughts, for example in [issues](https://github.com/it3xl/git-repo-sync/issues)

## Contacts

[it3xl.ru](http://it3xl.ru)
