#!/bin/bash
set -x

# Change_Source_destination_check
 aws ec2 modify-instance-attribute --no-source-dest-check \
  --region "$(/opt/aws/bin/ec2-metadata -z  | sed 's/placement: \(.*\).$/\1/')" \
  --instance-id  "$(/opt/aws/bin/ec2-metadata -i | cut -d' ' -f2)"

# start_SNAT
systemctl enable snat
systemctl start snat