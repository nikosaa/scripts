#!/bin/bash

old=`tempfile`
new=`tempfile`
echo Reading old IPs to ${old}
ufw status numbered | awk -F'[[:space:]][[:space:]]+'  '/Amazon CloudFront/{print $3}' | sort > ${old}
echo Reading new IPs to ${new}
curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | jq -r '[.prefixes[] | select(.service=="CLOUDFRONT").ip_prefix] | .[]'  | sort > ${new}

echo Comparing results
diff ${old} ${new} | while read i j ; do 
  case "${i}" in
   ">" )
    echo ${j} to be added 
    ufw allow from "$j" to any app "Apache Secure" comment "Amazon CloudFront";
    ;;
   "<" )
    echo ${j} to be removed
    ufw delete allow from "$j" to any app "Apache Secure"
    ;;
  esac
done

echo Removing temporary files
rm ${old} ${new}
