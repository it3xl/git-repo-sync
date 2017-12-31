BEGIN {
  prefRemote = "refs/remotes/";
  prefLocal = "refs/heads/";

  tty_attached = "/dev/tty";

  tty_dbg("AWK debugging is ON");
}
BEGINFILE {
  file_states();
}
$2 {
  common_key();

  refs[$3][dest]["sha"] = $1;
  refs[$3][dest]["ref"] = $2;
}
END {
  dest = "";
  origin = "";
}
END {
  #ff1;
  #ff2;
  #del1;
  #del2;
  #fetch1;
  #fetch2;
  #solv; - the owner repo can lose a ref. Behaves as a restoring.
  
  deletion_allowed = 0;
  unlock_deletion( \
    refs[must_exist_branch][remote_1]["sha"], \
    refs[must_exist_branch][remote_2]["sha"], \
    refs[must_exist_branch][local_1]["sha"], \
    refs[must_exist_branch][local_2]["sha"] \
  );
  tty_dbg("deletion allowed = " deletion_allowed " by " must_exist_branch);
  for(currentRef in refs){
    assign_action( \
      currentRef, \
      refs[currentRef][remote_1]["sha"], \
      refs[currentRef][remote_2]["sha"], \
      refs[currentRef][local_1]["sha"], \
      refs[currentRef][local_2]["sha"] \
    );
  }
}
function assign_action(cr, rr1, rr2, lr1, lr2,    lr, rr){
  if(rr1 == rr2 && lr1 == lr2 && lr1 == rr2){
    # Nothing to change.
    return;
  }
  if(!(rr1 rr2)){
    tty_dbg("solv, no remote refs: " cr);
    solv[cr];
    return;
  }
  if(!(lr1 lr2)){
    tty_dbg("solv, no local: " cr);
    solve[cr];
    return;
  }
  if(lr1 == lr2){
    lr = lr1;
    
    if(rr2 == lr && !rr1){
      tty_dbg("del2: " cr);
      del2[cr];
      return;
    }
    if(rr1 == lr && !rr2){
      tty_dbg("del1: " cr);
      del1[cr];
      return;
    }
    if(rr1 == lr && rr2 != lr){
      tty_dbg("ff1: " cr);
      ff1[cr];
      return;
    }
    if(rr2 == lr && rr1 != lr){
      tty_dbg("ff2: " cr);
      ff2[cr];
      return;
    }
  }
  if(rr1 == rr2){
    rr = rr1;
    
    if(lr1 != rr){
      tty_dbg("fetch1, net fail: " cr);
      fetch1[cr];
    }
    if(lr2 != rr){
      tty_dbg("fetch2, net fail: " cr);
      fetch2[cr];
    }
    return;
  }
  solv[cr];
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
function file_states() {
  switch (++file_num) {
    case 1:
      dest = remote_1;
      break;
    case 2:
      dest = remote_2;
      break;
    case 3:
      dest = local_1;
      origin = remote_1;
      break;
    case 4:
      dest = local_2;
      origin = remote_2;
      break;
  }
}
function common_key() {
  # Generates a common key for all 4 locations of every ref.
  $3 = $2
  split($3, split_refs, prefRemote origin "/");
  if(split_refs[2]){
    # Removes "refs/remotes/current_origin/"
    $3 = split_refs[2];
  }else{
    # Removes "refs/heads/"
    sub("refs/[^/]*/", "", $3);
  }
}


function tty(msg){
  print msg >> tty_attached;
}
function tty_header(msg){
  tty("\n" msg "\n");
}
function tty_dbg(msg){
  if(!debug_on)
    return;

  #print "Œ " msg >> tty_attached;
  print "Œ " msg " Ð" >> tty_attached;
}

END{
  close(tty_attached);
}
