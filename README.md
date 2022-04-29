# git-repo-sync

## Synchronization of Remote Git-repositories

The **git-repo-sync** synchronizes branches between two remote Git-repositories.<br/>
It is like you have two entry points to a single repository and your two remote Git-repositories will be behaving as a single repository.<br/>

**git-repo-sync** implemented as a bash script.

The main idea of this tool is to install, auto-run periodically and forget.

## Use cases

* Adhesion of Git-repositories of a client and a software/support supplier.
    * Access to your Git remote repository is restricted by your local network.
    * After completing of some work, remote access to your Git repository could be terminated.
* Provides an independence from your base remote Git repository if it is slow and could be out of service time after time.
* You software teams have independent Git remote repositories.

## How it works

Copy **git-repo-sync** somewhere

    git clone https://github.com/it3xl/git-repo-sync.git

Let **git-repo-sync** know location of your remote Git repositories.<br/>
Modify `url_a` and `url_b` variables in [default_sync_project.sh](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh).<br/>
You can use URL-s and file paths.

    url_a=https://example.com/git/my_repo.git
    
    url_b='/c/my-folder/my-local-git-repo-folder'

Run periodically the `git-sync.sh` file, which is located in the root of **git-repo-sync**.<br/>
The `git-sync.sh` will tell you if there are any troubles. The main among them is you need to update awk to gAWK on Ubuntu.

### Trade off. Redo your Git-commit in case of a conflict

Only if you and your teammate are working on the same branch but through different remote repositories.<br/>
And you run **git-repo-sync** rarely.<br/>
Let's say you both created Git-commits or Git-merge-commits.<br/>
Then **git-repo-sync** should decide whose changes will be accepted and whose will be deleted on both remote repositories for this branch.

The **git-repo-sync** uses described below sync-strategies to decide.

Let's imagine that exactly your commits were deleted by **git-repo-sync** in the remote Git-repositories in this case.<br/>
Anyway, your commits will stay locally in your local Git-repository.<br/>
Just update your local Git-repository. Make Git-rebase, merge, whatever. Do a Git-push again.

*This is a quite rare situation but you should be aware of it.*<br/>
Regular running of **git-repo-sync** decreases chances of it drastically.<br/>
This is why I create CI/CD-automations for **git-repo-sync** that are running every 2 or 5 minutes.

### On Linux

Run `git-sync.sh` and it will tell you what **git-repo-sync** needs.<br/>
In most cases you have to install gAWK. This applies to Ubuntu.<br/>
Docker Alpine Linux images require *bash* and *gAWK* to be installed.<br/>
You have to update the *bash* if you use an extra old Linux distro.

### I'm the Windows guy

Ha! You're lucky. Unlike Linux guys, you have to do nothing and have five options to run **git-repo-sync**.

Open PowerShell or CMD in the **git-repo-sync** folder and run one of three.

    "C:\Program Files\Git\bin\bash.exe" git-sync.sh
    "C:\Program Files\Git\usr\bin\bash.exe" git-sync.sh
    "C:\Program Files\Git\git-bash.exe" git-sync.sh

Or you can reinstall Git and integrate the bash into your Windows during installation. Then run

    bash  git-sync.sh

