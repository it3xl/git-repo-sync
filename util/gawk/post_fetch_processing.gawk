# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync

@include "base_processing.gawk"


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
    process_excluded_tracks();
    refspecs_to_stream();
}
function state_to_action(ref,    remote_sha, track_sha, side, is_victim, ref_type){
    if(attach_mode)
        return;
    # if(remote_empty[side_any])
    #     return;

    for(side in sides){
        remote_sha[side] = refs[ref][side][remote][sha_key];
        track_sha[side] = refs[ref][side][track][sha_key];
    }

    remote_sha[equal] = remote_sha[side_a] == remote_sha[side_b];
    track_sha[equal] = track_sha[side_a] == track_sha[side_b];
    
    if(remote_sha[equal] && track_sha[equal] && track_sha[side_a] == remote_sha[side_b])
        return;

    remote_sha[common] = remote_sha[equal] ? remote_sha[side_a] : "";
    remote_sha[empty_both] = !(remote_sha[side_a] || remote_sha[side_b]);
    remote_sha[empty_any] = !remote_sha[side_a] || !remote_sha[side_b];

    track_sha[common] = track_sha[equal] ? track_sha[side_a] : "";
    track_sha[empty_both] = !(track_sha[side_a] || track_sha[side_b]);
    track_sha[empty_any] = !track_sha[side_a] || !track_sha[side_b];

    is_victim = use_victim_sync(ref);

    if(remote_sha[empty_both]){
        # A branch in the ref was deleted manually in both repos.

        trace(ref ": action-remove-tracking-as-unknown-on-both-remotes");
        a_remove_tracking_both[ref];

        return;
    }

    # ! All further actions assume that remote refs are unequal.

    if(track_sha[empty_both]){
        trace("!Warning!");
        trace("!! Something went wrong for " ref ". It is still untracked.");
        trace("!! Possibly the program or the network were interrupted.");
        trace("!! We will try to sync it later (during the second sync pass).");

        return;
    }

    if(del_to_action(ref, is_victim, remote_sha, track_sha)){
        return;
    }
    if(move_to_refspec_by_state(ref, conv_move, is_victim)){
        return;
    }
    if(move_to_refspec_by_state(ref, victim_move, is_victim)){
        return;
    }
    if(victim_move_to_refspec(ref, remote_sha, track_sha, is_victim)){
        return;
    }
    if(ff_move_by_remote(ref, remote_sha, track_sha)){
        return;
    }

    ref_type = is_victim ? "victim" : "conv";
    trace(ref ": action-solve-all-others." ref_type "; it has different track or/and remote branch commits");
    if(is_victim){
        a_victim_solve[ref];
    }else{
        a_conv_solve[ref];
    }
}
function del_to_action(ref, is_victim, remote_sha, track_sha,    side, aside, deletion_state, unowned_ref, action_key){
    if(!track_sha[equal]){
        return;
    }

    for(side in sides){
        aside = asides[side];

        deletion_state = !remote_sha[side] && remote_sha[aside] == track_sha[common];
        if(!deletion_state){
            continue;
        }

        if(is_victim){
            if(deletion_allowed){
                trace(ref ": action-del-victim on " aside "; it is disappeared from " side);
                a_del[aside][ref];
            }else{
                trace(ref ": action-del-blocked-victim-restore on " aside "; disappeared from " side);
                a_restore_del[ref];
            }

            return 1;
        }

        unowned_ref = side_conv_ref(ref, aside);

        if(!deletion_allowed || unowned_ref){
            action_key = "action-del-blocked-conv";
            if(unowned_ref){
                action_key = action_key "&unowned-ref";
            }

            trace(ref ": " action_key " on " aside "; disappeared from " side);
            a_conv_solve[ref];
            append_by_val(out_notify_solving, "conventional-restore-as-del-blocked | " side " | " ref " | " action_key " | restoring-to:" side ":" refs[ref][side][track][sha_key]);

            return 1;
        }
        
        trace(ref ": action-del-conv on " aside "; it is disappeared from " side);
        a_del[aside][ref];

        return 1;
    }
}
function move_to_refspec_by_state(ref, source_refs, is_victim,    ref_item, action_sha, cmd, parent_sha, parent_side, child_side, action_key, moving_back, owner_action, force_key){
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


    cmd = "git merge-base " refs[ref][side_a][track][ref_key] " " refs[ref][side_b][track][ref_key];

    
    cmd | getline parent_sha;
    close(cmd);

    if(parent_sha == refs[ref][side_a][track][sha_key]){
        parent_side = side_a;
    } else if(parent_sha == refs[ref][side_b][track][sha_key]){
        parent_side = side_b;
    } else if(!parent_sha && ref == sync_enabling_branch){
        write("\nSyncing is blocked. You are trying to sync unrelated Git-remote repositories");
        write("\"" ref "\" has different SHA and has no a parent commit");
        write("\"" ref "\" located in " side_a ":" refs[ref][side_a][remote][sha_key] " vs " side_b ":" refs[ref][side_b][remote][sha_key]);
        
        exit 99;
    } else {
        # We didn't covered Git multi root cases by this logic yet.
        trace(ref ":~ rejected-move-by-state; " side_a " & " side_b " lost ff-inheritance at " parent_sha);

        return;
    }

    child_side = asides[parent_side];
    action_key = "action-fast-forward-by-state";

    moving_back = parent_sha == action_sha;
    if(moving_back){
        if(!is_victim){
            owner_action = side_conv_ref(ref, parent_side);
            if(!owner_action){
                # Moving back from a non-owner side is forbidden.
                trace(ref ":~ forbidden-moving-back-by-state; non-owner side cannot move conventional ref back");

                return;
            }
        }
        parent_side = child_side;
        child_side = asides[parent_side];
        force_key = "+";
        action_key = "action-moving-back-by-state";

        append_by_val(out_notify_solving, "moving-back-by-state | " parent_side " | " ref " | out-of " parent_side ":" refs[ref][parent_side][track][sha_key] " to " child_side ":" refs[ref][child_side][track][sha_key]);
    }
    
    trace(ref ": " action_key "; out-of " parent_side ":" refs[ref][parent_side][track][sha_key] " to " child_side ":" refs[ref][child_side][track][sha_key]);
    out_push[parent_side] = out_push[parent_side] "  " force_key refs[ref][child_side][track][ref_key] ":" refs[ref][parent_side][remote][ref_key];

    # Let's inform a calling logic that we've processed the current ref.
    return 1;
}
function victim_move_to_refspec(ref, remote_sha, track_sha, is_victim,    ref_item, action_sha, source_side, target_side){
    if(!is_victim)
        return;
    
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
    # E.g. process with ra==ta & rb==tb & ra!=rb

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

    if(action_sha != refs[ref][source_side][remote][sha_key]){
        write("\nError! The victim_move_to_refspec sync logic brocken.");
        write("\"" action_sha "\" must be " refs[ref][source_side][remote][sha_key]);
        
        cmd = "need_interrupt_app"        
        while (0 < (cmd | getline fail_text)){
            write(fail_text)
        }
        close(cmd);

        if(fail_text == "need-interrupt-app"){
            exit 97;
        }
    }
    trace(ref ": action-victim-nff-move; out-of " target_side ":" refs[ref][target_side][remote][sha_key] " to " source_side ":" refs[ref][source_side][remote][sha_key]);
    out_push[target_side] = out_push[target_side] "  +" refs[ref][source_side][track][ref_key] ":" refs[ref][target_side][remote][ref_key];

    append_by_val(out_notify_solving, "victim-non-fast-forward-move | " target_side " | " ref " | out-of " target_side ":" refs[ref][target_side][remote][sha_key] " to " source_side ":" refs[ref][source_side][remote][sha_key]);

    # Let's inform a calling logic that we've processed the current ref.
    return 1;
}
function ff_move_by_remote(ref, remote_sha, track_sha,    cmd, parent_sha, parent_side, child_side){
    # Process when ra==ta & rb==tb & ra!=rb & all not empty.
    if(remote_sha[empty_any])
        return;
    if(track_sha[empty_any])
        return;
    if(remote_sha[equal])
        return;
    if(track_sha[equal])
        return;
    if(remote_sha[side_a] != track_sha[side_a])
        return;
    if(remote_sha[side_b] != track_sha[side_b])
        return;

    cmd = "git merge-base " refs[ref][side_a][track][ref_key] " " refs[ref][side_b][track][ref_key];

    
    cmd | getline parent_sha;
    close(cmd);

    if(parent_sha == refs[ref][side_a][track][sha_key]){
        parent_side = side_a;
    } else if(parent_sha == refs[ref][side_b][track][sha_key]){
        parent_side = side_b;
    } else if(!parent_sha && ref == sync_enabling_branch){
        write("\nYou are trying to sync unrelated Git-remote repositories. Syncing is blocked");
        write("\"" ref "\" has different SHA and has no a parent commit");
        write("\"" ref "\" located in " side_a ":" refs[ref][side_a][remote][sha_key] " vs " side_b ":" refs[ref][side_b][remote][sha_key]);
        
        exit 98;
    } else {
        # We didn't covered Git multy root cases by this logic yet.
        trace(ref ":~ rejected-fast-forward-by-remote; " side_a " & " side_b " lost ff-inheritance at " parent_sha);

        return;
    }

    child_side = asides[parent_side];
    
    trace(ref ": action-fast-forward-by-remote; out-of " parent_side ":" refs[ref][parent_side][remote][sha_key] " to " child_side ":" refs[ref][child_side][track][sha_key]);
    out_push[parent_side] = out_push[parent_side] "  " refs[ref][child_side][track][ref_key] ":" refs[ref][parent_side][remote][ref_key];

    # Let's inform a calling logic that we've processed the current ref.
    return 1;
}
function actions_to_operations(    side, aside, ref, attach_both, track_sha, another_track_sha, remote_sha, ref_owner){
    if(attach_mode){
        attach_both = remote_empty[side_both];
        for(side in sides){
            if(!remote_empty[side]){
                continue
            }
            for(ref in refs){
                track_sha = refs[ref][side][track][sha_key];
                if(!track_sha){
                    continue;
                }
                if(attach_both){
                    op_push_attach_from_track[side][ref];
                    append_by_val(out_notify_solving, "attach-both-empty-sides | " side " | " ref " | restoring-to " side ":" track_sha);
                }else{
                    aside = asides[side];
                    another_track_sha = refs[ref][aside][track][sha_key];

                    op_push_attach_from_another[side][ref];
                    append_by_val(out_notify_solving, "attach-empty-side | " side " | " ref " | restoring-to " aside ":" another_track_sha);
                }
            }
        }
    }
    
    for(ref in a_remove_tracking_both){
        for(side in sides){
            track_sha = refs[ref][side][track][sha_key];
            if(!track_sha){
                continue;
            }
            op_remove_both_tracking[side][ref];
            append_by_val(out_notify_solving, "tracking-removed | " side " | " ref " | " side ":" track_sha);
        }
    }
    for(ref in a_restore_del){
        for(side in sides){
            remote_sha = refs[ref][side][remote][sha_key]
            if(remote_sha){
                continue;
            }
            op_push_restore_from_track[side][ref];
            
            track_sha = refs[ref][side][track][sha_key];
            append_by_val(out_notify_solving, "victim-restore-as-del-blocked | " side " | " ref " | restoring-to:" side ":" track_sha);
        }
    }

    for(side in a_del){
        for(ref in a_del[side]){
            op_del_track[ref];
            op_push_del[side][ref];
        }
    }

    for(side in sides){
        aside = asides[side];
        for(ref in a_conv_solve){
            ref_owner = side_conv_ref(ref, side);

            if(!ref_owner){
                continue;
            }

            if(refs[ref][side][remote][sha_key]){
                op_conv_push_nff[aside][ref];
            } else if(refs[ref][aside][remote][sha_key]){
                op_conv_push_nff[side][ref];
            }
        }
    }
}
function operations_to_refspecs(    side, aside, ref){
    for(side in op_remove_both_tracking){
        for(ref in op_remove_both_tracking[side]){
            out_remove_tracking = out_remove_tracking "  " origin[side] "/" ref;
        }
    }

    for(side in sides){
        for(ref in op_del_track){
            if(refs[ref][side][track][sha_key]){
                out_remove_tracking = out_remove_tracking "  " origin[side] "/" ref;
            }
        }
    }

    for(side in op_push_attach_from_track){
        for(ref in op_push_attach_from_track[side]){
            out_push[side] = out_push[side] "  +" refs[ref][side][track][ref_key] ":" refs[ref][side][remote][ref_key];
        }
    }

    for(side in op_push_attach_from_another){
        aside = asides[side];
        for(ref in op_push_attach_from_another[side]){
            out_push[side] = out_push[side] "  +" refs[ref][aside][track][ref_key] ":" refs[ref][side][remote][ref_key];
        }
    }

    for(side in op_push_restore_from_track){
        for(ref in op_push_restore_from_track[side]){
            out_push[side] = out_push[side] "  +" refs[ref][side][track][ref_key] ":" refs[ref][side][remote][ref_key];
        }
    }

    for(side in op_push_restore_from_another){
        aside = asides[side];
        for(ref in op_push_restore_from_another[side]){
            out_push[side] = out_push[side] "  +" refs[ref][aside][track][ref_key] ":" refs[ref][side][remote][ref_key];
        }
    }

    for(side in op_push_del){
        for(ref in op_push_del[side]){
            out_push[side] = out_push[side] "  +:" refs[ref][side][remote][ref_key];
            
            append_by_val(out_notify_del, "deletion | " side " | " ref " | " refs[ref][side][remote][sha_key]);
        }
    }

    for(side in op_conv_push_nff){
        aside = asides[side];
        for(ref in op_conv_push_nff[side]){
            out_push[side] = out_push[side] "  +" refs[ref][aside][track][ref_key] ":" refs[ref][side][remote][ref_key];

            if(refs[ref][side][remote][sha_key]){
                append_by_val(out_notify_solving, "conventional-conflict-solving | " side " | " ref " | out-of " side ":" refs[ref][side][remote][sha_key] " to " aside ":" refs[ref][aside][remote][sha_key]);
            }
        }
    }
    set_victim_refspec();

    # We may use post fetching as workaround for network fails and program interruptions.
    # Also FF-updating may fail in case of rare conflicting with a remote repo.
    # Without the post fetching these cases will not be resolved ever.
    # But we don't use it for now as we migrated to preprocessing git fetching.
    for(side in op_post_fetch){
        for(ref in op_post_fetch[side]){
            out_post_fetch[side] = out_post_fetch[side] "  +" refs[ref][side][remote][ref_key] ":" refs[ref][side][track][ref_key];
        }
    }
}

