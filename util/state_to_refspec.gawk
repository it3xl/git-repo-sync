
BEGIN { # Constants.
  local_refs_prefix = "refs/remotes/";
  remote_refs_prefix = "refs/heads/";

  sha_key = "sha"
  ref_key = "ref"
  
  out_stream_attached = "/dev/stderr";
}
BEGIN { # Parameters.
  write_after_line("> States To Refspecs started");
  trace("Tracing is ON");

  if(!must_exist_branch)
    write("Deletion is blocked. Parameter must_exist_branch is empty");
    
  if(!origin_1){
    write("Error. Parameter origin_1 is empty");
    exit 1002;
  }
  if(!origin_2){
    write("Error. Parameter origin_2 is empty");
    exit 1003;
  }
  if(!prefix_1){
    write("Error. Parameter prefix_1 is empty");
    exit 1004;
  }
  if(!prefix_2){
    write("Error. Parameter prefix_2 is empty");
    exit 1005;
  }

  if(!prefix_victims){
    # Let's prevent emptiness checking all around as prefix_victims var allowed to be empty.
    prefix_victims = "{prefix_victims var is empty at the input. We use here some forbidden branch name characters to prevent messing with real branch names. .. .~^:}";
  }

  if(!newline_substitution){
    write("Error. Parameter newline_substitution is empty");
    exit 1006;
  }

  local_1 = "local@" prefix_1;
  local_2 = "local@" prefix_2;
  remote_1 = "remote@" prefix_1;
  remote_2 = "remote@" prefix_2;
}
BEGINFILE { # Preparing processing for every portion of refs.
  file_states();
}
function file_states() {
  switch (++file_num) {
    case 1:
      dest = remote_1;
      ref_prefix = remote_refs_prefix;
      break;
    case 2:
      dest = remote_2;
      ref_prefix = remote_refs_prefix;
      break;
    case 3:
      dest = local_1;
      ref_prefix = local_refs_prefix origin_1 "/";
      break;
    case 4:
      dest = local_2;
      ref_prefix = local_refs_prefix origin_2 "/";
      break;
  }
}
{ # Ref states preparation.
  if(!$2){
    # Empty input stream of an empty refs' var.
    next;
  }
    
  prefix_name_key();

  if(index($3, prefix_1) != 1 \
    && index($3, prefix_2) != 1 \
    && index($3, prefix_victims) != 1 \
    ){
    trace("!unexpected " $2 " (" dest ") " $1 "; branch name (" $3 ") has no allowed prefixes");

    next;
  }
  
  refs[$3][dest][sha_key] = $1;
  refs[$3][dest][ref_key] = $2;
}
function prefix_name_key() { # Generates a common key for all 4 locations of every ref.
  $3 = $2
  split($3, split_refs, ref_prefix);
  $3 = split_refs[2];
}
END { # Processing.
  dest = ""; ref_prefix = "";

  deletion_allowed = 0;
  unlock_deletion( \
    refs[must_exist_branch][remote_1][sha_key], \
    refs[must_exist_branch][remote_2][sha_key], \
    refs[must_exist_branch][local_1][sha_key], \
    refs[must_exist_branch][local_2][sha_key] \
  );
  write("Deletion " ((deletion_allowed) ? "allowed" : "blocked") " by " must_exist_branch);

  generate_missing_refs();
  declare_processing_globs();

  for(currentRef in refs){
    state_to_action( \
      currentRef, \
      refs[currentRef][remote_1][sha_key], \
      refs[currentRef][remote_2][sha_key], \
      refs[currentRef][local_1][sha_key], \
      refs[currentRef][local_2][sha_key] \
    );
  }
  actions_to_operations();
  operations_to_refspecs();
  refspecs_to_stream();
}

