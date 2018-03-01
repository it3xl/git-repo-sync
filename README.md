# git-sync

Automated synchronization of remote Git repositories with auto conflict solving.

The text below is in the process of writing. Be patient. Let me know in case of any error, please.

## Main scenarios

* You want to keep you repositories neat and sane between customers and clients.
* You have a repository with limited internet access and want it be accessible by your partners.

## What it gives

You can synchronize many repositories by pairs.

Only Git-branches with simple prefixes in names will be under synchronization. I.e. they will be seen on another repository.

You will have two prefixes for each of your two repositories.

Each repository is considered the owner of its prefix and branches with this prefix in names.

The owner will win in case of any conflicting commits. Commits of a loser will be rejected, but he have only to repeat its commits again from his local repository after an Git update.

You can attach some your automations and notify somehow about conflict solving or about any branch deletion.

## Deal

This is my business and I be glad to offer you my experience and service. And I like to evolve projects if they in-demand.<br/>
If you want to close any task and forget about it, ask me. I'm doing solutions that do not remind of themselves.<br/>
If my offer is not for you, this is even better. I'm happy to see professionals here.

Please, proceed reading further.

## Features

* Prevention of an occasional deletion of an entire repository.
* Deletion and creation of branches in the foreign repository.
* Auto conflict resolving by [Convention over Git](http://blog.it3xl.com/2017/09/convention-over-git.html) (non-fast-forward branch conflicts).
* Recreation of the synchronization from any position and from scratch.
* Failover & auto recovery of synchronization is supported. Especially for network troubles.
* Solution is applied per-repository (vs per-server)
* Syncronization of the Git-tags was removed because GitLab loves to block tag's deletion.
* Single non-bare Git repositories is used for the synchronization.


## How to Use

Read the folloving sections before you will start creating your Git-syncronizations.

### Environment

Use any \*nix or Window machine.

Install Git

For \*nix users - update you bash and awk to any modern versions

Install Jenkins to invocate **git-sync** periodically. Or use any another means - crons or schedulers.

### Tune you sync project


repo_settings\sample_repo.sh

repo_create.local

### Invocation



### Repeated Invocations



### Signals




## Known Limitations

If you will commit in the same branch more often then once in a 1 to 3 seconds, your commit may be rejected as a conflicting commit. You will need to repeat your commit from your local repository. It is pretty rare case. It should be, but I still can't obtain it. If it is a trouble, I know how to fix it.
