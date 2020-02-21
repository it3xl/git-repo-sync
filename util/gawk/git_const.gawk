
BEGIN { # Constants.
    track_refs_prefix = "refs/remotes/";
    remote_refs_prefix = "refs/heads/";

    sha_key = "sha";
    ref_key = "ref";

    side_a = 1;
    side_b = 2;

    sides[side_a] = 1;
    sides[side_b] = 2;
    
    asides[side_a] = sides[side_b]
    asides[side_b] = sides[side_a]
}

