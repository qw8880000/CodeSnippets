# coding: utf-8
import os
import time
import tarfile
import argparse
import logging
from ftplib import FTP

# =============================================
# ftp_client -s "198.25.101.183" -u "" -p "" --local "" --remote "" --download
# ftp_client -s "198.25.101.183" -u "" -p "" --local "" --remote "" --upload
#
# =============================================

#从ftp下载文件
def downloadfile(ftp, remotefile, localfile):
    bufsize = 1024
    fp = open(localfile, 'wb')
    ftp.retrbinary('RETR {}'.format(remotefile), fp.write, bufsize)
    fp.close()

#从本地上传文件到ftp
def uploadfile(ftp, remotefile, localfile):
    bufsize = 1024
    fp = open(localfile, 'rb')
    ftp.storbinary('STOR {}'.format(remotefile), fp, bufsize)
    fp.close()

if __name__ == "__main__":
    #
    # 参数解析
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--server", dest="server", help="The ftp server.", metavar="FTP_SERVER", required=True)
    parser.add_argument("-u", "--user", dest="user", help="The ftp user.", metavar="USER", required=True)
    parser.add_argument("-p", "--password", dest="password", help="The ftp password.", metavar="PASSWORD", required=True)
    parser.add_argument("--local", dest="local", help="The locate file.", metavar="LOCAL", required=True)
    parser.add_argument("--remote", dest="remote", help="The dest file.", metavar="DEST", required=True)
    parser.add_argument("--download", dest="download", action="store_true", help="download file.")
    parser.add_argument("--upload", dest="upload", action="store_true", help="upload file")
    args = parser.parse_args()

    ftp_server = args.server
    ftp_user = args.user
    ftp_password = args.password
    local = args.local
    remote = args.remote
    is_download = args.download
    is_upload = args.upload

    #
    # ftp
    ftp = FTP()
    ftp.set_debuglevel(2)
    ftp.connect(ftp_server, 21)
    ftp.login(ftp_user, ftp_password)

    if is_upload == True:
        uploadfile(ftp, remote, local)
    elif is_download == True:
        downloadfile(ftp, remote, local)
    else:
        logging.error("choose download or upload.")

    # ftp.set_debuglevel(0)
    ftp.quit()
