#deletion_allowed

BEGIN {
  ref_count="ref_count";
  ref_key="ref_key";
}
BEGINFILE {
  print origin_1 " " origin_2
}
{
  ref=$0;
  ref_store[ref][ref_count]++;
  ref_store[ref][ref_key]=$2;
  
  print
  print " ref_cont: " ref_store[ref][ref_count] ", ref_key: " ref_store[ref][ref_key]
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