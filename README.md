# git-sync

**git-sync** is automated synchronization of remote Git repositories with auto conflict solving.

(The text below is in the process of writing. Be patient. Let me know in case of any error, please.)

## Scenarios of usage

* Auto syncronizations of remote Git-repositories.
* Keeping of repositories neat and sane between customers and clients.
* Share a repository with limited internet access with your partners.

## How it works

Imagine, you have a repository and you want to share this repository with your partner.<br/>
Both of you will be two sides of the same repository.

You agreed that your will be owning the prefix **foo-**<br/>
And your partner desided to use the prefix **bar/**<br/>
Only branches with such the prefixes will be synchronized and visible on both sides.

You need to describe this in a simple config-file such as [your_repo_some_name.sh](https://github.com/it3xl/git-sync/blob/master/repo_settings/sample_repo.sh)

Now, run the git-sync periodically, better once in a minute.

That's all. You may work and forget about **git-sync**. In the case of any synchronization interrupt, **git-sync** will do everything right.

Each side is considered the owner of its prefixed branches. The owner will win in the case of any conflicting commits. Commits of a loser will be rejected, but he just has to repeat his commits again from his local repository after a Git update.

## Offer

I am offering a complete package that includes
* Working system
* One year support
* Dayly backups of your repositories
* Notifications about conflict solving or deletion of a branch
* any customizations

To contact me go to [it3xl.com](it3xl.com)

## Features

* Prevention of an occasional deletion of an entire repository.
* Deletion and creation of branches in the foreign repository.
* Auto conflict resolving by [Convention over Git](http://blog.it3xl.com/2017/09/convention-over-git.html) (non-fast-forward branch conflicts).
* Recreation of the synchronization from any position and from scratch.
* Failover & auto recovery of synchronization is supported. Especially for network troubles.
* Solution is applied per-repository (vs per-server)
* Syncronization of the Git-tags was removed because GitLab loves to block tag's deletion.
* Single non-bare Git repositories is used for the synchronization.
* You can attach some your automations and notify somehow about conflict solving or about any branch deletion.


## How to Use

Read the folloving sections before you will start creating your Git-syncronizations.

### Environment

Use any \*nix or Window machine.

Install Git

For \*nix users - update you bash and awk to any modern versions

Tune any automation to invocate **git-sync** periodically - crons, schedulers, etc.

### Tune you sync project


repo_settings\sample_repo.sh

repo_create.local

### Invocation



### Repeated Invocations

