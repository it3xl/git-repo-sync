@include "util.gawk"
@include "git_const.gawk"

BEGIN { # Constants.
    val = "val";
    common = "common";
    equal = "equal";
    empty = "empty";
    empty_any = "empty_any";
}
BEGIN { # Parameters.
    initial_states_processing();
}
function initial_states_processing(    side, split_arr, split_val, ind, ref, val, sha){
    must_exist_branch = ENVIRON["must_exist_branch"];
    if(!must_exist_branch)
        write("Deletion is blocked as the must_exist_branch variable is empty");
        
    origin_a = ENVIRON["origin_a"];
    if(!origin_a){
        write("Error. Parameter origin_a is empty");
        exit 82;
    }
    origin[side_a] = origin_a;
    origin_a = ""
    
    origin_b = ENVIRON["origin_b"];
    if(!origin_b){
        write("Error. Parameter origin_b is empty");
        exit 83;
    }
    origin[side_b] = origin_b;
    origin_b = ""
    
    pref_a_conv = ENVIRON["pref_a_conv"];
    if(!pref_a_conv){
        d_trace("The conventional B prefix isn't defined. Conventional branches sync functionality is disabled.")
        # Let's prevent emptiness checking all around as pref_victim var allowed to be empty.
        pref_a_conv = "{pref_a_conv var is empty at the input. We use here some forbidden branch name characters to prevent messing with real branch names. .. .~^:}";
    }
    prefix[side_a] = pref_a_conv;
    pref_a_conv = ""
    
    pref_b_conv = ENVIRON["pref_b_conv"];
    if(!pref_b_conv){
        d_trace("The conventional B prefix isn't defined. Conventional branches sync functionality is disabled.")
        # Let's prevent emptiness checking all around as pref_victim var allowed to be empty.
        pref_b_conv = "{pref_b_conv var is empty at the input. We use here some forbidden branch name characters to prevent messing with real branch names. .. .~^:}";
    }
    prefix[side_b] = pref_b_conv;
    pref_b_conv = ""

    pref_victim = ENVIRON["pref_victim"];
    if(!pref_victim){
        d_trace("The victim prefix isn't defined. Victim branches sync functionality is disabled.")
        # Let's prevent emptiness checking all around as pref_victim var allowed to be empty.
        pref_victim = "{pref_victim var is empty at the input. We use here some forbidden branch name characters to prevent messing with real branch names. .. .~^:}";
    }

    newline_substitution = ENVIRON["env_awk_newline_substitution"];
    if(!newline_substitution){
        write("Error. Parameter newline_substitution is empty");
        exit 86;
    }

    for(side in sides){
        track[side] = "track@" prefix[side];
        remote[side] = "remote@" prefix[side];
    }
    
    split(ENVIRON["conv_move"], split_arr, "\n");
    for(ind in split_arr){
        val = split_arr[ind];

        split(val, split_val, " ");

        ref = split_val[1];
        sha = split_val[2];
        if(!ref || !sha){
            continue;
        }
        
        conv_move[ref][sha];
    }
    
    split(ENVIRON["victim_move"], split_arr, "\n");
    for(ind in split_arr){
        val = split_arr[ind];

        split(val, split_val, " ");

        ref = split_val[1];
        sha = split_val[2];
        if(!ref || !sha){
            continue;
        }

        victim_move[ref][sha];
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
        && index($3, pref_victim) != 1 \
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
END {
    process_restore_side_state();
}

