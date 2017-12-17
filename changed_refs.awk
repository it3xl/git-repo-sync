#deletion_allowed

BEGIN {
  debugger_on = 1;

  prefRemote = "refs/remotes/";
  prefLocal = "refs/heads/";

  tty_attached = "/dev/tty";

  tty_header("AWK started");
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
  remove_unchanged(refs);

  fetch[1] = fetch_refspec(refs, remote_1, local_1);
  fetch[2] = fetch_refspec(refs, remote_2, local_2);

  push[1] = push_refspec(refs, remote_1, local_1);
  push[2] = push_refspec(refs, remote_2, local_2);
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
  # Generates a common key for different locations of a ref.
  $3 = $2
  split($3, split_refs, prefRemote origin "/");
  if(split_refs[2]){
    # Removes "refs/remotes/current origin/"
    $3 = split_refs[2];
  }else{
    # Removes "refs/heads/"
    sub("refs/[^/]*/", "", $3);
  }
}
function remove_unchanged(refs) {
  for(key in refs){
    sha_1 = refs[key][remote_1]["sha"];
    sha_2 = refs[key][remote_2]["sha"];
    if(sha_1 && sha_1 == sha_2)
    {
      delete refs[key];

      continue;
    }
    tty("\t" key);
    tty(sha_1 "\t" remote_1);
    tty(sha_2 "\t" remote_2);
  }
}
function fetch_refspec(refs, remote, local,    refspec) {
  for(key in refs){
    sha = refs[key][remote]["sha"];
    if(!sha || sha != refs[key][local]["sha"])
    {
      refspec = refspec " +'" refs[key][remote]["ref"] "':'" refs[key][local]["ref"] "'";
    }
  }

  tty_dbg("\tfetch " remote);
  tty_dbg(refspec)

  return refspec;
}
function push_refspec(refs) {
  for(key in refs){
    sha = refs[key][remote]["sha"];
    if(!sha || sha != refs[key][local]["sha"])
    {
      refspec = refspec " +" refs[key][remote]["ref"] ":" refs[key][local]["ref"];
    }
  }









}


function tty(msg){
  print msg >> tty_attached;
}
function tty_header(msg){
  tty("\n" msg "\n");
}
function tty_dbg(msg){
  if(!debugger_on)
    return;

  print msg >> tty_attached;
}


END{
  close(tty_attached);
}
