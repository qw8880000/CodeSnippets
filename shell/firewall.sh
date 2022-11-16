#!/bin/bash

hosts=(10.25.97.11 10.25.97.12 10.25.97.13 10.25.97.14 10.25.97.15 10.25.97.16 10.25.97.17 10.25.97.18 10.25.97.19 10.25.97.20 10.25.97.21 10.25.97.22 10.25.97.23 10.25.97.24 10.25.97.25)

for i in $(seq 0 ${#hosts[@]})
do
  host=${hosts[$i]}
  ssh "root@$host" > /dev/null 2>&1 << eeooff
  firewall-cmd --add-rich-rule 'rule family="ipv4" source address="198.25.100.70" accept' --permanent
  firewall-cmd --add-rich-rule 'rule family="ipv4" source address="192.25.66.88" accept' --permanent
  firewall-cmd --reload
  exit
eeooff
done

echo done!