Or you can try to update the PATH environment variable. Try to add the following (that wasn't tested by me)

    ;C:\Program Files\Git\cmd;C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\usr\bin

### Do not synchronize all branches

Despite that there are [fair cases](https://github.com/it3xl/git-repo-sync/issues/3#issuecomment-771494886) when it is useful to sync all branches, this is not always a good idea.<br/>
Some well know Git-servers block some branches in different ways. Some of them create "trash"-branches which you do not want to see synchronized.<br/>

So, you can synchronize branches that have special prefixes only.<br/>
You could configure these prefixes in [default_sync_project.sh](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) configuration file.<br/>
What's important, these prefixes are related to correspondent *synchronization strategies*.

### The Victim Sync Strategy

By default all branches are synced under a Victim Synchronization Strategy.<br/>
You can do whatever you want with such branches from both remote sides (repositories).<br/>
In case of commit conflicts, any newest commit will win.<br/>
You can relocate branches to any position, delete and move them back in history if you run **git-repo-sync** regularly.<br/>
Use the following variable to limit synced branches.

    victim_branches_prefix=@

The most common value of victim_branches_prefix is "@".<br/>
In this case the following branches will be synchronized: `@dev`, `@dev-staging`, `@test`, `@test-staging`, `@my-feature`.

### The Conventional Sync Strategy

By using this strategy you limit what your teammates may do from another side repository with branches on your side remote repository.

Branches with the following prefix will be owned by the repo from [url_a](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) variable. Let's call it *A side*.

    side_a_conventional_branches_prefix=client-

Branches with the following prefix will be owned by the repo from [url_b](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) variable. Let's call it *B side*.

    side_b_conventional_branches_prefix=vendor-

Other examples of prefix pairs: `a-`, `b-`; `microsoft/`, `google/`; `foo-`, `bar-`;

On the owning side repo: You can do whatever you want with such branches.

On a repo of another side:<br/>
You can do fast-forward updates and merges.<br/>
You can move such branches back in Git-history if you run **git-repo-sync** periodically.

All commit conflicts will be solved in favor of the owning side.<br/>

### Other Unimplemented Sync Strategies

There are other interesting sync and conflict solving approaches.<br/>
For example when you don't lose your conflicting commits in your remote repositories and other teammates can resolve your conflicts after/for you.<br/>
Also it will be useful if you have a stubborn Git-server that blocks updating commits in different ways.<br/>
But the Victim and Conventional approaches cover the most important cases fairly well.

### Disaster Protection

People have to make mistakes to become better. This is normal. But let's protect our clients from such the mistakes.<br/>
Define *sync_enabling_branch* variable

    sync_enabling_branch=it3xl_git_repo_sync_enabled

Its value may represent any branch name.<br/>
Examples: `@test`, `client-prod`, `vendor-master`, `it3xl_git_repo_sync_enabled`.<br/>

The **git-repo-sync** will check if such a branch exist in both remote repositories and that it has the same or related commits, i.e. its commits are located in the same Git-tree.<br/>
This will protect you from occasional adhesion of unrelated git-repositories and deletion of branches that have the same names.<br/>
Git may store many independent projects (trees) in the same repository and this is uncommon behavior for many users.

I advise to use `it3xl_git_repo_sync_enabled` branch name to make this explicit for others that their remote Git-repo is synchronized with another remote repo.<br/>
They could search for the word *it3xl_git_repo_sync_enabled* in the Internet and understand the applied sync solution.

Be aware that a branch mentioned in the `sync_enabling_branch` variable will be alwasy synchronized by **git-repo-sync**.<br/>
Probably this is not a good idea to specify here the `master` branch name because a branch mentioned in `sync_enabling_branch` will be synchronized under the Victim strategy. But you can specify there a branch with one of your conventional prefixes for the Conventional syncing of it. For example `client-master`.

### Notes
* Usage with SSH isn't tested but possible.
* **git-repo-sync** is resilient for HTTP fails and interruptions.
* It has protections from an occasional deletion of your entire remote repository.
* Arbitrary Git-history rewriting is supported.
* Within a single installation, **git-repo-sync** can synchronize as many pairs of Git-repositories as you want. Every sync pair is a sync project for **git-repo-sync**.
* **git-repo-sync** doesn't synchronize Git-tags because some popular Git-servers block manipulations with Git-tags.
* **git-repo-sync** doesn't attempt to do Git-merge or rebase.

### Support Operations

#### Remote Repo Replacing Support

Real case of my customer. You want to synchronize your existing Git-repo with a Git-repo of your new software parnter.

Option 1.<br/>
Create a new git-repo-sync project and use it (project description file or environment variables).

Option 2.<br/>
Modify your existing project. Update its description file or environment variables.<br/>
Delete `git-repo-sync/sync-projects/<your-sync-project-name>` directory.<br/>
Start synchronization as usual.

Option 3.<br/>
Your Git-repository is extra huge and you can't recreate it. It is a TL;DR. Ask a Git-professional for a help. 

### Automation support
* **git-repo-sync** works with remote Git repositories asynchronously, by default.
* It works faster under \*nix OS-es because Git-bash on Windows is slower. But compare to network latency, this is nothing.
* You can separate change detection and synchronization phases of **git-repo-sync** for readability of build logs.
* Multiple configuration capabilities are supported. Environment, configuration files, combination of them.
* Integration with **bash Git Credential Helper - [git-cred](https://github.com/it3xl/bash-git-credential-helper)** to obtain credentials from a parent shell environment.
* You shouldn't do anything in case of connectivity fails. Continue to run **git-repo-sync** periodically and everything will be restored automatically.
* After every synchronization, analyze notification files to send notifications about branch deletions or commit conflict solving.  
See `git-repo-sync/sync-projects/<your-sync-project-name>/file-signals/`
  * `notify_solving` - for conflict solving
  * `notify_del` - for deletions
* See [instructions](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) on how to configure more synchronization pairs of remote Git repositories.
* Number of pairs is unlimited. Every pair is a separate sync project.

### Required Specification

* Use any Linux, Windows or Mac machine.
* Install Git.
* For users of \*nix OS-es.
  * update *bash* on old Linux distros.
  * check that gAWK (GNU AWK) is installed on your machine. Consider [this case](https://askubuntu.com/questions/561621/choosing-awk-version-on-ubuntu-14-04/561626#561626) if you are going to update mAWK to gAWK on Ubuntu.
* Tune any automation to run **git-repo-sync** periodically - crones, schedulers, Jenkins, GitLab-CI, etc. Or run it yourself periodically.

### Contacts

[it3xl.ru](http://it3xl.ru)
