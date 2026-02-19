#!/bin/bash
if [ "$EUID" -ne 0 ]; then
 echo "Please run as root (use sudo)"
 exit 1
fi
LOG_FILE="/var/log/auth.log"
THRESHOLD=3
OUTPUT="ssh_security_report.txt"

echo "=====================================" > $OUTPUT
echo " SSH failed Login Security Report" >> $OUTPUT
echo " Generated on: $(date)" >> $OUTPUT
echo "=====================================" >> $OUTPUT
echo "" >> $OUTPUT

# Extract and count IP addresses 
sudo grep "Failed password" $LOG_FILE | \
awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' | \
sort | uniq -c | sort -nr > temp_counts.txt

echo "Failed Login Attempts by IP:" >> $OUTPUT
cat temp_counts.txt >> $OUTPUT
echo "" >> $OUTPUT

echo "Suspicious IPs (>= $THRESHOLD attempts):" >> $OUTPUT

awk -v threshold=$THRESHOLD '$1 >= threshold {print "ALERT:" $2 " - " $1 "failed attempts"}' temp_counts.txt >> $OUTPUT

rm temp_counts.txt

echo "Report saved to $OUTPUT"
