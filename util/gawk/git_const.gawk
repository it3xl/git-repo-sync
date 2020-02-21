
BEGIN { # Constants.
    track_refs_prefix = "refs/remotes/";
    remote_refs_prefix = "refs/heads/";

    sha_key = "sha";
    ref_key = "ref";

    side_a = "a";
    side_b = "b";

    sides[side_a] = side_a;
    sides[side_b] = side_b;
    
    asides[side_a] = sides[side_b]
    asides[side_b] = sides[side_a]
}

