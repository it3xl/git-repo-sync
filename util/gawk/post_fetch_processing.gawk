
@include "base.gawk"
@include "input_processing.gawk"

END {
    write_after_line("> main processing");
    main_processing();
    write("> main processing end");
}

function main_processing(    ref){
    deletion_allowed = 0;
    unlock_deletion();
    write("Deletion " ((deletion_allowed) ? "allowed" : "blocked") " by " must_exist_branch);

    generate_missing_refs();

    for(ref in refs){
        state_to_action(ref);
    }
    actions_to_operations();
    operations_to_refspecs();
    refspecs_to_stream();
}
function state_to_action(current_ref,    remote_sha, track_sha, side, aside, is_victim){
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

    if(remote_sha[empty]){
        # As we here this means that remote repos don't know the current ref but gitSync knows it somehow.

        trace(current_ref " action-restore on both remotes; is unknown");
        # This actions supports independents of gitSync from its remoter repos.
        # I.e. you can replace remote repos all at once, as gitSync will be the source of truth.
        # But if you don't run gitSync for a while and have deleted a branch on both side repos manually then gitSync will recreate it.
        # Re-delete the branch again and use gitSync. Silly))
        a_restore[current_ref];

        return;
    }

    # ! All further actions assume that remote refs are not equal.

    is_victim = index(current_ref, prefix_victims) == 1;
    action_solve_key = is_victim ? "action-victim-solve" : "action-solve";

    if(track_sha[empty]){
        trace("!Warning!");
        trace("!! Something went wrong for " current_ref ". It is still untracked.");
        trace("!! Possibly the program or the network were interrupted.");
        trace("!! We will try to sync it during the second sync pass.");
        set_solve_action(is_victim, current_ref);

        return;
    }

    if(track_sha[equal]){
        for(side in sides){
            aside = asides[side];
            if(!remote_sha[side] && remote_sha[aside] == track_sha[common]){
                if(deletion_allowed){
                    trace(current_ref " action-del on " origin[aside] "; it is disappeared from " origin[side]);
                    a_del[aside][current_ref];
                }else{
                    trace(current_ref " " action_solve_key "-as-del-blocked on " origin[aside] "; is disappeared from " origin[side] " and deletion is blocked");
                    set_solve_action(is_victim, current_ref);
                }

                return;
            }
        }
    }

    if(ff_candidates_to_refspec(current_ref)){
        return;
    }

    trace(current_ref " " action_solve_key "-all-others; it has different track or/and remote branch commits");
    set_solve_action(is_victim, current_ref);
}
function set_solve_action(is_victim, ref){
    if(is_victim){
        a_victim_solve[ref];
    }else{
        a_solve[ref];
    }
}
function ff_candidates_to_refspec(ref,    ff_ref, is_ff, a_owner, b_owner, owner_side, not_owner_side, owner_sha, not_owner_sha, cmd, ff_result){
    for(ff_ref in ff_candidates){
        if(ff_ref == ref){
            is_ff = 1;
            break;
        }
    }
    if(!is_ff){
        return;
    }

    a_owner = index(ref, prefix[side_a]) == 1;
    b_owner = index(ref, prefix[side_b]) == 1;

    if(a_owner){
        owner_side = side_a;
    } else if(b_owner){
        owner_side = side_b;
    } else {
        return;
    }

    not_owner_side = asides[owner_side];

    # Ancestor is an update target. Owner must be an ancestor
    owner_sha = refs[ref][remote[owner_side]][sha_key];

    # descendant is (possibly) where to update.
    not_owner_sha = refs[ref][remote[not_owner_side]][sha_key];

    # --is-ancestor <ancestor> <descendant>
    cmd = "git merge-base --is-ancestor " refs[ref][track[owner_side]][ref_key] " " refs[ref][track[not_owner_side]][ref_key] " && echo ff";
    
    cmd | getline ff_result;
    close(cmd);

    if(ff_result != "ff"){
        trace(ref " blocked-fast-forward; from " origin[not_owner_side] " to " origin[owner_side] " as " owner_sha " isn't parent of " not_owner_sha " respectively");

        return;
    }
    
    trace(ref " action-fast-forward; from " origin[not_owner_side] " to " origin[owner_side] " as " owner_sha " is parent of " not_owner_sha " respectively");
    out_push[owner_side] = out_push[owner_side] " " refs[ref][track[not_owner_side]][ref_key] ":" refs[ref][remote[owner_side]][ref_key];

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
        aside = asides[side];
        for(ref in a_victim_solve){
            # Update non-existing remote refs.
            if(!refs[ref][remote[side]][sha_key] && refs[ref][remote[aside]][sha_key]){
                op_push_nff[side][ref];
                #op_post_fetch[side][ref];

                # Stop if non-existing remote refs will be updated.
                continue;
            }

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
            
            append_by_val(out_notify_del, prefix[side]  " | deletion | "  refs[ref][remote[side]][ref_key]  "   "  refs[ref][remote[side]][sha_key]);
        }
    }

    for(side in op_push_nff){
        aside = asides[side];
        for(ref in op_push_nff[side]){
            out_push[side] = out_push[side] "  +" refs[ref][track[aside]][ref_key] ":" refs[ref][remote[side]][ref_key];

            if(refs[ref][remote[side]][sha_key]){
                append_by_val(out_notify_solving, prefix[side]  " | conflict-solving | "  refs[ref][remote[side]][ref_key]  "   "  refs[ref][remote[side]][sha_key]);
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

function set_victim_refspec(    ref, sha_a, sha_b, git_rev_list_cmd, newest_sha){
    for(ref in op_victim_winner_search){
        # We expects that "no sha" cases will be processed by common NFF-solving actions.
        # But this approach with variables help to solve severe errors. Also it makes code more resilient.
        sha_a = refs[ref][remote[side_a]][sha_key] ? refs[ref][remote[side_a]][sha_key] : ("<no sha for " remote[side_a] ">");
        sha_b = refs[ref][remote[side_b]][sha_key] ? refs[ref][remote[side_b]][sha_key] : ("<no sha for " remote[side_b] ">");

        git_rev_list_cmd = "git rev-list " refs[ref][track[side_a]][ref_key] " " refs[ref][track[side_b]][ref_key] " --max-count=1"
        git_rev_list_cmd | getline newest_sha;
        close(git_rev_list_cmd);

        if(newest_sha == sha_a){
            d_trace("victim solving: " branch " on " origin_1 " beat " origin_2 " with " sha_a " vs " sha_b)
            out_push[side_b] = out_push[side_b] "  +" refs[ref][track[side_a]][ref_key] ":" refs[ref][remote[side_b]][ref_key];
        }
        if(newest_sha == sha_b){
            d_trace("victim solving: " branch " on " origin_2 " beat " origin_1 " with " sha_b " vs " sha_a)
            out_push[side_a] = out_push[side_a] "  +" refs[ref][track[side_b]][ref_key] ":" refs[ref][remote[side_a]][ref_key];
        }        
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


