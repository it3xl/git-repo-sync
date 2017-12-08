BEGIN{
  ref_count="ref_count";
  ref_key="ref_key";
}
{
  ref=$0;
  ref_store[ref][ref_count]++;
  ref_store[ref][ref_key]=$2;
}
END{
  for(ref in ref_store){
    if(1 < ref_store[ref][ref_count])
      continue;
    
    changed_refs[ref_store[ref][ref_key]]++;
  }
  
  for(key in changed_refs){
    print key;
  }
}