@include "util.gawk"

BEGIN { # Constants.
    track_refs_prefix = "refs/remotes/";
    remote_refs_prefix = "refs/heads/";

    sha_key = "sha";
    ref_key = "ref";

    val = "val";
    common = "common";
    equal = "equal";
    empty = "empty";
}
BEGIN { # Globals.
    side_a = 1;
    side_b = 2;

    sides[side_a] = 1;
    sides[side_b] = 2;
    
    asides[side_a] = sides[side_b]
    asides[side_b] = sides[side_a]
}
BEGIN { # Parameters.
    initial_states_processing();
}
function initial_states_processing(    side, split_arr, ind, ref){
    must_exist_branch = ENVIRON["must_exist_branch"];
    if(!must_exist_branch)
        write("Deletion is blocked. Parameter must_exist_branch is empty");
        
    origin_a = ENVIRON["origin_1"];
    if(!origin_a){
        write("Error. Parameter origin_a is empty");
        exit 1002;
    }
    origin[side_a] = origin_a;
    origin_a = ""
    
    origin_b = ENVIRON["origin_2"];
    if(!origin_b){
        write("Error. Parameter origin_b is empty");
        exit 1003;
    }
    origin[side_b] = origin_b;
    origin_b = ""
    
    prefix_a = ENVIRON["prefix_1"];
    if(!prefix_a){
        write("Error. Parameter prefix_a is empty");
        exit 1004;
    }
    prefix[side_a] = prefix_a;
    prefix_a = ""
    
    prefix_b = ENVIRON["prefix_2"];
    if(!prefix_b){
        write("Error. Parameter prefix_b is empty");
        exit 1005;
    }
    prefix[side_b] = prefix_b;
    prefix_b = ""

    prefix_victims = ENVIRON["prefix_victims"];
    if(!prefix_victims){
        # Let's prevent emptiness checking all around as prefix_victims var allowed to be empty.
        prefix_victims = "{prefix_victims var is empty at the input. We use here some forbidden branch name characters to prevent messing with real branch names. .. .~^:}";
    }

    newline_substitution = ENVIRON["env_awk_newline_substitution"];
    if(!newline_substitution){
        write("Error. Parameter newline_substitution is empty");
        exit 1006;
    }

    for(side in sides){
        track[side] = "track@" prefix[side];
        remote[side] = "remote@" prefix[side];
    }
    
    split(ENVIRON["ff_candidates"], split_arr, "\n");
    for(ind in split_arr){
        ref = split_arr[ind];
        if(!ref){
            continue;
        }
        d_trace("ref is " ref);
        ff_candidates[side][ref];
    }
}
BEGINFILE { # Preparing processing for every portion of refs.
    file_states_processing();
}
function file_states_processing() {
    dest = "";
    ref_prefix = "";
    switch (++file_num) {
        case 1:
            dest = remote[side_a];
            ref_prefix = remote_refs_prefix;
            break;
        case 2:
            dest = remote[side_b];
            ref_prefix = remote_refs_prefix;
            break;
        case 3:
            dest = track[side_a];
            ref_prefix = track_refs_prefix origin[side_a] "/";
            break;
        case 4:
            dest = track[side_b];
            ref_prefix = track_refs_prefix origin[side_b] "/";
            break;
    }
}
{ # Ref states preparation.
    if(!$2){
        # Empty input stream of an empty refs' var.
        next;
    }
        
    prefix_name_key();

    if(index($3, prefix[side_a]) != 1 \
        && index($3, prefix[side_b]) != 1 \
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


