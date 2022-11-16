#!/bin/bash

HOSTS=(110.32.13.29 110.32.13.30 110.32.13.31 110.32.13.32 110.32.13.33 110.32.13.34 110.32.13.35 110.32.13.36 110.32.13.37 110.32.13.38 110.32.13.39)

for host in "${HOSTS[@]}"
do
  echo "remove firewall rules from HOST-${host}"

  ssh "root@${host}" 2>&1  << eeooff
  firewall-cmd --list-rich-rules | xargs -0 | xargs -n 1 -I {} firewall-cmd --zone=public --remove-rich-rule "{}" --permanent
  firewall-cmd --reload
  systemctl stop firewalld
  systemctl status firewalld
eeooff

done

echo done!
