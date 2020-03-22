@include "util.gawk"
@include "git_const.gawk"


BEGIN {
    write_after_line("> change detecting");

    same_sha_sync_enabling_branch = ENVIRON["same_sha_sync_enabling_branch"];
    if(!same_sha_sync_enabling_branch){
        write("Synchronization is blocked as the same_sha_sync_enabling_branch variable is empty");
        exit 81;
    }

    remote = "remote"
    track = "track"

    parse_refs("remote_refs_a", remote, side_a);
    parse_refs("remote_refs_b", remote, side_b);
    parse_refs("track_refs_a", track, side_a);
    parse_refs("track_refs_b", track, side_b);
    
    exit;
}

function parse_refs(env_var, source_key, side,    split_arr, ind, val, split_val, sha, ref){
    split(ENVIRON[env_var], split_arr, "\n");

    for(ind in split_arr){
        val = split_arr[ind];
        if(!val){
            continue;
        }

        split(val, split_val, " ");

        sha = split_val[1];
        ref = split_val[2];
        sub(/^refs\/heads\/|^refs\/remotes\/[^\/]+\//, "", ref);
        if(!ref || !sha){
            continue;
        }
        
        refs[ref][side][source_key] = sha;
    }
}
END {
    changed = 0;

    block_sync();

    for (ref in refs) {
        a_remote = refs[ref][side_a][remote]
        a_track = refs[ref][side_a][track]

        b_remote = refs[ref][side_b][remote]
        b_track = refs[ref][side_b][track]

        if(!a_remote || !a_track || !b_remote || !b_track){
            changed = 1;
            trace(ref " has empty sha")
            continue;
        }

        if(a_remote != b_remote \
            || a_track != b_track \
            || a_remote != a_track){
            changed = 1;
            trace(ref " has unequal sha")
            continue;
        }
    }

    print changed;

    write("> change detecting end");
}

function block_sync(    sha_a, sha_b, side){
    sha_a = refs[same_sha_sync_enabling_branch][side_a][remote];
    sha_b = refs[same_sha_sync_enabling_branch][side_b][remote];

    delete refs[same_sha_sync_enabling_branch];

    if(!sha_a && !sha_b){
        write("Syncing blocked as all remote repos have no \"" same_sha_sync_enabling_branch "\" branch");
        
        exit 91;
    }

    if(sha_a && sha_b && sha_a != sha_b){
        write("Syncing blocked as \"" same_sha_sync_enabling_branch "\" branch points to different commits in remote Git-repositories");
        write(sha_a "  vs  " sha_b)

        exit 92;
    }

    block_sync_non_empty(sha_a, side_a);
    block_sync_non_empty(sha_b, side_b);
}

function block_sync_non_empty(side_sha, side,    ref){
    if(side_sha){
        return;
    }

    for(ref in refs){
        if(refs[ref][side][remote]){
            write("Syncing blocked as \"" same_sha_sync_enabling_branch "\" branch doesn't exist in the \""side"\" remote repo");

            exit 92;
        }
    }
}
