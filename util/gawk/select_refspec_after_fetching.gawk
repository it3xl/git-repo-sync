
@include base.gawk

BEGIN{
    write_after_line("> refs rechecking");
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

    switch (algorithm) {
      case "ff-vs-nff":
        ff_vs_nff_processing();
        break;
      case "victim":
        victim_processing();
        break;
      default:
        trace("We do not expect to have unknown algorithms here.");
        exit 1301;
    }
}

function ff_vs_nff_processing(){
    branch = $2;
    ancestor_updated_sha = $3;
    descendant_sha = $4;

    getline git_merge_base__is_ancestor_cmd;
    getline push_ff_spec;

    git_merge_base__is_ancestor_cmd | getline result_action;
    close(git_merge_base__is_ancestor_cmd);

}
function victim_processing(    branch, sha1, sha2){
    branch = $2;
    sha1 = $3;
    sha2 = $4;

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


END{
    print "{[results-spec: 0-results-spec; 1-out_push_spec1; 2-out_push_spec2; 3-end-of-results-required-mark;]}"
    
    print out_push_spec1;
    print out_push_spec2;

    # Must print finishing line otherwise previous empty lines will be ignored by mapfile command in bash.
    print "{[end-of-results]}"
}
