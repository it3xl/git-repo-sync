# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync

BEGIN { # Constants.
    track_refs_path = "refs/remotes/";
    remote_refs_path = "refs/heads/";

    remote = "remote-key"
    track = "track-key"
    all_track = "all-track-key"

    sha_key = "sha-key";
    ref_key = "ref-key";

    side_a = "A";
    side_b = "B";
    
    side_any = "side-any-key";
    side_both = "side-both-key";

    sides[side_a] = side_a;
    sides[side_b] = side_b;
    
    asides[side_a] = sides[side_b]
    asides[side_b] = sides[side_a]

    val_key = "a-value-key";
    common = "common-key";
    equal = "equal-key";
    empty_both = "empty-both-key";
    empty_any = "empty-any-key";

}

