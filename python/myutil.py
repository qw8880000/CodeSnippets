# -*- coding: utf-8 -*-
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
    groups = re.findall(r'(\{.*?\})', string_template)        # ? 表示非贪婪匹配

    if len(groups) <= 0:
        return string_template
    
    for group in groups:
        res = re.search(r'\{(.*)\|(.*)\}', group)
        if res == None:
            continue

        key = res.group(1).strip()
        format_pattern = res.group(2).strip()
        value = None

        if key == 'today':
            value = time.strftime(format_pattern, time.localtime())
            substitute_string = re.sub(convert_string_to_regular_expression(group), value, substitute_string)
    
    return substitute_string
