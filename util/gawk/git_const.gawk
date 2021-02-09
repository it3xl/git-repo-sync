# it3xl.ru git-repo-sync https://github.com/it3xl/git-repo-sync

BEGIN { # Constants.
    track_refs_path = "refs/remotes/";
    remote_refs_path = "refs/heads/";

    remote = "remote"
    track = "track"

    sha_key = "sha";
    ref_key = "ref";

    side_a = "A";
    side_b = "B";
    
    side_any = "side_any";
    side_both = "side_both";

    sides[side_a] = side_a;
    sides[side_b] = side_b;
    
    asides[side_a] = sides[side_b]
    asides[side_b] = sides[side_a]
}

