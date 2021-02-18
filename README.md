# git-repo-sync

## Synchronization of Remote Git-repositories

The **git-repo-sync** synchronizes branches between two remote Git-repositories.<br/>
It is like you have two entry points to a single repository and your two remote Git-repositories will be behaving as a single repository.<br/>

The main idea of this tool is to install, auto-run periodically and forget.

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

What if you're working on the same branch with another teammate who is working through the other side repository.<br/>
What if you both commit at the same time.<br/>
The **git-repo-sync** will decide who wins and who loses in this conflict.<br/>
Let's say if you run **git-repo-sync** once in 2 minutes.<br/>
Then update your local Git-repository after 2 minutes and check your last commit.<br/>
The losing commit will be deleted from both your remote repositories and will only remain in your local repository.<br/>
Nothing wrong with this. Just repeat your commit above the winning commit of your teammate.<br/>
*This is a quite rare situation in the Agile World and more related to the Waterfall development, but you have to know.*

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
Some well know Git-servers block some branches in different ways. Some of them create trash branches that you do not want to see synchronized.<br/>
Also, this mode is new and there hasn't been much feedback yet.

So, you can synchronize branches that have special prefixes only.<br/>
You could configure these prefixes in [default_sync_project.sh](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) configuration file.<br/>
What's important, these prefixes are related to correspondent *synchronization strategies*.

### The Victim Sync Strategy

By default all branches are synced under the Victim Synchronization Strategy.<br/>
You can do whatever you want with such branches from both remote sides (repositories).<br/>
In case of commit conflicts, any newest commit will win.<br/>
You can relocate branches to any position, delete and move them back in history if you run **git-repo-sync** regularly.<br/>
Use the following variable to limit synced branches.

    victim_branches_prefix=@

The most common value of victim_branches_prefix is "@".<br/>
In this case the following branches will be syncronized: `@dev`, `@dev-staging`, `@test`, `@test-staging`, `@my-feature`.

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

### Other Sync Strategies

There are other interesting sync and conflict solving approaches.<br/>
For example when you don't lose your conflicting commits in your remote repositories and other teammates can resolve your conflicts after/for you.<br/>
Also it is useful if you have a stubborn Git-server that blocks updating commits in different ways.
But the Victim and Conventional approaches cover the most important cases fairly well.

### Disaster Protection

People should make mistakes to become better. This is normal. But let's protect our clients from such the mistakes.<br/>
Define *sync_enabling_branch* variable

    sync_enabling_branch=it3xl_git_repo_sync_enabled

Its value may represent any branch name.<br/>
Examples: `@test`, `client-prod`, `vendor-master`, `it3xl_git_repo_sync_enabled`.<br/>

The **git-repo-sync** will check if such a branch exist in both remote repositories and that it has the same or related commits, i.e. its commits are located in the same Git-tree.<br/>
This will protect you from occasional adhesion of unrelated git-repositories and deletion of branches that have the same names.<br/>
Git may store many independent projects (trees) in the same repository and this is uncommon behavior for many users.

I advise to use it3xl_git_repo_sync_enabled branch name to make it explicit for others that their remote Git-repo is synchronized with another remote repo.<br/>
They could search for the word *it3xl_git_repo_sync_enabled* in the Internet and understand the applied sync solution.

Be aware that mentioned in the sync_enabling_branch variable branch will be synchronized by **git-repo-sync** despite branch prefix filtering that is described above.<br/>
Probably this is not a good idea to use the `master` branch name as such branches are synced under the Victim strategy. But you can specify a branch with a conveintiona prefix for the Conventional syncing of it.

### Notes
* Usage of SSH wasn't tested.
* **git-repo-sync** is resilient for HTTP fails and interruptions.
* It has protections from an occasional deletion of your entire remote repository.
* Arbitrary Git-history rewriting is supported.
* Within a single installation, **git-repo-sync** can synchronize as many pairs of Git-repositories as you want. Every sinc pair is a sync project for **git-repo-sync**.
* **git-repo-sync** doesn't synchronize Git-tags. (Some popular Git-servers block manipulations with Git-tags.)
* **git-repo-sync** is developed within the TDD approach. Therefore, its CI/CD has a huge amount of auto tests.

### CI/CD on Automation Servers support
* **git-repo-sync** works with remote Git repositories asynchronously, by default.
* It works faster under \*nix OS-es because bash on Windows could be slower. But compare to network latency, this is nothing.
* You can separate change detection and synchronization phases of **git-repo-sync** for readability.
* Multiple configuration capabilities are supported. Environment, configuration files, combination of them.
* Integration with **bash Git Credential Helper - [git-cred](https://github.com/it3xl/bash-git-credential-helper)** to obtain credentials from shell environment.
* You shouldn't do anything in case of connectivity fails. Continue to run **git-repo-sync** and everything will be restored automatically.

### Automation servers How-To
* After every synchronization, analyze notification files to send notifications about branch deletions or conflict solving.  
See `git-repo-sync/sync-projects/<your-sync-project-name>/file-signals/`
  * `notify_solving` - for conflict solving
  * `notify_del` - for deletions
* See [instructions](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh) on how to configure more synchronization pairs of remote Git repositories.
* Number of pairs is unlimited. Every pair is a separate sync project.

### Required Specification

* Use any \*nix or Window machine.
* Install Git.
* For \*nix users
  * update *bash* on old Linux distros.
  * check that gAWK (GNU AWK) is installed on your machine. Consider [this case](https://askubuntu.com/questions/561621/choosing-awk-version-on-ubuntu-14-04/561626#561626) if you are going to update mAWK to gAWK on Ubuntu.
* Tune any automation to run **git-repo-sync** periodically - crones, schedulers, Jenkins, GitLab-CI, etc. Or run it yourself.

### Contacts

[it3xl.ru](http://it3xl.ru)
