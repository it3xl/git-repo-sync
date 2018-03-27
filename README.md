# git-sync

**git-sync** is an automated synchronization of remote Git repositories with auto conflict solving.

## Scenarios of usage

* Auto syncronizations of remote Git-repositories.
* Share a repository with limited internet access with your partners.
* Keeping of repositories neat and sane between customers and clients.

## Package

This is a working solutions out of the box. If you won't configure your repositories, then a test environment will be create.<br/>
You will receive interconnected two remote and two local repositories on your machine.<br/>
Play with it. Details below.

## How it works

There are two remote repositories. Each repository is a separate side.

You agreed that
* the first repository owns the prefix **foo-**<br/>
* the second repository owns the prefix **bar/**<br/>

Only branches with such the prefixes will be synchronized and visible on both sides.

You need to describe this in a simple config-file such as [your_repo_some_name.sh](https://github.com/it3xl/git-sync/blob/master/repo_settings/sample_repo.sh)

Now, run the git-sync periodically, better once in a minute.

That's all. You may work and forget about **git-sync**. In the case of any synchronization interrupt, **git-sync** will do everything right.

Each side is considered the owner of its prefixed branches. The owner will win in the case of any conflicting commits. Commits of a loser will be rejected, but he just has to repeat his commits again from his local repository after a Git update.

## FAQ

**Why is everything done so?** - This is an exprerience. This is robust.<br/>
**Why do not synchronize everything at once?** - For the same reason you do not use a single primary remote Git-repository. You will spend significant resources to cover this idea. Think about it - your are not a GitHub.
**Is it possible to synchronize everything at once?** - Yes. I did.
**Why do not the Git-tags sync?** - This is disabled because popular GitLab-server blocks tag deletion.

## Ready to pay for a working solution 

I am offering a complete package that includes
* Working solution
* One year support
* Daily backups of your repositories
* Notifications about conflict solving or branches deletion
* any customizations

If you are interested, then contact me at [it3xl.com](it3xl.com)

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

