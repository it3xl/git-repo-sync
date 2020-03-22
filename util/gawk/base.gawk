@include "global.gawk"


function unlock_deletion(){
    if(remote_empty[side_both]){
        deletion_blocked_by = "Deletion blocked as all sides need to be restored"
        return;
    }
    if(remote_empty[side_a]){
        deletion_blocked_by = "Deletion blocked as side A needs to be restored"
        return;
    }
    if(remote_empty[side_b]){
        deletion_blocked_by = "Deletion blocked as side B needs to be restored"
        return;
    }
    
    deletion_allowed = 1;
}
function generate_missing_refs(    ref){
    for(ref in refs){
        if(!refs[ref][remote[side_a]][ref_key]){
            refs[ref][remote[side_a]][ref_key] = remote_refs_prefix ref;
        }
        if(!refs[ref][remote[side_b]][ref_key]){
            refs[ref][remote[side_b]][ref_key] = remote_refs_prefix ref;
        }
        if(!refs[ref][track[side_a]][ref_key]){
            refs[ref][track[side_a]][ref_key] = track_refs_prefix origin[side_a] "/" ref;
        }
        if(!refs[ref][track[side_b]][ref_key]){
            refs[ref][track[side_b]][ref_key] = track_refs_prefix origin[side_b] "/" ref;
        }

        # d_trace("ref is " ref);
        # d_trace("track ref_key side_a " refs[ref][track[side_a]][ref_key]);
        # d_trace("track ref_key side_b " refs[ref][track[side_b]][ref_key]);
        # d_trace("remote ref_key side_a " refs[ref][remote[side_a]][ref_key]);
        # d_trace("remote ref_key side_b " refs[ref][remote[side_b]][ref_key]);
    }
}

function append_by_side(side, host, addition){
    host[side] = host[side] (host[side] ? newline_substitution : "") addition;
}
function append_by_val(host, addition){
    host[val] = host[val] (host[val] ? newline_substitution : "") addition;
}

function use_victim_sync(ref){
    return ref == same_sha_sync_enabling_branch || index(ref, pref_victim) == 1;
}



