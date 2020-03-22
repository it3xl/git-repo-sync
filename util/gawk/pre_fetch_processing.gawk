@include "base.gawk"


BEGIN {
    write_after_line("> pre processing");
}

@include "input_processing.gawk"

END {
    main_processing();
    write("> pre processing end");
}
function main_processing(    ref){
    generate_missing_refs();

    for(ref in refs){
        state_to_action(ref);
    }
    actions_to_refspecs();
    refspecs_to_stream();
}
function state_to_action(ref,    remote_sha, track_sha, side, is_victim){
    for(side in sides){
        remote_sha[side] = refs[ref][side][remote][sha_key];
        track_sha[side] = refs[ref][side][track][sha_key];
    }

    remote_sha[equal] = remote_sha[side_a] == remote_sha[side_b];
    track_sha[equal] = track_sha[side_a] == track_sha[side_b];
    
    if(remote_sha[equal] && track_sha[equal] && track_sha[side_a] == remote_sha[side_b])
        return;

    remote_sha[common] = remote_sha[equal] ? remote_sha[side_a] : "";
    remote_sha[empty] = !(remote_sha[side_a] || remote_sha[side_b]);
    remote_sha[empty_any] = !remote_sha[side_a] || !remote_sha[side_b];

    track_sha[common] = track_sha[equal] ? track_sha[side_a] : "";
    track_sha[empty] = !(track_sha[side_a] || track_sha[side_b]);
    track_sha[empty_any] = !track_sha[side_a] || !track_sha[side_b];

    is_victim = use_victim_sync(ref);

    if(remote_sha[empty])
        return;
    
    request_victim_move(ref, remote_sha, track_sha, is_victim);

    if(remote_sha[equal]){
        request_update_tracking(ref, remote_sha, track_sha);
        
        return;
    }

    if(track_sha[empty]){
        request_update_tracking(ref, remote_sha, track_sha);

        return;
    }

    request_update_tracking(ref, remote_sha, track_sha);
    
    request_conv_move(ref, remote_sha, track_sha, is_victim);
}
function request_update_tracking(ref, remote_sha, track_sha){
    for(side in sides){
        if(!remote_sha[side]){
            # No an update source.
            continue;
        }
        if(remote_sha[side] == track_sha[side]){
            # No need to update. Tracking and remote refs are the same.
            continue;
        }

        # Possibly gitSync or the network was interrupted.
        # Or this ref was moved back.
        # But the default scenario is that the remote ref was modified.
        # Let's update the tracking ref.
        trace(ref " action-fetch from " origin[side] "; " ((track_sha[side]) ? "track ref is outdated" : "track ref is unknown"));
        a_fetch[side][ref];
    }
}
function request_conv_move(ref, remote_sha, track_sha, is_victim,    side, aside, ref_owner){
    if(is_victim)
        return;

    if(!track_sha[equal])
        return;
    
    if(track_sha[empty])
        return;

    for(side in sides){
        
        # d_trace(ref_owner " " side " " ref " " prefix[side]);

        if(!remote_sha[side]){
            continue;
        }

        if(remote_sha[side] == track_sha[side]){
            continue;
        }

        aside = asides[side];
        if(remote_sha[aside] != track_sha[aside]){
            continue;
        }

        # Let's allow updating of the another side conventional refs. Remember fast-forward updating candidates.
        trace(ref " check-conventional-move; outdated on " origin[side]);
        a_conv_move[ref][remote_sha[side]];
    }
}
function request_victim_move(ref, remote_sha, track_sha, is_victim,    side, aside){
    if(!is_victim)
        return;

    if(remote_sha[empty_any])
        return;
    if(track_sha[empty_any])
        return;

    if(remote_sha[equal])
        return;

    if(!track_sha[equal])
        return;
    
    # We expect that request_update_tracking will request required here fetching.

    for(side in sides){

        if(remote_sha[side] == track_sha[side]){
            continue;
        }

        aside = asides[side];
        if(remote_sha[aside] != track_sha[aside]){
            continue;
        }

        # Let's allow updating of the another side conventional refs. Remember fast-forward updating candidates.
        trace(ref " request-non-fast-forward; ref changed on " origin[side] " only");
        a_victim_move[ref][remote_sha[side]];
    }
}

function actions_to_refspecs(    side, aside, ref){
    for(side in a_fetch){
        for(ref in a_fetch[side]){
            out_fetch[side] = out_fetch[side] "  +" refs[ref][side][remote][ref_key] ":" refs[ref][side][track][ref_key];
        }
    }

    for(ref in a_conv_move){
        for(sha in a_conv_move[ref]){
            append_by_val(out_conv_move, ref " " sha);
        }
    }

    for(ref in a_victim_move){
        for(sha in a_victim_move[ref]){
            append_by_val(out_victim_move, ref " " sha);
        }
    }
}

function refspecs_to_stream(){
    print out_fetch[side_a];
    print out_fetch[side_b];

    print out_conv_move[val];
    print out_victim_move[val];

    # Must print finishing line otherwise previous empty lines will be ignored by mapfile command in bash.
    print "{[end-of-results]}"
}


