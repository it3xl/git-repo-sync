
BEGIN { # Constants.
    track_refs_prefix = "refs/remotes/";
    remote_refs_prefix = "refs/heads/";

    remote = "remote"
    track = "track"

    sha_key = "sha";
    ref_key = "ref";

    side_a = "a";
    side_b = "b";
    
    side_any = "side_any";
    side_both = "side_both";

    sides[side_a] = side_a;
    sides[side_b] = side_b;
    
    asides[side_a] = sides[side_b]
    asides[side_b] = sides[side_a]
}

