# -*- coding: utf-8 -*-

#
# `check_logfiles.py` 用来检查文件的每一行，判断是否包含某关键字，它的参数有：
#    * `-w`: 关键字的正则表达式
#    * `-f`: 表示被检查的文件
#    * `-p`: 以正则表达式表示的文件
# 
# 例子：
#    * `python check_logfiles.py -w "error" -f "./check_logfiles_test.txt"` 过滤`error`字符串
#    * `python check_logfiles.py -w "\berror\b" -f "./check_logfiles_test.txt"`  全词匹配`error`字符串
#    * `python check_logfiles.py -w "error" -p "/opt/log/app-{today | %Y%m%d}.log"` 假设今天是2018.12.24，那么上述命令的输入文件将是 `/opt/log/app-20181224.log`
#
import os
import sys
import argparse
import logging
import copy
import re
import time
import ConfigParser

import myutil

def find_word_in_line(word, line):
    """判断字符串中是否包含某个关键字（全词匹配，不分大小写）
    Args:
        word: 关键字
        line: 字符串
    Returns:
        True: line中包含word
        False: line中不包含word
    """
    pattern = r'\b({0})\b'.format(word)
    result = re.search(pattern, line, flags=re.IGNORECASE)
    
    if result is not None:
        return True
    else:
        return False

def result_output(outputs):
    if len(outputs) == 0:
        logging.info('No found')
    else:
        logging.info("Found in lines: %s", outputs)
        
def check_file(file_handle, key_words):
    regular_expression = '|'.join(key_words)
    outputs = []
        
    for (line_num, line) in enumerate(file_handle):
        # result = re.search(regular_expression, line, flags=re.IGNORECASE)
        match = re.search(regular_expression, line, flags=re.IGNORECASE)
        if match:
            outputs.append(line_num + 1)

    return outputs 

def task_run_and_save_work(input_file, words):
    #
    # 获取配置
    #
    SECTION = input_file
    OPTION_OFFSET = 'offset'
    CONFIG_FILE = '.my-app-filter-work.ini'

    config = ConfigParser.RawConfigParser()
    config.read(CONFIG_FILE)

    #
    # 文件处理
    #
    with open(input_file, 'r') as f:
        if (config != None) and config.has_option(SECTION, OPTION_OFFSET):
            f.seek(config.getint(SECTION, OPTION_OFFSET))

        outputs = check_file(f, words)
        result_output(outputs)
        
        # 把解析的位置保存到文件里，下次解析从这个位置开始
        offset = f.tell()

        with open(CONFIG_FILE, 'wb') as configfile:
            if not config.has_section(SECTION):
                config.add_section(SECTION)

            config.set(SECTION, OPTION_OFFSET, offset)
            config.write(configfile)

def task_run(input_file, words):
    with open(input_file, 'r') as f:
        outputs = check_file(f, words)
        result_output(outputs)

                
if __name__ == "__main__":
    logging.basicConfig(format='%(asctime)s %(levelname)s:%(message)s', datefmt='%Y-%m-%d %I:%M:%S', level=logging.INFO)

    #
    # 参数解析
    #
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file', dest='file', help='The input file.', metavar='FILE')
    parser.add_argument('-p', '--file-pattern', dest='file_pattern', help='The input file pattern.')
    parser.add_argument('-w', '--word-pattern', dest='words', action='append', required=True, help='check logfile by the regular expression.', metavar='WORD')
    parser.add_argument('--save-work', dest='save_work', action='store_true', help='Save latest work to config file.')
    
    args = parser.parse_args()
    save_work = args.save_work
    words = args.words
    file_pattern = args.file_pattern

    # 确定 input_file
    if file_pattern:
        input_file = myutil.string_substitute(file_pattern)
    else:
        input_file = args.file

    if input_file == None:
        logging.warning('--file or --file-pattern-date must be choose.')
        sys.exit(1)

    input_file = os.path.abspath(input_file)
    logging.info('The input file is: %s', input_file)

    # 异常判断
    if not os.path.exists(input_file):
        logging.warning('The input file does not exist: %s', input_file)
        sys.exit(1)

    if not os.path.isfile(input_file):
        logging.warning('The input file is not a file: %s', input_file)
        sys.exit(1)

    #
    # task run
    #
    if save_work:
        task_run_and_save_work(input_file, words)
    else:
        task_run(input_file, words)

    sys.exit(0)
