# -*- coding: utf-8 -*-

#
# `check_files_exist.py` 用来测试多个文件是否存在。
# 
# 例子：
#    * `python check_files_exist.py -f "./check_logfiles_test.txt"`
#    * `python check_files_exist.py -p "./check_logfiles_test-{today | %Y%m%d}.txt"`
#
import os
import sys
import argparse
import logging

import myutil

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
        files.append(myutil.string_substitute(file_pattern))

    # 判断文件是否存在
    for f in files:
        if not os.path.exists(f):
            files_no_exist.append(f)

    if len(files_no_exist) > 0:
        logging.info("No exist count %s, %s", len(files_no_exist), files_no_exist)
    else:
        logging.info("All exist.")
