# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync

BEGIN { # Constants.
    out_stream_attached = "/dev/stderr";
}
BEGIN {
    awk_trace_on = !! ENVIRON["env_awk_trace_on"];
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



