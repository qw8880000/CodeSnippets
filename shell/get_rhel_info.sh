#!/bin/sh

# 获取操作系统类型，如：Linux，Windows
OS_TYPE=$(uname -s)

# 主机名称，如：wjl-pc
OS_HOSTNAME=$(uname -n)

# 系统发行版本信息，如：Red Hat Enterprise Linux Server release 7.4 (Maipo)
OS_INFORMATION=$(cat /etc/redhat-release)

# 计算机类型，如：'x86_64' 
OS_MACHINE=$(uname -m)

# CPU逻辑核数
CPU_LOGIC_CORES=$(cat /proc/cpuinfo | grep "processor" | wc -l)

# 总内存（单位字节）
MEM_TOTAL=$(free -b | grep Mem | awk '{print $2}')

# 总硬盘（单位字节）
DISK_TOTAL=$(fdisk -l | grep "Disk /dev/"| grep -v "/dev/mapper" | awk -F [" ",]+ '{sum+=$5} END {print sum}')

# 所有的IP地址
if [[ $OS_INFORMATION =~ "7." ]]; then
  IP_TOTAL=$(ifconfig | grep "inet.*netmask" | grep -v "inet6\|127.0.0.1" | \
    awk 'BEGIN{count=0;} \
    {ip[count]=$2;mask[count]=$4;count++;} \
    END{\
      item="";\
      for(i=0;i<count;i++){\
        if(i==0){item=ip[i]"|"mask[i]}\
        else{item=item","ip[i]"|"mask[i]}\
      }\
      print item;
    }')
else
  IP_TOTAL=$(ifconfig | grep "inet addr" | grep -v "127.0.0.1" | \
    sed 's/.*inet addr:\([0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}\).*Mask:\([0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}\)/\1 \2/g' | \
    awk 'BEGIN{count=0;} \
    {ip[count]=$1;mask[count]=$2;count++;} \
    END{\
      item="";\
      for(i=0;i<count;i++){\
        if(i==0){item=ip[i]"|"mask[i]}\
        else{item=item","ip[i]"|"mask[i]}\
      }\
      print item;
    }')
fi

# 是否是虚拟机
if [[ $(dmidecode -s system-product-name | grep "VMware") != "" ]]; then
  IS_VIRTUAL="true"
else
  IS_VIRTUAL="false"
fi

function format_json_string {
  key=$1
  value=$2
  echo \"$key\":\"$value\"
}

# 输出json格式
echo \{\
$(format_json_string "myver" "1.0"),\
$(format_json_string "is_virtual" "$IS_VIRTUAL"),\
$(format_json_string "os_type" "$OS_TYPE"),\
$(format_json_string "os_hostname" "$OS_HOSTNAME"),\
$(format_json_string "os_information" "$OS_INFORMATION"),\
$(format_json_string "os_machine" "$OS_MACHINE"),\
$(format_json_string "cpu_logic_cores" "$CPU_LOGIC_CORES"),\
$(format_json_string "mem_total" "$MEM_TOTAL"),\
$(format_json_string "disk_total" "$DISK_TOTAL"),\
$(format_json_string "ip_total" "$IP_TOTAL")\
\}


