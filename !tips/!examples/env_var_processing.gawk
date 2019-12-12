
# We use split() instead of this approach as it has "child process creation" overhead.
# But it can be useful sometimes.
# For split() approaches look for "split(ENVIRON[".
function awk_native_processing_of_an_environment_var(    cmd, result){
    cmd = "echo \"$your_var\"";

    while (cmd | getline result){
        if(!result){
            continue;
        }
        d_trace("result is " result);
    }

    close(cmd);
}
