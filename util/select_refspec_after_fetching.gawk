
BEGIN { # Constants.
  out_stream_attached = "/dev/stderr";
}
BEGIN{
  write_after_line("> victim refs processing");
  #trace("Tracing is ON");

  if(!origin_1){
    write("Error. Parameter origin_1 is empty");
    exit 1102;
  }
  if(!origin_2){
    write("Error. Parameter origin_2 is empty");
    exit 1103;
  }
}
{
    if(!$0){
        next;
    }

    algorithm = $1;

    branch=$2;
    sha1=$3;
    sha2=$4;
    
    getline git_rev_list_cmd;
    getline push_spec2;
    getline push_spec1;

    git_rev_list_cmd | getline newest_sha;
    close(git_rev_list_cmd);

    #print "newest_sha is: " newest_sha;
    #print "git_rev_list_cmd is: " git_rev_list_cmd;
    #print "sha1 is: " sha1;
    #print "sha2 is: " sha2;
    #print "push_spec1 is: " push_spec1;
    #print "push_spec2 is: " push_spec2;


    if(newest_sha == sha1){
        trace(branch ": " origin_1 " beat " origin_2 " with " sha1 " vs " sha2)
        out_push_spec2 = out_push_spec2 push_spec2;
    }
    if(newest_sha == sha2){
        trace(branch ": " origin_2 " beat " origin_1 " with " sha2 " vs " sha1)
        out_push_spec1 = out_push_spec1 push_spec1;
    }
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
function dTrace(msg){
  if(0)
    return;

  trace("|" msg)
}

END{
    print "{[results-spec: 0-results-spec; 1-out_push_spec1; 2-out_push_spec2; 3-end-of-results-required-mark;]}"
    
    print out_push_spec1;
    print out_push_spec2;

    # Must print finishing line otherwise previous empty lines will be ignored by mapfile command in bash.
    print "{[end-of-results]}"
}
END{ # Disposing.
  write("> victim refs processing end");

  # Possibly the close here is excessive.
  #https://www.gnu.org/software/gawk/manual/html_node/Close-Files-And-Pipes.html#Close-Files-And-Pipes
  close(out_stream_attached);
}
