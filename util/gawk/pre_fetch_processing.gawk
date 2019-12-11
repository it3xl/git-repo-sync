
@include "base.gawk"
@include "input_processing.gawk"

END {
    main_processing();
}
function main_processing(    ref){
    generate_missing_refs();

    for(ref in refs){
        state_to_action(ref);
    }
    actions_to_refspecs();
    refspecs_to_stream();
}
function state_to_action(current_ref,    remote_sha, track_sha, side, is_victim){
    for(side in sides){
        remote_sha[side] = refs[current_ref][remote[side]][sha_key];
        track_sha[side] = refs[current_ref][track[side]][sha_key];
    }

    remote_sha[equal] = remote_sha[side_a] == remote_sha[side_b];
    track_sha[equal] = track_sha[side_a] == track_sha[side_b];
    
    if(remote_sha[equal] && track_sha[equal] && track_sha[side_a] == remote_sha[side_b])
        return;

    remote_sha[common] = remote_sha[equal] ? remote_sha[side_a] : "";
    remote_sha[empty] = !(remote_sha[side_a] || remote_sha[side_b]);

    track_sha[common] = track_sha[equal] ? track_sha[side_a] : "";
    track_sha[empty] = !(track_sha[side_a] || track_sha[side_b]);

    is_victim = index(current_ref, prefix_victims) == 1;


    if(remote_sha[empty])
        return;
    
    if(remote_sha[equal])
        request_update_tracking(current_ref, remote_sha, track_sha);

    if(remote_sha[equal])
        return;

    if(track_sha[empty])
        request_update_tracking(current_ref, remote_sha, track_sha);

    if(track_sha[empty])
        return;

    request_ff(current_ref, remote_sha, track_sha, is_victim);

    request_update_tracking(current_ref, remote_sha, track_sha);
}
function request_update_tracking(current_ref, remote_sha, track_sha){
    for(side in sides){
        if(!remote_sha[side]){
            # No the update source.
            continue;
        }
        if(remote_sha[common] == track_sha[side]){
            # No need to update. Tracking and remote refs are the same.
            continue;
        }
        # Possibly gitSync or the network was interrupted. Let's update the tracking ref.
        trace(current_ref " action-fetch from " origin[side] "; track ref is " ((track_sha[side]) ? "outdated" : "unknown"));
        a_fetch[side][current_ref];
    }
}
function request_ff(current_ref, remote_sha, track_sha, is_victim){
    if(!track_sha[equal])
        return;
    
    if(track_sha[empty])
        return;

    if(is_victim)
        return;

    for(side in sides){
        aside = asides[side];
        if(remote_sha[side] == track_sha[common] && remote_sha[aside] != track_sha[common]){
            # Let's allow updating of the another side conventional refs. Remember fast-forward updating candidates.
            trace(current_ref " check-fast-forward; outdated on " origin[side]);
            a_ff_candidate[side][current_ref];
        }
    }
}

function actions_to_refspecs(    side, aside, ref){
    for(side in a_fetch){
        for(ref in a_fetch[side]){
            out_fetch[side] = out_fetch[side] "  +" refs[ref][remote[side]][ref_key] ":" refs[ref][track[side]][ref_key];
        }
    }

    for(side in a_ff_candidate){
        aside = asides[side];
        for(ref in a_ff_candidate[side]){
            # In format order: ref; the space; side to update
            append_by_side(side, out_ff_candidates, ref " " refs[ref][remote[side]][ref_key]);
        }
    }
}

function refspecs_to_stream(){
    print out_fetch[side_a];
    print out_fetch[side_b];

    print out_ff_candidates[side_a];
    print out_ff_candidates[side_b];

    # Must print finishing line otherwise previous empty lines will be ignored by mapfile command in bash.
    print "{[end-of-results]}"
}