function set_victim_refspec(    ref, remote_sha_a, track_sha_a, trace_action, track_sha_a_txt, remote_sha_b, track_sha_b, track_sha_b_txt, cmd, newest_sha, side_winner, side_victim, victim_sha){
    for(ref in a_victim_solve){
        # We expects that "no sha" cases will be processed by common NFF-solving actions.
        # But this approach with variables help to solve severe errors. Also it makes code more resilient.

        remote_sha_a = refs[ref][side_a][remote][sha_key];
        track_sha_a = refs[ref][side_a][track][sha_key];

        remote_sha_b = refs[ref][side_b][remote][sha_key];
        track_sha_b = refs[ref][side_b][track][sha_key];

        # d_trace("a " ref "; track_sha_a:" track_sha_a "; remote_sha_a:" remote_sha_a);
        # d_trace("b " ref "; track_sha_b:" track_sha_b "; remote_sha_b:" remote_sha_b);

        if(track_sha_a && track_sha_b){
            # Have both tracks.
            cmd = "git rev-list " refs[ref][side_a][track][ref_key] " " refs[ref][side_b][track][ref_key] " --max-count=1"
            cmd | getline newest_sha;
            close(cmd);
        } else if(track_sha_a){
           newest_sha =  track_sha_a;
        } else if(track_sha_b){
           newest_sha =  track_sha_b;
        }

        if(newest_sha == track_sha_a){
            side_winner = side_a
            side_victim = side_b
        } else if(newest_sha == track_sha_b){
            side_winner = side_b
            side_victim = side_a
        } else {
            trace("unexpected behavior during victim solving | " ref);

            continue;
        }

        out_push[side_victim] = out_push[side_victim] "  +" refs[ref][side_winner][track][ref_key] ":" refs[ref][side_victim][remote][ref_key];

        victim_sha = refs[ref][side_victim][remote][sha_key];
        # Do not show solving for new branch creation.
        if(victim_sha){
            append_by_val(out_notify_solving, "victim-conflict-solving | " side_victim " | " ref " | out-of " victim_sha " to " side_winner ":" refs[ref][side_winner][remote][sha_key]);
        }

        trace_action = victim_sha ? "victim-conflict-solving" : "victim-empty-solving";

        track_sha_a_txt = track_sha_a ? track_sha_a : "<no-sha>";
        track_sha_b_txt = track_sha_b ? track_sha_b : "<no-sha>";
        trace(trace_action ": " ref " on " side_winner " beat " side_victim " with " track_sha_a_txt " vs " track_sha_b_txt);
    }
}

