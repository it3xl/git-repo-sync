#deletion_allowed

BEGIN {
  ref_count="ref_count";
  ref_key="ref_key";
}
BEGINFILE {
  switch (++file_num) {
    case "1":
      repo=origin_1
      break
    case "2":
      repo=origin_2
      break
  }

  #print file_num " repo = " repo "\n"
}
{
  ref=$2;
  ref_store[ref][repo]=$1;
}
END {

  for(ref in ref_store){
    print ref
    print origin_1 " " ref_store[ref][origin_1]
    print origin_2 " " ref_store[ref][origin_2]
    print ""

    if(ref_store[ref][origin_1] == ref_store[ref][origin_2])
      continue;
    
    changed_refs[ref]++;
  }
  
  print ""
  for(ref in changed_refs){
    print ref;
  }
}