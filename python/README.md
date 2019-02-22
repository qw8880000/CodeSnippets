
# check_logfiles.py

`check_logfiles.py` 用来检查文件的每一行，判断是否包含某关键字，它的参数有：

   * `-w`: 关键字的正则表达式
   * `-f`: 表示被检查的文件
   * `-p`: 以正则表达式表示的文件

例子：

   * `python check_logfiles.py -w "error" -f "./check_logfiles_test.txt"` 过滤`error`字符串
   * `python check_logfiles.py -w "\berror\b" -f "./check_logfiles_test.txt"`  全词匹配`error`字符串
   * `python check_logfiles.py -w "error" -p "/opt/log/app-{today | %Y%m%d}.log"` 假设今天是2018.12.24，那么上述命令的输入文件将是 `/opt/log/app-20181224.log`

# check_files_exist.py

`check_files_exist.py` 用来测试多个文件是否存在。

命令格式：

   * `python check_files_exist.py -f "./check_logfiles_test.txt"`
   * `python check_files_exist.py -p "./check_logfiles_test-{today | %Y%m%d}.txt"`
