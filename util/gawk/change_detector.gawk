@include "global.gawk"


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
    set_side_emptiness();

    block_sync();

    changed = 0;

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

function set_side_emptiness(    has){
    for (side in sides) {
        for (ref in refs) {
            if(!refs[ref][side][remote])
                continue;

            has[side][remote] = 1;
            break;
        }
    }

    emptiness[side_a][remote] = !has[side_a][remote]
    emptiness[side_b][remote] = !has[side_b][remote]
    emptiness[side_any][remote] = emptiness[side_a][remote] || emptiness[side_b][remote];
    emptiness[side_both][remote] = emptiness[side_a][remote] && emptiness[side_b][remote];
}

function block_sync(    ref){
    ref = same_sha_sync_enabling_branch;

    if(emptiness[side_both][remote]){

        if(!refs[ref][side_a][track] &&
            !refs[ref][side_b][track]){

            write("Syncing blocked as all remote repos have no \"" ref "\" branch");
            
            exit 91;
        }

        return;
    }

    _block_sync_by_side(refs[ref][side_a][remote], side_a);
    _block_sync_by_side(refs[ref][side_b][remote], side_b);
}
function _block_sync_by_side(remote_sha, side,    ref){
    if(remote_sha){
        return;
    }
    if(emptiness[side][remote]){
        return;
    }

    write("Syncing blocked as \"" same_sha_sync_enabling_branch "\" branch doesn't exist in the \""side"\" remote repo");

    exit 92;
}

