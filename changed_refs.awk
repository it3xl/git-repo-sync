#deletion_allowed

BEGIN {
  ref_count="ref_count";
  ref_key="ref_key";
}
BEGINFILE {
  file_num++;
  switch (file_num) {
    case "1":
      repo=origin_1
      break
    case "2":
      repo=origin_2
      break
  }

  print file_num " repo = " repo "\n"
}
{
  ref=$0;
  ref_store[ref][ref_count]++;
  ref_store[ref][ref_key]=$2;
  
  print
  print "    ref_key: " ref_store[ref][ref_key] "; ref_cont: " ref_store[ref][ref_count]
  print ""
  
}
END {

  print "oppa"
  for(ref in ref_store){
    if(1 < ref_store[ref][ref_count])
      continue;
    
    changed_refs[ref_store[ref][ref_key]]++;
  }
  
  for(key in changed_refs){
    print key;
  }
}