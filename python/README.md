
# check_logfiles.py

`check_logfiles.py` 的传入参数:
    * `-w`: 表示过滤的关键字（全词匹配，不区分大小写）
    * `-f`: 表示被过滤的文件
    * `--file-pattern`: 文件名中带有变量

假如我们有一个文件`/opt/log/app.log`，它的内容如下：
```
[error] This is a message.
[info] This is a message.
[debug] This is a message.
[exception] This is a message.

error This is a message.
info This is a message.
debug This is a message.
exception This is a message.
```

例子1：
```
python check_logfiles.py -w error -f /opt/log/app.log
```
上述命令表示，把`/opt/log/app.log`文件中带有 `error` 关键字的行过滤出来。输出如下：
```
2018-12-24 03:48:47 ERROR: find "error" 2 times in lines: [1, 6]
```


例子2：
```
python check_logfiles.py -w error -w exception -f /opt/log/app.log
```
上述命令表示，把`/opt/log/app.log`文件中带有 `error` 或者`exception`关键字的行过滤出来。输出如下：
```
2018-12-24 04:04:10 ERROR: find "error" 2 times in lines: [1, 6]
2018-12-24 04:04:10 ERROR: find "exception" 2 times in lines: [4, 9]
```

例子3，假设日志文件的文件名中带有今天的日期，那个可以使用`--file-pattern` 来指定文件：
```
python check_logfiles.py -w error --file-pattern /opt/log/app-{today | %Y%m%d}.log
```
假设今天是2018.12.24，那么上述命令的输入文件将是 `/opt/log/app-20181224.log`

# check_files_exist.py

测试文件是否存在。
