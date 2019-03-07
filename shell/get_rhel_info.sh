#!/bin/sh

# 获取操作系统类型，如：Linux，Windows
OS_TYPE=$(uname -s)

# 主机名称，如：wjl-pc
OS_HOSTNAME=$(uname -n)

# 系统发行版本信息，如：Red Hat Enterprise Linux Server release 7.4 (Maipo)
OS_INFORMATION=$(lsb_release -d | awk -F "[\t:]" '{print $3}')
RHEL_VERSION=$(lsb_release -r | awk '{print $2}')

# 计算机类型，如：'x86_64' 
OS_MACHINE=$(uname -m)

# CPU主频，单位MHz
CPU_FREQ=$(cat /proc/cpuinfo | grep MHz | uniq | awk -F [" ":]+ '{print $3}')

# CPU逻辑核数
CPU_LOGIC_CORES=$(cat /proc/cpuinfo | grep "processor" | wc -l)

# 总内存（单位字节）
MEM_TOTAL=$(free | grep Mem | awk '{print  $2}')

# 总硬盘（单位字节）
DISK_TOTAL=$(fdisk -l | grep "Disk /dev/"| grep -v "/dev/mapper" | awk -F [" ",]+ '{sum+=$5} END {print sum}')

# 所有的IP地址
if [[ $RHEL_VERSION == "7.4" ]]; then
  IP_TOTAL=$(ifconfig | grep "inet" | grep -v "inet6\|127.0.0.1" | awk '{if(NR==1){ip=$2}else{ip=ip","$2}} END{print ip}')
elif [[ $RHEL_VERSION == "6.5" ]]; then
  IP_TOTAL=$(ifconfig | grep "inet addr" | grep -v "127.0.0.1" | awk -F [" ":]+ '{if(NR==1){ip=$4}else{ip=ip","$4}} END{print ip}')
else
  IP_TOTAL="null"
fi

function format_json_string {
  key=$1
  value=$2
  echo \"$key\":\"$value\"
}

function format_json_int {
  key=$1
  value=$2
  echo \"$key\":$value
}

# 输出json格式
echo \{\
$(format_json_string "os_type" "$OS_TYPE"),\
$(format_json_string "os_hostname" "$OS_HOSTNAME"),\
$(format_json_string "os_information" "$OS_INFORMATION"),\
$(format_json_string "os_machine" "$OS_MACHINE"),\
$(format_json_int "cpu_freq" "$CPU_FREQ"),\
$(format_json_int "cpu_logic_cores" "$CPU_LOGIC_CORES"),\
$(format_json_int "mem_total" "$MEM_TOTAL"),\
$(format_json_int "disk_total" "$DISK_TOTAL"),\
$(format_json_string "ip_total" "$IP_TOTAL")\
\}

