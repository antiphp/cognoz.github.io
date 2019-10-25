import json
import os
import shutil
import argparse
import logging


parser = argparse.ArgumentParser(description='Example usage: python openstack_prometheus_targets.py rabbitmq 9419 --clean-dest')
parser.add_argument('svc', type=str, default='openstack',
                    help='service to monitor (haproxy/rabbitmq/galera/compute/openstack)')
parser.add_argument('port', type=int, default=9200,
                    help='exporter port to monitor (9100,9419, etc ..)')
parser.add_argument('--dest-path', dest='destPath', type=str, default="/etc/openstack_deploy/prometheus-inventory",
                    help='output destination folder (default: /etc/openstack_deploy/prometheus-inventory)')
parser.add_argument('--clean-dest', dest='destClean', default=False, action='store_true',
                    help='Pre-clean output destination folder')
args = parser.parse_args()

#Logging block
logger = logging.getLogger("openstack_prometheus_targets")
logger.setLevel(logging.INFO)
fh = logging.FileHandler("/var/log/openstack_prometheus_targets.log")
formatter = logging.Formatter('%(asctime)s %(levelname)s %(name)s [-]  %(message)s')
fh.setFormatter(formatter)
logger.addHandler(fh)

if os.path.exists(args.destPath) and args.destClean:
    shutil.rmtree(args.destPath)
if not os.path.exists(args.destPath):
  try:
      os.mkdir(args.destPath)
  except OSError:
      logger.error("Creation of the directory %s failed" % args.destPath)
      exit(1)
try:
  with open('/etc/openstack_deploy/openstack_inventory.json', 'r') as inv:
    openstack_inventory_data = json.load(inv)
except IOError:
    logger.error("Error opening /etc/openstack_deploy/openstack_inventory.json file, exit")
    exit(1)

try:
  with open('/etc/openstack_deploy/openstack_hostnames_ips.yml', 'r') as hst_ip:
    openstack_hostname_ips = json.load(hst_ip)
except IOError:
    logger.error("Error opening /etc/openstack_deploy/openstack_hostnames_ips.yml file, exit")
    exit(1)

service_to_component = {
    'haproxy': 'haproxy',
    'rabbitmq': 'rabbitmq',
    'galera': 'galera',
    'compute': 'nova_compute',
    'openstack': 'haproxy',
    'node': 'all'
}
#Node exporter case - all physical hosts
phsHosts = []
allHosts = list(openstack_inventory_data["_meta"]["hostvars"].keys())
allComponents = list(openstack_inventory_data.keys())
for hst in allHosts:
  try:
    if openstack_inventory_data["_meta"]["hostvars"][hst]["is_metal"]:
      phsHosts.append(hst)
  except KeyError:
    pass

def prom_config(service,port,dstPath):
  component = service_to_component.get(service)
  tgtHosts = []
  if component == 'haproxy':
    for hst in openstack_inventory_data["haproxy_hosts"]["hosts"]:
      tgtHosts.append(hst)
    if service == 'openstack':
      hosts = tgtHosts[0]
    else:
      hosts = tgtHosts
  try:
    if component != 'all':
      for hst in allHosts:
        try:
#          print openstack_inventory_data[component][hosts]
          if openstack_inventory_data["_meta"]["hostvars"][hst]["component"] == component:
            tgtHosts.append(openstack_inventory_data["_meta"]["hostvars"][hst]["physical_host"])
          hosts = tgtHosts
# we recieve keyerror, if component is not container
        except KeyError:
          for hst in openstack_inventory_data[component][hosts]:
            tgtHosts.append(hst)
          hosts = tgtHosts
    else:
      hosts = phsHosts
    if not hosts:
      logger.warning("Hosts list for %s component is empty, skipping" % (component))
      return
    with open(dstPath + "/" + service + ".json","w+") as inv:
      ar = []
      for hst in hosts:
        try:
          with open("/etc/openstack_deploy/ansible_facts/" + hst, 'r') as fct:
            ar.append((json.load(fct)["ansible_default_ipv4"]["address"])+":"+str(port))
          fct.close()
        except IOError:
          logger.error("Error opening ansible fact /etc/openstack_deploy/ansible_facts/%s, exit" % hst)
          exit(1)
      if component == 'all' and os.environ['ENV_PROMETHEUS_IP'] != '':
        for prm in os.environ['ENV_PROMETHEUS_IP'].split(','):
          #in case of one host env with , in the end
          if prm != '':
            ar.append(prm +":"+str(port))
      prm_cnf = json.dumps([{"targets": ar}], indent=4)
      inv.write(prm_cnf)
      inv.write("\n")
    inv.close()
    logger.debug(prm_cnf)
    logger.info("Successfully get hosts info for component %s and service %s" % (component,service))
  except KeyError:
    logger.warning("Where is no %s component in inventory, skipping" % (component))
    pass

prom_config(args.svc,args.port,args.destPath)
