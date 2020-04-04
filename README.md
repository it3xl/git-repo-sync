# git-repo-sync

## Synchronization of Remote Git-repositories

**git-repo-sync** synchronizes git-branches between two remote Git-repositories.

With **git-repo-sync** you forget that your teams have two remote Git-repository.

* Only Git-branches with prefixes will be synchronized. You can configure this prefixes.
* Requires Git, bash and GAWK installed on your machine. (It could be updated to work with outdated Git, bash and AWK.)
* It has two automated conflict solving strategies which are described below.
* All possible Git-operations and synchronizatons are fully covered by auto tests.
* It is resilient for HTTP fails and interruptions. (Usage with SSH wasn't tested yet.)
* Has integration with **bash Git Credential Helper [git-cred](https://github.com/it3xl/bash-git-credential-helper)**
* It doesn't synchronize Git-tags. (Some popular Git-servers block manipulations with Git-tags.)
* You can work on the same Git-branch simultaneously in different remote Git-repositories.
* For autumation servers. For greater readability, you can separate the [verification](https://github.com/it3xl/git-repo-sync/blob/master/request-git-sync.sh) and synchronization phases across different projects.

## How it works

* You should configure 4 or more inviroment variables of **git-repo-sync** as described in this [default synchronization project](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh).
* Run [git-sync.sh](https://github.com/it3xl/git-repo-sync/blob/master/git-sync.sh) periodically.
* For automation servers. After every real syncronization analyse notification files to send notifications about a branch deletion or conflict solving.






## Git conflicts solving

Conflicts may occur only if your do merges or commits to another side branches.<br/>
The prefix owner will win in case of any conflicts.<br/>
Commits of a loser will be rejected, but he just has to repeat merge or commits again (from his local repository) after a Git update (fetch, pull, etc).<br/>

To know if your commit was reflected first run gitSync then do a Git update (fetch, pull, etc) in your local Git repository.  
Then look at Git commits log.

## FAQ

**Why is everything done so?** - This is a proven and working solution. But it is also modest and supported by a single person, me.<br/>
**Why do not synchronize everything at once?** - You will spend significant resources to do it professionally.<br/>
**Is it possible to synchronize all branches and tags?** - Yes. I had other [solutions and ideas](https://it3xl.blogspot.com/2018/02/approaches-to-synchronize-git-repos.html). No one is interested.<br/>
**Why do not sync Git-tags?** - This is disabled because some popular Git-servers block deletion of tags.

## Features

* Prevention of an occasional deletion of an entire repository.
* Deletion and creation of branches from one side repository to another.
* Auto conflict solving by [Convention over Git](https://it3xl.blogspot.com/2017/09/convention-over-git.html) (non-fast-forward branch conflicts).
* Recreation of the synchronization from any position and from scratch.
* Failover & auto recovery of synchronization is supported. Especially for network troubles.
* Solution is applied per-repository (not per-server)
* Synchronization of the Git-tags was removed because GitLab loves to block tag's deletion.
* Single non-bare Git repository is used for the synchronization.
* You can attach your automations to notify about conflict solving or a branch deletion.

## Provinding credentials for Git

I use my **bash Git Credential Helper [git-cred](https://github.com/it3xl/bash-git-credential-helper)**<br/>
It passes to Git credentials from enviroment variables created by Continues Intergration tools like Jenkins.<br/>
It is **[inegrated](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh)** now with git-repo-sync. 

## What to expect next

**Victim Branches**

I've temporary postponed this feature. Everybody can live without it. Although it is annoying.

We have some branches that reflect all our stands (dev, test, UAT, pre-prod).  
Any commit three runs complete CI/CD processes.  
It is useful to allow any team sides to put this branches at any position, on any commit.  
I think it is time to add such branches into git-repo-sync.

E.g.  
**victim/test-stand**  
**victim-test-stand**  

## The Glossary

Here is my [glossary](https://it3xl.blogspot.com/2018/02/glossary-of-synchronization-of-remote.html) related to the topic.

## How to Use

You need to describe the prefixes and simple details of your real remote repositories in a simple config-file.<br/>
Create the same file as [your_repo_some_name.sh](https://github.com/it3xl/git-repo-sync/blob/master/repo_settings/default_sync_project.sh).

Run the **git-repo-sync** and pass a path to your config file as a parameter.<br/>

    bash git-sync.sh "relative_or_absolute_path/project_settings.sh"

Run **git-repo-sync** so periodically, better once in a minute.

That's all. You may work and forget about **git-repo-sync**.<br/>
In the case of any synchronization interruption **git-repo-sync** will do everything right.

### Prepare Environment

Use any \*nix or Window machine.

Install Git

For \*nix users - update you bash and awk to any modern version

Tune any automation to invocate **git-repo-sync** periodically - crons, schedulers, Jenkins, GitLab-CI, etc.

## Contatcs

[it3xl.ru](http://it3xl.ru).
