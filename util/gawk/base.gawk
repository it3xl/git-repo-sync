@include util.gawk


function unlock_deletion(    rr_a, rr_b, tr_a, tr_b){
    rr_a = refs[must_exist_branch][remote[side_a]][sha_key];
    if(!rr_a)
        return;

    tr_a = refs[must_exist_branch][track[side_a]][sha_key];
    if(!tr_a)
        return;

    rr_b = refs[must_exist_branch][remote[side_b]][sha_key];
    if(rr_a != rr_b)
        return;

    tr_b = refs[must_exist_branch][track[side_b]][sha_key];
    if(tr_a != tr_b)
        return;
        
    if(rr_a != tr_b)
        return;
    
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
    }
}

function append_by_side(host, side, addition){
    host[side] = host[side] (host[side] ? newline_substitution : "") addition;
}
function append_by_val(host, addition){
    host[val] = host[val] (host[val] ? newline_substitution : "") addition;
}





