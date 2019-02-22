# -*- coding: utf-8 -*-
import os
import sys
import argparse
import logging
import copy
import re
import time

def convert_string_to_regular_expression(string_template):
    """ 把字符串中正则表达式的特殊字符加上转义符号
        例如："{today|%Y}" 转成 "\{today\|%Y\}"
    """
    substitute_string = copy.copy(string_template)
    substitute_string = re.sub(r'\{', r'\{', substitute_string)
    substitute_string = re.sub(r'\}', r'\}', substitute_string)
    substitute_string = re.sub(r'\|', r'\|', substitute_string)
    return substitute_string

def string_substitute(string_template):
    """
        说明：
            1. {key | format}，其中 | 是分格符，左边是key，右边是format
            2. 目前支持的key:
                - today

        例子：
            1. app-{today | %Y%m%d}-test.log，将被格式化成 app-20181223-test.log
    """

    substitute_string = copy.copy(string_template)
    groups = re.findall(r'(\{.*\}?)', string_template)        # ? 表示非贪婪匹配

    if len(groups) <= 0:
        return string_template
    
    for group in groups:
        res = re.search(r'\{(.*)\|(.*)\}', group)
        if res == None:
            continue

        key = res.group(1)
        format_pattern = res.group(2)
        value = None

        if key == 'today':
            value = time.strftime(format_pattern, time.localtime())
            substitute_string = re.sub(convert_string_to_regular_expression(group), value, substitute_string)
    
    return substitute_string

if __name__ == "__main__":
    logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', datefmt='%Y-%m-%d %I:%M:%S', level=logging.INFO)

    #
    # 参数解析
    #
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file', dest='files', action='append', help='The input file.', metavar='FILE')
    parser.add_argument('-p', '--file-pattern', dest='file_patterns', action='append', help='The input file pattern.')

    args = parser.parse_args()
    files = args.files or []
    file_patterns = args.file_patterns or []
    files_no_exist = []

    for file_pattern in file_patterns:
        files.append(string_substitute(file_pattern))

    # 判断文件是否存在
    for f in files:
        if not os.path.exists(f):
            files_no_exist.append(f)

    if len(files_no_exist) > 0:
        logging.info("No exist count %s, %s", len(files_no_exist), files_no_exist)
    else:
        logging.info("All exist.")
