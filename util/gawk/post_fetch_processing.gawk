
@include "base.gawk"

BEGIN {
    write_after_line("> main processing");
}

@include "input_processing.gawk"

END {
    main_processing();
    write("> main processing end");
}

function main_processing(    ref){
    generate_missing_refs();

    unlock_deletion();
    if(!deletion_allowed){
        write(deletion_blocked_by);
    }

    for(ref in refs){
        state_to_action(ref);
    }
    actions_to_operations();
    operations_to_refspecs();
    refspecs_to_stream();
}
function state_to_action(ref,    remote_sha, track_sha, side, aside, is_victim, ref_type){
    for(side in sides){
        remote_sha[side] = refs[ref][remote[side]][sha_key];
        track_sha[side] = refs[ref][track[side]][sha_key];
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

    is_victim = index(ref, pref_victim) == 1;

    if(remote_sha[empty]){
        # As we here this means that remote repos don't know the current ref but gitSync knows it somehow.

        trace(ref ": action-restore on both remotes; is unknown");
        # This actions supports independents of gitSync from its remoter repos.
        # I.e. you can replace remote repos all at once, as gitSync will be the source of truth.
        # But if you don't run gitSync for a while and have deleted a branch on both side repos manually then gitSync will recreate it.
        # Re-delete the branch again and use gitSync. Silly))
        a_restore[ref];

        return;
    }

    # ! All further actions assume that remote refs are unequal.

    if(track_sha[empty]){
        trace("!Warning!");
        trace("!! Something went wrong for " ref ". It is still untracked.");
        trace("!! Possibly the program or the network were interrupted.");
        trace("!! We will try to sync it during the second sync pass.");

        return;
    }

    ref_type = is_victim ? "victim" : "conv";

    if(track_sha[equal]){
        for(side in sides){
            aside = asides[side];
            if(!remote_sha[side] && remote_sha[aside] == track_sha[common]){
                if(deletion_allowed){
                    trace(ref ": action-del on " origin[aside] "; it is disappeared from " origin[side]);
                    a_del[aside][ref];
                }else{
                    trace(ref "; " ref_type ":action-solve-as-del-blocked on " origin[aside] "; is disappeared from " origin[side] " and deletion is blocked");
                    set_solve_action(is_victim, ref);
                }

                return;
            }
        }
    }

    if(move_to_refspec(ref, conv_move, is_victim)){
        return;
    }
    if(move_to_refspec(ref, victim_move, is_victim)){
        return;
    }
    if(victim_move_to_refspec(ref, remote_sha, track_sha)){
        return;
    }

    trace(ref "; " ref_type ":action-solve-all-others; it has different track or/and remote branch commits");
    set_solve_action(is_victim, ref);
}
function set_solve_action(is_victim, ref){
    if(is_victim){
        a_victim_solve[ref];
    }else{
        a_solve[ref];
    }
}
function move_to_refspec(ref, source_refs, is_victim,    ref_item, action_sha, cmd, parent_sha, parent_side, child_side, action_key, moving_back, owner_action, force_key){
    for(ref_item in source_refs){
        if(ref_item != ref){
            continue;
        }
        for(action_sha in source_refs[ref_item]){}

        break;
    }
    if(ref_item != ref){
        return;
    }

    cmd = "git merge-base " refs[ref][track[side_a]][ref_key] " " refs[ref][track[side_b]][ref_key];
    
    cmd | getline parent_sha;
    close(cmd);

    if(parent_sha == refs[ref][track[side_a]][sha_key]){
        parent_side = side_a;
    } else if(parent_sha == refs[ref][track[side_b]][sha_key]){
        parent_side = side_b;
    } else{
        trace(ref " rejected-move; " origin[side_a] " & " origin[side_b] " lost direct inheritance at " parent_sha);

        return;
    }

    child_side = asides[parent_side];
    action_key = "action-fast-forward";

    moving_back = parent_sha == action_sha;
    if(moving_back){
        if(!is_victim){
            owner_action = index(ref, prefix[parent_side]) == 1;
            if(!owner_action){
                # Moving back from a non-owner side is forbidden.
                return;
            }
        }
        parent_side = child_side;
        child_side = asides[parent_side];
        force_key = "+";
        action_key = "action-moving-back";

        append_by_val(out_notify_solving, "moving-back | " prefix[parent_side] " | " ref " | out-of " refs[ref][track[parent_side]][sha_key] " to " refs[ref][track[child_side]][sha_key]);
    }
    
    trace(ref " " action_key "; from " origin[parent_side] " to " origin[child_side]);
    out_push[parent_side] = out_push[parent_side] "  " force_key refs[ref][track[child_side]][ref_key] ":" refs[ref][remote[parent_side]][ref_key];

    # Let's inform a calling logic that we've processed the current ref.
    return 1;
}
function victim_move_to_refspec(ref, remote_sha, track_sha,    ref_item, action_sha, source_side, target_side){
    for(ref_item in victim_move){
        if(ref_item != ref){
            continue;
        }
        for(action_sha in victim_move[ref_item]){}

        break;
    }
    if(ref_item != ref){
        return;
    }

    # The idea below is to ignore a candidate ref if sha was changed since last check.
    # E.g. obey ra==la & rb==lb & ra!=rb

    if(remote_sha[equal])
        return;
    if(track_sha[equal])
        return;

    if(remote_sha[side_a] != track_sha[side_a])
        return;
    if(remote_sha[side_b] != track_sha[side_b])
        return;

    if(remote_sha[side_a] != action_sha && remote_sha[side_b] != action_sha)
        return;

    if(remote_sha[side_a] == action_sha){
        source_side = side_a;
    } else if(remote_sha[side_b] == action_sha){
        source_side = side_b;
    } else {
        return;
    }

    target_side = asides[source_side];

    trace(ref " action-non-fast-forward to " action_sha);
    out_push[target_side] = out_push[target_side] "  +" refs[ref][track[source_side]][ref_key] ":" refs[ref][remote[target_side]][ref_key];

    # Let's inform a calling logic that we've processed the current ref.
    return 1;
}
function actions_to_operations(    side, aside, ref, ref_owner){
    for(ref in a_restore){
        for(side in sides){
            if(!refs[ref][track[side]][sha_key]){
                continue;
            }
            op_push_restore[side][ref];
            #op_post_fetch[side][ref];
        }
    }

    for(side in a_del){
        for(ref in a_del[side]){
            op_del_track[ref];
            op_push_del[side][ref];
        }
    }

    for(side in sides){
        for(ref in a_victim_solve){
            op_victim_winner_search[ref];
        }
    }

    for(side in sides){
        aside = asides[side];
        for(ref in a_solve){
            ref_owner = index(ref, prefix[side]) == 1;

            if(!ref_owner){
                continue;
            }

            if(refs[ref][remote[side]][sha_key]){
                op_push_nff[aside][ref];
                #op_post_fetch[aside][ref];
            } else if(refs[ref][remote[aside]][sha_key]){
                op_push_nff[side][ref];
                #op_post_fetch[side][ref];
            }
        }
    }
}
function operations_to_refspecs(    side, aside, ref){
    for(side in sides){
        for(ref in op_del_track){
            if(refs[ref][track[side]][sha_key]){
                out_del = out_del "  " origin[side] "/" ref;
            }
        }
    }

    for(side in op_push_restore){
        for(ref in op_push_restore[side]){
            out_push[side] = out_push[side] "  +" refs[ref][track[side]][ref_key] ":" refs[ref][remote[side]][ref_key];
        }
    }

    for(side in op_push_del){
        for(ref in op_push_del[side]){
            out_push[side] = out_push[side] "  +:" refs[ref][remote[side]][ref_key];
            
            append_by_val(out_notify_del, "deletion | " prefix[side] " | " ref " | " refs[ref][remote[side]][sha_key]);
        }
    }

    for(side in op_push_nff){
        aside = asides[side];
        for(ref in op_push_nff[side]){
            out_push[side] = out_push[side] "  +" refs[ref][track[aside]][ref_key] ":" refs[ref][remote[side]][ref_key];

            if(refs[ref][remote[side]][sha_key]){
                append_by_val(out_notify_solving, "conflict-solving | " prefix[side] " | " ref " | out-of " refs[ref][remote[side]][sha_key] " to " refs[ref][remote[aside]][sha_key]);
            }
        }
    }
    set_victim_refspec();

    # We may use post fetching as workaround for network fails and program interruptions.
    # Also FF-updating may fail in case of rare conflicting with a remote repo.
    # Without the post fetching these cases will not be resolved ever.
    # But we don't use it for now as we've migrated to preprocessing git fetching.
    for(side in op_post_fetch){
        for(ref in op_post_fetch[side]){
            out_post_fetch[side] = out_post_fetch[side] "  +" refs[ref][remote[side]][ref_key] ":" refs[ref][track[side]][ref_key];
        }
    }
}

function set_victim_refspec(    ref, sha_a, sha_a_txt, sha_b, sha_b_txt, cmd, newest_sha, side_winner, side_victim){
    for(ref in op_victim_winner_search){
        # We expects that "no sha" cases will be processed by common NFF-solving actions.
        # But this approach with variables help to solve severe errors. Also it makes code more resilient.
        sha_a = refs[ref][track[side_a]][sha_key];
        sha_a_txt = sha_a ? sha_a : "<no-sha>"
        sha_b = refs[ref][track[side_b]][sha_key];
        sha_b_txt = sha_b ? sha_b : "<no-sha>"

        if(sha_a && sha_b){
            cmd = "git rev-list " refs[ref][track[side_a]][ref_key] " " refs[ref][track[side_b]][ref_key] " --max-count=1"
            cmd | getline newest_sha;
            close(cmd);
        } else if(sha_a){
           newest_sha =  sha_a;
        } else if(sha_b){
           newest_sha =  sha_b;
        }

        if(newest_sha == sha_a){
            side_winner = side_a
            side_victim = side_b
        } else if(newest_sha == sha_b){
            side_winner = side_b
            side_victim = side_a
        } else {
            trace("unexpected behavior during victim solving | " ref);

            continue;
        }

        trace("victim-solving: " ref " on " origin[side_winner] " beat " origin[side_victim] " with " sha_a_txt " vs " sha_b_txt);

        out_push[side_victim] = out_push[side_victim] "  +" refs[ref][track[side_winner]][ref_key] ":" refs[ref][remote[side_victim]][ref_key];

        append_by_val(out_notify_solving, "victim-solving | " prefix[side_victim] " | " ref " | out-of " refs[ref][remote[side_victim]][sha_key] " to " refs[ref][remote[aside]][side_winner]);
    }
}

function refspecs_to_stream(){
    print out_del;
    print out_notify_del[val];

    print out_push[side_a];
    print out_push[side_b];
    print out_notify_solving[val];

    print out_post_fetch[side_a];
    print out_post_fetch[side_b];

    # Must print finishing line otherwise previous empty lines will be ignored by mapfile command in bash.
    print "{[end-of-results]}"
}


