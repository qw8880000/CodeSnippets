# -*- coding: utf-8 -*-

import os
import sys
import time
import wmi
import platform
import json

mywmi= wmi.WMI()

def get_os_type():
    """ 获取操作系统类型，如：Linux，Windows
    """
    return platform.system()

def get_os_hostname():
    """ 获取主机名称，如：wjl-pc
    """
    return platform.node()

def get_os_information():
    """ 获取操作系统名称及版本号，如：Windows-7-6.1.7601-SP1
    """
    return platform.platform()

def get_os_machine():
    """ 计算机类型，如：'x86' 
    """
    return platform.machine()

def get_cpu_freq():
    """ 获取CPU主频，单位MHz
    """
    cpu_freq = 0
    for processor in mywmi.Win32_Processor():
        cpu_freq += processor.MaxClockSpeed

    return cpu_freq

def get_cpu_logic_cores():
    """获取CPU逻辑核数
    """
    cpu_cores = 0
    for processor in mywmi.Win32_Processor():
        cpu_cores += processor.NumberOfCores

    return cpu_cores

def get_mem_total():
    """获取内存
    """
    mem_total = 0
    for Memory in mywmi.Win32_PhysicalMemory():
        mem_total += int(Memory.Capacity)

    return mem_total

def get_disk_total():
    """获取硬盘容量
    """
    disk_total = 0
    for physical_disk in mywmi.Win32_DiskDrive():
        disk_total += int(physical_disk.Size)

    return disk_total

def get_ip_total():
    """获取所有的IP地址
    """
    ip_total = []
    for interface in mywmi.Win32_NetworkAdapterConfiguration(IPEnabled=1):
        ip = interface.IPAddress[0]
        ip_total.append(ip)

    return ip_total

if __name__ == '__main__':
    windows_info = {
            "os_type": get_os_type(),
            "os_hostname": get_os_hostname(),
            "os_information": get_os_information(),
            "os_machine": get_os_machine(),
            "cpu_logic_cores": get_cpu_logic_cores(),
            "cpu_freq": get_cpu_freq(),
            "mem_total": get_mem_total(),
            "disk_total": get_disk_total(),
            "ip_total": get_ip_total()
            }

    print json.dumps(windows_info)

