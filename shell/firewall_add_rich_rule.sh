#!/bin/bash

# 加入防火墙的主机需要从外部参数传入
SOURCE_IP=$1

if [ "${SOURCE_IP}" == "" ];then
    echo "error: parameter is needed..."
    exit 1
fi

HOSTS=(110.32.13.29 110.32.13.30 110.32.13.31 110.32.13.32 110.32.13.33 110.32.13.34 110.32.13.35 110.32.13.36 110.32.13.37 110.32.13.38 110.32.13.39)


for host in "${HOSTS[@]}"
do
  echo "ADD source-${SOURCE_IP} to HOST-${host}"

  ssh "root@${host}" 2>&1  << eeooff
  exit
  systemctl start firewalld
  firewall-cmd --zone=public --add-rich-rule "rule family=\"ipv4\" source address=\"${SOURCE_IP}\" accept" --permanent
  firewall-cmd --reload
eeooff

done

echo done!
