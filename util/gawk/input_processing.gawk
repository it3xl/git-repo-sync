@include util.gawk

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

    split("", origin);
    split("", prefix);
    split("", track);
    split("", remote);
}
BEGIN { # Parameters.
    write_after_line("> refs processing");
    #trace("Tracing is ON");

    initial_states_processing();
}
function initial_states_processing(    side){
    if(!must_exist_branch)
        write("Deletion is blocked. Parameter must_exist_branch is empty");
        
    if(!origin_a){
        write("Error. Parameter origin_a is empty");
        exit 1002;
    }
    origin[side_a] = origin_a;
    origin_a = ""
    
    if(!origin_b){
        write("Error. Parameter origin_b is empty");
        exit 1003;
    }
    origin[side_b] = origin_b;
    origin_b = ""
    
    if(!prefix_a){
        write("Error. Parameter prefix_a is empty");
        exit 1004;
    }
    prefix[side_a] = prefix_a;
    prefix_a = ""
    
    if(!prefix_b){
        write("Error. Parameter prefix_b is empty");
        exit 1005;
    }
    prefix[side_b] = prefix_b;
    prefix_b = ""

    if(!prefix_victims){
        # Let's prevent emptiness checking all around as prefix_victims var allowed to be empty.
        prefix_victims = "{prefix_victims var is empty at the input. We use here some forbidden branch name characters to prevent messing with real branch names. .. .~^:}";
    }

    if(!newline_substitution){
        write("Error. Parameter newline_substitution is empty");
        exit 1006;
    }

    for(side in sides){
        track[side] = "track@" prefix[side];
        remote[side] = "remote@" prefix[side];
    }
}
BEGINFILE { # Preparing processing for every portion of refs.
    file_states_processing();
}
function file_states_processing() {
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







