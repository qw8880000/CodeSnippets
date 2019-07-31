#!/bin/bash

# 查看主机到目标主机的端口是否连通
hosts=(192.25.107.15 192.25.107.14)

dest=192.25.107.16
dest_port=22

for host in "${hosts[@]}"
do
  result=$(ssh  "root@$host" nc -v -w 2 -i 2 $dest $dest_port 2>&1)
  conn_result=$(echo $result | grep Connected)
  if [[ "$conn_result" == "" ]]; then
    echo "warn: $host connect to $dest $dest_port fail!"
  else
    echo "$host connect to $dest $dest_port ok!"
  fi
done

echo done!
