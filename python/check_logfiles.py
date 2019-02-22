# -*- coding: utf-8 -*-
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

def find_word_re_in_line(word_re, line):
    """判断字符串中是否包含某个正则表达式
    Args:
        word_re: 正则表达式
        line: 字符串
    Returns:
        True: line中包含word
        False: line中不包含word
    """
    pattern = word_re
    result = re.search(pattern, line, flags=re.IGNORECASE)
    if result is not None:
        return True
    else:
        return False

def result_output(outputs):
    if len(outputs) == 0:
        logging.info('no found')
    else:
        logging.info(outputs)
        
def filter(file_handle, key_words, word_re_array):
    output_template = {'key': '', 'filter_by': 0, 'line_nums': []}
    outputs = []
    
    if key_words:
        for key_word in key_words:
            output = copy.deepcopy(output_template)
            output['key'] = key_word
            output['filter_by'] = 0
            outputs.append(output)

    if word_re_array:
        for word_re in word_re_array:
            output = copy.deepcopy(output_template)
            output['key'] = word_re
            output['filter_by'] = 1
            outputs.append(output)

    outputs_empty = copy.deepcopy(outputs)
        
    for (line_num, line) in enumerate(file_handle):
        for item in outputs:
            if (item['filter_by'] == 0) and find_word_in_line(item['key'], line):
                item['line_nums'].append(line_num + 1)
            elif (item['filter_by'] == 1) and find_word_re_in_line(item['key'], line):
                item['line_nums'].append(line_num + 1)

    if cmp(outputs, outputs_empty) == 0:
        return []
    else:
        return outputs
        

def task_run_and_save_work(input_file, words, word_re_array):
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

        outputs = filter(f, words, word_re_array)
        result_output(outputs)
        
        # 把解析的位置保存到文件里，下次解析从这个位置开始
        offset = f.tell()

        with open(CONFIG_FILE, 'wb') as configfile:
            if not config.has_section(SECTION):
                config.add_section(SECTION)

            config.set(SECTION, OPTION_OFFSET, offset)
            config.write(configfile)

def task_run(input_file, words, word_re_array):
    with open(input_file, 'r') as f:
        outputs = filter(f, words, word_re_array)
        result_output(outputs)

                
if __name__ == "__main__":
    logging.basicConfig(format='%(asctime)s %(levelname)s:%(message)s', datefmt='%Y-%m-%d %I:%M:%S', level=logging.INFO)

    #
    # 参数解析
    #
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file', dest='file', help='The input file.', metavar='FILE')
    parser.add_argument('--file-pattern', dest='file_pattern', help='The input file pattern.')
    parser.add_argument('-w', '--word', dest='words', action='append', help='Filter lines by the word.', metavar='WORD')
    parser.add_argument('-r', '--word-re', dest='word_re_array', action='append', help='Filter lines by the regular expression.', metavar='Regular expression')
    parser.add_argument('--save-work', dest='save_work', action='store_true', help='Save latest work to config file.')
    
    args = parser.parse_args()
    save_work = args.save_work
    words = args.words
    word_re_array = args.word_re_array
    file_pattern = args.file_pattern

    # 确定 input_file
    if file_pattern:
        input_file = myutil.string_substitute(file_pattern)
    else:
        input_file = args.file

    input_file = os.path.abspath(input_file)
    logging.info('The input file is: %s', input_file)

    # 异常判断
    if (not file_pattern) and (not input_file):
        logging.warning('--file or --file-pattern-date must be choose.')
        sys.exit(1)

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
        task_run_and_save_work(input_file, words, word_re_array)
    else:
        task_run(input_file, words, word_re_array)

    sys.exit(0)
