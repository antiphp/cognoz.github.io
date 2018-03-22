#!/usr/bin/python
#This scrpt checks status (running:true or false) of currnet node in rabbitmq cluster
import pycurl
import cStringIO
import errno, sys
import socket
import syslog

user = sys.argv[1]
password = sys.argv[2]
vip = sys.argv[3]

currentip=((([ip for ip in socket.gethostbyname_ex(socket.gethostname())[2]
    if not ip.startswith("127.")] or ip.startswith(vip) or [[(s.connect(("8.8.8.8", 53)),
        s.getsockname()[0], s.close()) for s in [socket.socket(socket.AF_INET,
           socket.SOCK_DGRAM)]][0][1]]) + ["no IP found"])[0])

hostname = socket.gethostname()
response = cStringIO.StringIO()
response_nodes = cStringIO.StringIO()

#Checking if the current node is running at least
node = pycurl.Curl()
node.setopt(node.URL, 'http://{0}/api/nodes/rabbit@{1}?columns=running'.format(currentip, hostname))
node.setopt(node.PORT, 15672)
node.setopt(node.USERPWD, "{0}:{1}".format(user, password))
node.setopt(node.WRITEFUNCTION, response.write)
node.perform()
node.close()
resp = response.getvalue().split(",")
resp = [x for x in resp if '"running":true' in x ]
print resp
#Checking another hosts (only count)
nodes = pycurl.Curl()
nodes.setopt(nodes.URL, 'http://%s/api/nodes?columns=running' % currentip)
nodes.setopt(nodes.PORT, 15672)
nodes.setopt(nodes.USERPWD, "{0}:{1}".format(user, password))
nodes.setopt(nodes.WRITEFUNCTION, response_nodes.write)
nodes.perform()
nodes.close()
resp_nodes = response_nodes.getvalue().split(",")
resp_nodes = [x for x in resp_nodes if '"running":false' in x ]
lng=len(resp_nodes)
print lng
#print response_nodes.getvalue()


if resp and len(resp_nodes) == 2:
  syslog.syslog(syslog.LOG_ERR, 'Current rabbit@%s host is thinking that its online but its not! Moving VIP to other place' % hostname)
  sys.exit(1)
if not resp and len(resp_nodes) == 2:
  syslog.syslog(syslog.LOG_ERR, 'Current rabbit@%s host is dead! Moving VIP to other place' % hostname)
  sys.exit(1)