function process_excluded_tracks(    side, ref){
    parse_excluded_tracks("all_track_refs_a", side_a);
    parse_excluded_tracks("all_track_refs_b", side_b);

    for(ref in excluded_track_state){
        for(side in sides){
            trace(ref ": action-remove-excluded-track;" side ":" excluded_track_state[ref][side][sha_key] "; not under sync any more")
        }
    }

}
function parse_excluded_tracks(track_env_var, side,    split_arr, ind, val, split_val, sha, refspec, refspec_split, track_ref_path, ref){
    split(ENVIRON[track_env_var], split_arr, "\n");
    for(ind in split_arr){
        val = split_arr[ind];

        split(val, split_val, " ");

        sha = split_val[1];
        refspec = split_val[2];
        if(!sha || !refspec){
            continue;
        }

        # refs/remotes/origin_x/
        track_ref_path = track_refs_path origin[side] "/"

        split(refspec, refspec_split, track_ref_path);
        ref = refspec_split[2];

        if(sync_refs[ref]){
            continue;
        }

        excluded_track_state[ref][side][sha_key] = sha;

        out_remove_tracking = out_remove_tracking "  " origin[side] "/" ref;
    }
}

function refspecs_to_stream(    out_processing_requested){

    out_processing_requested = 0 < length(out_remove_tracking out_push[side_a] out_push[side_b] out_post_fetch[side_a] out_post_fetch[side_b]);


    print out_processing_requested;

    print out_remove_tracking;
    print out_notify_del[val_key];

    print out_push[side_a];
    print out_push[side_b];
    print out_notify_solving[val_key];

    print out_post_fetch[side_a];
    print out_post_fetch[side_b];

    # Must print finishing line otherwise previous empty lines will be ignored by mapfile command in bash.
    print "{[end-of-results]}"
}