function unlock_deletion(rr1, rr2, lr1, lr2){
  if(!rr1)
    return;
  if(!lr1)
    return;
    
  if(rr1 != rr2)
    return;
  if(lr1 != lr2)
    return;
  if(rr1 != lr2)
    return;
  
  deletion_allowed = 1;
}
function generate_missing_refs(){
  for(ref in refs){
    if(!refs[ref][remote_1][ref_key])
      refs[ref][remote_1][ref_key] = remote_refs_prefix ref
    if(!refs[ref][remote_2][ref_key])
      refs[ref][remote_2][ref_key] = remote_refs_prefix ref
    if(!refs[ref][local_1][ref_key])
      refs[ref][local_1][ref_key] = local_refs_prefix origin_1 "/" ref
    if(!refs[ref][local_2][ref_key])
      refs[ref][local_2][ref_key] = local_refs_prefix origin_2 "/" ref
  }
}
function declare_processing_globs(){
  # Action array variables.
  split("", a_restore);
  split("", a_fetch1); split("", a_fetch2);
  split("", a_del1); split("", a_del2);
  split("", a_ff_to1); split("", a_ff_to2);
  split("", a_solve);
  split("", a_victim_solve);
  # Operation array variables.
  split("", op_del_local);
  split("", op_fetch1); split("", op_fetch2);
  split("", op_push_restore1); split("", op_push_restore2);
  split("", op_push_del1); split("", op_push_del2);
  split("", op_push_ff_to1); split("", op_push_ff_to2);
  split("", op_push_nff_to1); split("", op_push_nff_to2);
  split("", op_fetch_post1); split("", op_fetch_post2);
  split("", op_victim_winner_search);
  # Output Git refspec variables.
  out_del;
  out_fetch1; out_fetch2;
  out_push1; out_push2;
  out_post_fetch1; out_post_fetch2;
  out_victim_data;
  out_notify_del;
  out_notify_solving;
}
function state_to_action(cr, rr1, rr2, lr1, lr2,    rrEqual, lrEqual, rr, lr, is_victim, action_solve_key){
  rrEqual = rr1 == rr2;
  lrEqual = lr1 == lr2;
  
  if(rrEqual && lrEqual && lr1 == rr2){
    # Nothing to change for the current branch.

    return;
  }

  rr = rrEqual ? rr1 : "# remote refs are not equal #";

  if(rrEqual && !rr){
    # As we here this means that remote repos don't know the branch but gitSync knows it somehow.
    # This behavior supports independents of gitSync from its remoter repos. I.e. you can replace them at once, as gitSync will be the source of truth.
    # But if you don't run gitSync for a while and have deleted the branch on both side repos manually then gitSync will recreate it.
    # Re-delete the branch and use gitSync. Silly))

    trace("action-restore on both remotes; " cr " in unknown");
    a_restore[cr];

    return;
  }

  if(rrEqual){
    if(rr != lr1){
      # Possibly gitSync or the network was interrupted.
      trace("action-fetch from " origin_1 "; " cr " is " ((lr1) ? "outdated" : "unknown") " locally");
      a_fetch1[cr];
    }
    if(rr != lr2){
      # Possibly gitSync or the network was interrupted.
      trace("action-fetch from " origin_2 "; " cr " is " ((lr2) ? "outdated" : "unknown") " locally");
      a_fetch2[cr];
    }

    return;
  }

  # ! All further actions suppose that remote refs are not equal.

  lr = lrEqual ? lr1 : "# local refs are not equal #";

  is_victim = index(cr, prefix_victims) == 1;
  action_solve_key = is_victim ? "action-victim-solve" : "action-solve";

  if(lrEqual && !lr){
    trace(action_solve_key " on both remotes; " cr " is unknown locally");
    set_solve_action(is_victim, cr);

    return;
  }

  if(lrEqual){
    if(!rr1 && rr2 == lr){
      if(deletion_allowed){
        trace("action-del on " origin_2 "; " cr " is disappeared from " origin_1);
        a_del2[cr];
      }else{
        trace(action_solve_key "-as-del-blocked on " origin_2 "; " cr " is disappeared from " origin_1 " and deletion is blocked");
        set_solve_action(is_victim, cr);
      }

      return;
    }
    if(!rr2 && rr1 == lr){
      if(deletion_allowed){
        trace("action-del on " origin_1 "; " cr " is disappeared from " origin_2);
        a_del1[cr];
      }else{
        trace(action_solve_key "-as-del-blocked on " origin_1 "; " cr " is disappeared from " origin_2 " and deletion is blocked");
        set_solve_action(is_victim, cr);
      }

      return;
    }
  }

  if(lrEqual){
    if(rr1 == lr && rr2 != lr){
      trace("action-fast-forward on " origin_1 "; " cr " is outdated there");
      a_ff_to1[cr];

      return;
    }
    if(rr2 == lr && rr1 != lr){
      trace("action-fast-forward on " origin_2 "; " cr " is outdated there");
      a_ff_to2[cr];

      return;
    }
  }

  trace(action_solve_key "-all-others; " cr " is different locally or/and remotely");
  set_solve_action(is_victim, cr);
}
function set_solve_action(is_victim, ref){
  if(is_victim){
    a_victim_solve[ref]
  }else{
    a_solve[ref]
  }
}
function actions_to_operations(    ref, owns_side1, owns_side2, victims_push_requested){
  for(ref in a_restore){
    if(refs[ref][local_1][sha_key]){
      op_push_restore1[ref];
      op_fetch_post1[ref];
    }
    if(refs[ref][local_2][sha_key]){
      op_push_restore2[ref];
      op_fetch_post2[ref];
    }
  }

  for(ref in a_fetch1){
    op_fetch1[ref];
  }
  for(ref in a_fetch2){
    op_fetch2[ref];
  }

  for(ref in a_del1){
    op_del_local[ref];
    op_push_del1[ref];
  }
  for(ref in a_del2){
    op_del_local[ref];
    op_push_del2[ref];
  }

  for(ref in a_ff_to1){
    op_fetch2[ref];
    op_push_ff_to1[ref];
    op_fetch_post1[ref];
  }
  for(ref in a_ff_to2){
    op_fetch1[ref];
    op_push_ff_to2[ref];
    op_fetch_post2[ref];
  }

  for(ref in a_victim_solve){

    # Update outdated or missing local refs for existing remote refs.
    if(refs[ref][remote_1][sha_key]){
        if(refs[ref][remote_1][sha_key] != refs[ref][local_1][sha_key]){
          op_fetch1[ref];
        }
    }
    if(refs[ref][remote_2][sha_key]){
      if(refs[ref][remote_2][sha_key] != refs[ref][local_2][sha_key]){
        op_fetch2[ref];
      }
    }

    # Update non-existing remote refs.
    if(!refs[ref][remote_1][sha_key] && refs[ref][remote_2][sha_key]){
      victims_push_requested = 1;
      op_push_ff_to1[ref];
      #op_fetch_post1[ref];
    }
    if(!refs[ref][remote_2][sha_key] && refs[ref][remote_1][sha_key]){
      victims_push_requested = 1;
      op_push_ff_to2[ref];
      #op_fetch_post2[ref];
    }

    # Stop if non-existing remote refs will be updated.
    if(victims_push_requested){
      victims_push_requested = 0;
      continue;
    }

    op_victim_winner_search[ref];
  }

  for(ref in a_solve){
    owns_side1 = index(ref, prefix_1) == 1;
    owns_side2 = index(ref, prefix_2) == 1;

    if(!owns_side1 && !owns_side2){
      trace("operation-solve; Ignoring " ref " as it has no allowed prefixes " prefix_1 " or " prefix_2)
      continue;
    }

    if(owns_side1){
      if(refs[ref][remote_1][sha_key]){
        if(refs[ref][remote_1][sha_key] != refs[ref][local_1][sha_key]){
          op_fetch1[ref];
        }
        op_push_nff_to2[ref];
        op_fetch_post2[ref];
      } else if(refs[ref][remote_2][sha_key]){
        if(refs[ref][remote_2][sha_key] != refs[ref][local_2][sha_key]){
          op_fetch2[ref];
        }
        op_push_nff_to1[ref];
        op_fetch_post1[ref];
      }
    }
    if(owns_side2){
      if(refs[ref][remote_2][sha_key]){
        if(refs[ref][remote_2][sha_key] != refs[ref][local_2][sha_key]){
          op_fetch2[ref];
        }
        op_push_nff_to1[ref];
        op_fetch_post1[ref];
      } else if(refs[ref][remote_1][sha_key]){
        if(refs[ref][remote_1][sha_key] != refs[ref][local_1][sha_key]){
          op_fetch1[ref];
        }
        op_push_nff_to2[ref];
        op_fetch_post2[ref];
      }
    }
  }
}
function operations_to_refspecs(    ref, delimiter){
  { # op_del_local
    for(ref in op_del_local){
      if(refs[ref][local_1][sha_key]){
        out_del = out_del "  " origin_1 "/" ref;
      }
      if(refs[ref][local_2][sha_key]){
        out_del = out_del "  " origin_2 "/" ref;
      }
    }
  }
  { # op_fetch1, op_fetch2
    for(ref in op_fetch1){
      out_fetch1 = out_fetch1 "  +" refs[ref][remote_1][ref_key] ":" refs[ref][local_1][ref_key];
    }
    for(ref in op_fetch2){
      out_fetch2 = out_fetch2 "  +" refs[ref][remote_2][ref_key] ":" refs[ref][local_2][ref_key];
    }
  }

  { # op_push_restore1, op_push_restore2
    for(ref in op_push_restore1){
      out_push1 = out_push1 "  " refs[ref][local_1][ref_key] ":" refs[ref][remote_1][ref_key];
    }
    for(ref in op_push_restore2){
      out_push2 = out_push2 "  " refs[ref][local_2][ref_key] ":" refs[ref][remote_2][ref_key];
    }
  }
  { # op_push_del1, op_push_del2
    for(ref in op_push_del1){
      out_push1 = out_push1 "  :" refs[ref][remote_1][ref_key];
    }
    for(ref in op_push_del2){
      out_push2 = out_push2 "  :" refs[ref][remote_2][ref_key];
    }
    
    for(ref in op_push_del1){
      delimiter = out_notify_del ? newline_substitution : "";
      out_notify_del = out_notify_del delimiter prefix_1  " | deletion | "  refs[ref][remote_1][ref_key]  "   "  refs[ref][remote_1][sha_key];
    }
    for(ref in op_push_del2){
      delimiter = out_notify_del ? newline_substitution : "";
      out_notify_del = out_notify_del delimiter prefix_2  " | deletion | "  refs[ref][remote_2][ref_key]  "   "  refs[ref][remote_2][sha_key];
    }
  }
  { # op_push_ff_to1, op_push_ff_to2
    for(ref in op_push_ff_to1){
      out_push1 = out_push1 "  " refs[ref][local_2][ref_key] ":" refs[ref][remote_1][ref_key];
    }
    for(ref in op_push_ff_to2){
      out_push2 = out_push2 "  " refs[ref][local_1][ref_key] ":" refs[ref][remote_2][ref_key];
    }
  }
  { # op_push_nff_to1, op_push_nff_to2
    for(ref in op_push_nff_to1){
      out_push1 = out_push1 "  +" refs[ref][local_2][ref_key] ":" refs[ref][remote_1][ref_key];
    }
    for(ref in op_push_nff_to2){
      out_push2 = out_push2 "  +" refs[ref][local_1][ref_key] ":" refs[ref][remote_2][ref_key];
    }

    for(ref in op_push_nff_to1){
      if(refs[ref][remote_1][sha_key]){
        delimiter = out_notify_solving ? newline_substitution : "";
        out_notify_solving = out_notify_solving delimiter prefix_1  " | conflict-solving | "  refs[ref][remote_1][ref_key]  "   "  refs[ref][remote_1][sha_key];
      }
    }
    for(ref in op_push_nff_to2){
      if(refs[ref][remote_2][sha_key]){
        delimiter = out_notify_solving ? newline_substitution : "";
        out_notify_solving = out_notify_solving delimiter prefix_2  " | conflict-solving | "  refs[ref][remote_2][ref_key]  "   "  refs[ref][remote_2][sha_key];
      }
    }
  }
  { # op_victim_winner_search
    for(ref in op_victim_winner_search){
      delimiter = out_victim_data ? newline_substitution : "";
      out_victim_data = out_victim_data delimiter "git rev-list " refs[ref][local_1][ref_key] " " refs[ref][local_2][ref_key] " --max-count=1";
      delimiter = newline_substitution;
      out_victim_data = out_victim_data delimiter refs[ref][remote_1][sha_key] " " refs[ref][local_2][sha_key];
      out_victim_data = out_victim_data delimiter "  +" refs[ref][local_1][ref_key] ":" refs[ref][remote_2][ref_key];
      out_victim_data = out_victim_data delimiter "  +" refs[ref][local_2][ref_key] ":" refs[ref][remote_1][ref_key];
    }
  }

  { # op_fetch_post1, op_fetch_post2
    for(ref in op_fetch_post1){
      out_post_fetch1 = out_post_fetch1 "  +" refs[ref][remote_1][ref_key] ":" refs[ref][local_1][ref_key];
    }
    for(ref in op_fetch_post2){
      out_post_fetch2 = out_post_fetch2 "  +" refs[ref][remote_2][ref_key] ":" refs[ref][local_2][ref_key];
    }
  }
}
function refspecs_to_stream(){
  # 0
  print "{[results-spec: 0-results-spec; 1-del local; 2,3-fetch; 4,5-push; 6,7-post fetch; 8-rev-list; 9-notify-del; 10-notify-solving; 11-end-of-results;]}"
  # 1
  print out_del;
  # 2
  print out_fetch1;
  # 3
  print out_fetch2;
  # 4
  print out_push1;
  # 5
  print out_push2;
  # 6
  print out_post_fetch1;
  # 7
  print out_post_fetch2;
  # 8
  print out_victim_data;
  # 9
  print out_notify_del;
  # 10
  print out_notify_solving;

  # 11
  # Must print finishing line otherwise previous empty lines will be ignored by mapfile command in bash.
  print "{[end-of-results]}"
}


function write(msg){
  print msg >> out_stream_attached;
}
function write_after_line(msg){
  write("\n" msg);
}
function trace(msg){
  if(!trace_on)
    return;

  if(!msg){
    print "|" >> out_stream_attached;
    return;
  }

  print "|" msg >> out_stream_attached;
}
function trace_header(msg){
  trace();
  trace(msg);
  trace();
}
function trace_after_line(msg){
  trace();
  trace(msg);
}
function trace_line(msg){
  trace(msg);
  trace();
}
function devtrace(msg){
  if(0)
    return;

  trace("|" msg)
}

END{ # Disposing.
  write("> States To Refspecs end");

  # Possibly the close here is excessive.
  #https://www.gnu.org/software/gawk/manual/html_node/Close-Files-And-Pipes.html#Close-Files-And-Pipes
  close(out_stream_attached);
}
