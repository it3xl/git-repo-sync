# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync

@include "global.gawk"


BEGIN { # Constants.
    val = "val";
    common = "common";
    equal = "equal";
    empty_both = "empty_both";
    empty_any = "empty_any";
}
BEGIN { # Parameters.
    initial_states_processing();
}
function initial_states_processing(    side, split_arr, split_val, ind, ref, val, sha){
    sync_enabling_branch = ENVIRON["sync_enabling_branch"];
    if(!sync_enabling_branch){
        write("Synchronization is blocked as the sync_enabling_branch variable is empty");
        exit 81;
    }
        
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
    prefix[side_a] = pref_a_conv;
    pref_a_conv = ""
    
    pref_b_conv = ENVIRON["pref_b_conv"];
    prefix[side_b] = pref_b_conv;
    pref_b_conv = ""

    pref_victim = ENVIRON["pref_victim"];

    newline_substitution = ENVIRON["env_awk_newline_substitution"];
    if(!newline_substitution){
        write("Error. Parameter newline_substitution is empty");
        exit 86;
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
    current_dest = "";
    current_side = "";
    ref_prefix = "";
    switch (++file_num) {
        case 1:
            current_dest = remote;
            current_side = side_a;
            ref_prefix = remote_refs_path;
            break;
        case 2:
            current_dest = remote;
            current_side = side_b;
            ref_prefix = remote_refs_path;
            break;
        case 3:
            current_dest = track;
            current_side = side_a;
            ref_prefix = track_refs_path origin[side_a] "/";
            break;
        case 4:
            current_dest = track;
            current_side = side_b;
            ref_prefix = track_refs_path origin[side_b] "/";
            break;
    }
}
{ # Ref states preparation.
    if(!$2){
        # Empty input stream of an empty refs' variable or an empty line.
        next;
    }
    
    prepare_ref_states();
}
function prepare_ref_states(    ref){
    prefix_name_key();

    ref = $3;
    if( !sync_all_refs() \
        && ref != sync_enabling_branch \
        && !explicit_victim_ref(ref) \
        && !side_a_conv_ref(ref) \
        && !side_b_conv_ref(ref) \
        ){
        trace("!unexpected " $2 " in " current_dest " " $1 "; branch name (" ref ") has no allowed prefixes or not allowed");

        next;
    }
    
    refs[ref][current_side][current_dest][sha_key] = $1;
    refs[ref][current_side][current_dest][ref_key] = $2;
}
function prefix_name_key() { # Generates a common key for all 4 locations of every ref.
    $3 = $2
    split($3, split_refs, ref_prefix);
    $3 = split_refs[2];
}
END {
    process_emptiness();
}
