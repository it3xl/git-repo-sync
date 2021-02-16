# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync

@include "global.gawk"


BEGIN {
    write_after_line("> change detecting");

    sync_enabling_branch = ENVIRON["sync_enabling_branch"];

    parse_refs("remote_refs_a", remote, side_a);
    parse_refs("remote_refs_b", remote, side_b);
    parse_refs("track_refs_a", track, side_a);
    parse_refs("track_refs_b", track, side_b);
    
    exit;
}

function parse_refs(env_var, dest_key, side,    split_arr, ind, val, split_val, sha, ref){
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
        
        refs[ref][side][dest_key][sha_key] = sha;
    }
}


END {
    process_emptiness();

    if(side_empty[side_both]){
        write("both-repos-are-empty")
    }
    block_sync();

    changed = 0;

    for (ref in refs) {
        a_remote = refs[ref][side_a][remote][sha_key]
        a_track = refs[ref][side_a][track][sha_key]

        b_remote = refs[ref][side_b][remote][sha_key]
        b_track = refs[ref][side_b][track][sha_key]

        if(!a_remote || !a_track || !b_remote || !b_track){
            changed = 1;
            trace(ref " has empty sha; On" (a_track?"":" a_track") (b_track?"":" b_track") (a_remote?"":" a_remote") (b_remote?"":" b_remote"))
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

function block_sync(    ref){
    if(side_empty[side_both]){
        return;
    }

    ref = sync_enabling_branch;

    if(!ref){
        return;
    }

    _block_sync_by_side(refs[ref][side_a][remote][sha_key], side_a);
    _block_sync_by_side(refs[ref][side_b][remote][sha_key], side_b);
}

function _block_sync_by_side(remote_sha, side){
    if(remote_sha){
        return;
    }
    if(remote_empty[side]){
        return;
    }

    write("Syncing is blocked as \"" sync_enabling_branch "\" branch doesn't exist in the \""side"\" remote repo");

    exit 92;
}

