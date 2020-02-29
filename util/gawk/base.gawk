@include "util.gawk"

function unlock_deletion(    rr_a, rr_b, tr_a, tr_b){
    if(!must_exist_branch){
        deletion_blocked_by = "Deletion blocked as a branch that must exist on all repos isn't provided in project configuration settings"
        return;
    }

    rr_a = refs[must_exist_branch][remote[side_a]][sha_key];
    rr_b = refs[must_exist_branch][remote[side_b]][sha_key];

    tr_a = refs[must_exist_branch][track[side_a]][sha_key];
    tr_b = refs[must_exist_branch][track[side_b]][sha_key];

    deletion_blocked_by = "Deletion blocked as \"" must_exist_branch "\" branch isn't exist on all remote repos"
    if(!rr_a || !rr_b)
        return;

    deletion_blocked_by = "Deletion blocked as \"" must_exist_branch "\" branch isn't tracked yet"
    if(!tr_a || !tr_b)
        return;

    # Blocks any deletion if must_exist_branch refs are unmatched everywhere.
    # Now I'm considering that this hearts rare-sync scenarios.
    if(false){
        deletion_blocked_by = "Deletion blocked as \"" must_exist_branch "\" branch doesn't match everywhere"

        if(rr_a != rr_b)
            return;

        if(tr_a != tr_b)
            return;
            
        if(rr_a != tr_b)
            return;
    }
    
    deletion_blocked_by = ""
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





