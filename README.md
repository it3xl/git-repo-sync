# git-sync

Automated synchronization of two remote Git repositories with auto conflict solving.

The text below is in the process of writing. Be patient. Let me know in case of any error, please.

## What it gives

You can synchronize many repositories by pairs.

Only Git-branches with special prefixes in names will be under synchronization. I.e. they will be seen on another repository.

You will have two prefixes for each of your two repositories.

Each repository is considered the owner of its prefix and brunches with this prefix in the name.

The owner will win in case of any conflicting commits. Commits of a loser will be rejected, but he have only to repeat its commits again from his local repository after an Git update.

You can attach some your automations and notify somehow about conflict solving or about any branch deletion.

## Features

* Prevention of an occasional deletion of an entire repository.
* Deletion and creation of branches in the foreign repository.
* Auto conflict resolving by [Convention over Git](http://blog.it3xl.com/2017/09/convention-over-git.html) (non-fast-forward branch conflicts).
* Recreation of the synchronization from any position and from scratch.
* Failover & auto recovery of synchronization is supported. Especially for network troubles.
* Solution is applied per-repository (vs per-server)
* Syncronization of the Git-tags was removed because GitLab loves to block tag's deletion.
* Single non-bare Git repositories is used for synchronization.


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

If you will commit to a branch more often then once in a 3 to 5 seconds, your commit may be rejcted. You will need to repeat your commit from your local repository.
