from socket import *
from time import ctime

HOST='198.25.100.11'
PORT=10050
ADDR=(HOST,PORT)


c = socket(AF_INET, SOCK_STREAM)
c.settimeout(10)
c.connect(ADDR)
c.close()

print "OK"
