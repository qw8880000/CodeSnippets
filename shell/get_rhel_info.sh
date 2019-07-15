#!/bin/sh


function format_json_string {
  key=$1
  value=$2
  echo \"$key\":\"$value\"
}

#
# 获取操作系统类型，如：Linux，Windows
#
OS_TYPE=$(uname -s)

#
# 主机名称，如：wjl-pc
#
OS_HOSTNAME=$(uname -n)

#
# 系统发行版本信息，如：Red Hat Enterprise Linux Server release 7.4 (Maipo)
#
OS_INFORMATION=$(cat /etc/redhat-release)

#
# 计算机类型，如：'x86_64' 
#
OS_MACHINE=$(uname -m)

#
# CPU逻辑核数
#
CPU_LOGIC_CORES=$(cat /proc/cpuinfo | grep "processor" | wc -l)

#
# 总内存（单位字节）
#
MEM_TOTAL=$(free -b | grep Mem | awk '{print $2}')

#
# 总硬盘（单位字节）
#
#DISK_TOTAL=$(fdisk -l | grep "Disk /dev/"| grep -v "/dev/mapper" | awk -F [" ",]+ '{sum+=$5} END {print sum}')
DISK_TOTAL=$(cat /proc/partitions | grep "[s,h,v]d[a-z]$" | awk '{sum+=$3} END {print sum*1024}')

#
# net interface
#
function get_ip {
  interface=$1
  local ip=""

  if [[ $OS_INFORMATION =~ "7." ]]; then
    ip=$(ifconfig "$interface" | grep "inet [0-9\.]\+" | sed 's/.*inet \([0-9\.]\+\).*/\1/g')
  else
    ip=$(ifconfig "$interface" | grep "inet addr:[0-9\.]\+" | sed 's/.*inet addr:\([0-9\.]\+\).*/\1/g')
  fi

  echo $ip
}
function get_netmask {
  local netmask=""
  interface=$1

  if [[ $OS_INFORMATION =~ "7." ]]; then
    netmask=$(ifconfig "$interface" | grep "inet.* netmask [0-9\.]\+" | sed 's/.*inet.* netmask \([0-9\.]\+\).*/\1/g')
  else
    netmask=$(ifconfig "$interface" | grep "inet addr:.* Mask:[0-9\.]\+" | sed 's/.*inet addr:.*Mask:\([0-9\.]\+\).*/\1/g')
  fi

  echo $netmask
}
function get_mac {
  local mac=""
  interface=$1

  if [[ $OS_INFORMATION =~ "7." ]]; then
    mac=$(ifconfig "$interface" | grep "ether [0-9a-zA-Z:]\+" | sed 's/.*ether \([0-9a-zA-Z:]\+\).*/\1/g')
  else
    mac=$(ifconfig "$interface" | grep "HWaddr [0-9a-zA-Z:]\+" | sed 's/.*HWaddr \([0-9a-zA-Z:]\+\).*/\1/g')
  fi

  echo $mac
}

all_interface=""
interfaces=($(ip -4 -f inet -o addr | grep "inet.*scope global" | sed 's/inet addr/inet/g' | awk '{print $2}'))
ips=($(ip -4 -f inet -o addr | grep "inet.*scope global" | sed 's/inet addr/inet/g' | awk '{print $4}' | awk -F [/] '{print $1}'))
netmasks=($(ip -4 -f inet -o addr | grep "inet.*scope global" | sed 's/inet addr/inet/g' | awk '{print $4}' | awk -F [/] '{print $2}'))

index=0
for interface in "${interfaces[@]}"
do
  name="$interface"
  #ip=$(get_ip "$interface")
  #netmask=$(get_netmask "$interface")
  ip="${ips[$index]}"
  netmask="${netmasks[$index]}"
  mac=$(get_mac "$interface")

  let "index += 1"

  item="{\
    $(format_json_string "name" "$name"),\
    $(format_json_string "ip" "$ip"),\
    $(format_json_string "netmask" "$netmask"),\
    $(format_json_string "mac" "$mac") }"

  if [[ "$all_interface" == "" ]]; then
    all_interface="$item"
  else
    all_interface="$all_interface","$item"
  fi
done


#
# 是否是虚拟机
#
if [[ $(dmidecode -s system-product-name | grep "VMware") != "" ]]; then
  IS_VIRTUAL=true
else
  IS_VIRTUAL=false
fi

#
# 装机时间
# 最近一次重启的时间
#
INSTALL_TIME=$(ls -lct --time-style=+"%Y-%m-%d %H:%M:%S" /etc/redhat-release | tail -1 | sed 's/.*\(....-..-.. ..:..:..\).*/\1/g')
LAST_BOOT_UP_TIME=$(date -d "$(awk -F. '{print $1}' /proc/uptime) second ago" +"%Y-%m-%d %H:%M:%S")

#
# 输出json格式
#
echo \{\
$(format_json_string "is_virtual" "$IS_VIRTUAL"),\
$(format_json_string "os_type" "$OS_TYPE"),\
$(format_json_string "os_hostname" "$OS_HOSTNAME"),\
$(format_json_string "os_information" "$OS_INFORMATION"),\
$(format_json_string "os_machine" "$OS_MACHINE"),\
$(format_json_string "cpu_logic_cores" "$CPU_LOGIC_CORES"),\
$(format_json_string "mem_total" "$MEM_TOTAL"),\
$(format_json_string "disk_total" "$DISK_TOTAL"),\
\"net_interface\":[$all_interface],\
$(format_json_string "last_boot_up_time" "$LAST_BOOT_UP_TIME"),\
$(format_json_string "install_time" "$INSTALL_TIME"),\
$(format_json_string "myver" "1.3")\
\}

