# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync

BEGIN { # Constants.
    out_stream_attached = "/dev/stderr";
}
BEGIN {
    awk_trace_on = !! ENVIRON["env_awk_trace_on"];
}

function process_emptiness(    not_empty_remote, remote_sha, not_empty_track, track_sha){
    for (side in sides) {
        for (ref in refs) {
            remote_sha = refs[ref][side][remote][sha_key];
            if(!remote_sha)
                continue;

            not_empty_remote[side] = 1;
            break;
        }
    }

    remote_empty[side_a] = !not_empty_remote[side_a]
    remote_empty[side_b] = !not_empty_remote[side_b]
    remote_empty[side_any] = remote_empty[side_a] || remote_empty[side_b];
    remote_empty[side_both] = remote_empty[side_a] && remote_empty[side_b];


    for (side in sides) {
        for (ref in refs) {
            track_sha = refs[ref][side][track][sha_key];
            if(!track_sha)
                continue;

            not_empty_track[side] = 1;
            break;
        }
    }

    track_empty[side_a] = !not_empty_track[side_a]
    track_empty[side_b] = !not_empty_track[side_b]
    track_empty[side_any] = track_empty[side_a] || track_empty[side_b];
    track_empty[side_both] = track_empty[side_a] && track_empty[side_b];

    side_empty[side_a] = remote_empty[side_a] && track_empty[side_a];
    side_empty[side_b] = remote_empty[side_b] && track_empty[side_b];
    side_empty[side_any] = side_empty[side_a] || side_empty[side_b];
    side_empty[side_both] = side_empty[side_a] && side_empty[side_b];

    attach_mode = remote_empty[side_any] && ! track_empty[side_any];
}

function write(msg){
    print msg >> out_stream_attached;
}
function write_after_line(msg){
    write("\n" msg);
}
function trace(msg){
    if(!awk_trace_on)
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
function d_trace(msg){ # Development trace.
    if(0)
        return;

    trace("~" msg)
}

END{ # Disposing.
    # Possibly the close here is excessive.
    #https://www.gnu.org/software/gawk/manual/html_node/Close-Files-And-Pipes.html#Close-Files-And-Pipes
    close(out_stream_attached);
}



