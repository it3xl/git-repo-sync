
# Puts only error output to a variable. Prevents useless execution by "--count=1".
# Looks inside "refs/remotes" only.
errors_for_each=$(git for-each-ref --count=1 refs/remotes 2>&1 1>/dev/null)


if [[ $errors_for_each == 'warning: ignoring broken ref refs/remotes/'* ]]; then
    echo
    echo
    echo '@@' Crash Recovery '@@'
    echo '@'
    echo '@' Possibly the internal checking repository is slightly broken after an unexpected PC switching off. 
    echo '@' All remote references will be reloaded. So, you will see an increased log related to internal references updating.
    echo '@' It is because we got the following problem':'
    echo "@    $errors_for_each"
    echo '@'
    echo '@@@@@@@@@@@@@@@@@@@@'
    echo

    rm -rf "$(git rev-parse --absolute-git-dir)/refs/remotes"
    mkdir "$(git rev-parse --absolute-git-dir)/refs/remotes"
fi;
