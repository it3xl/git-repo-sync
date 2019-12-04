
BEGIN { # Constants.
    out_push_spec1;
    out_push_spec2;
}
{
    git_rev_list_cmd = $0;

    getline;
    sha1=$1;
    sha2=$2;

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
        out_push_spec2 = out_push_spec2 push_spec2;
    }
    if(newest_sha == sha1){
        out_push_spec1 = out_push_spec1 push_spec1;
    }
}
END{
    print "{[results-spec: 0-results-spec; 1-out_push_spec1; 2-out_push_spec2; 3-end-of-results;]}"
    
    print out_push_spec1;
    print out_push_spec2;

    # Must print finishing line otherwise previous empty lines will be ignored by mapfile command in bash.
    print "{[end-of-results]}"
}