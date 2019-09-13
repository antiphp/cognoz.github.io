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

with open('/etc/openstack_deploy/openstack_hostnames_ips.yml', 'r') as hst:
    openstack_hostname_ips = json.load(hst)

service_to_component = {
    'haproxy': 'haproxy',
    'rabbitmq': 'rabbitmq',
    'galera': 'shared-infra_hosts',
    'compute': 'nova_compute',
    'openstack': 'shared-infra_hosts'
}

def prom_config(service,port,dstPath):
  component = service_to_component.get(service)
  try:
    hosts = openstack_inventory_data[component]["hosts"]
    if not hosts:
      logger.warning("Hosts list for %s component is empty, skipping" % (component))
      return
    with open(dstPath + "/" + component + "_inventory","w+") as inv:
      ar = []
      for hst in hosts:
        try:
          with open("/etc/openstack_deploy/ansible_facts/" + hst, 'r') as fct:
            ar.append((json.load(fct)["ansible_default_ipv4"]["address"]))
          fct.close()
        except IOError:
          logger.error("Error opening ansible fact /etc/openstack_deploy/ansible_facts/%s, exit" % hst)
          exit(1)
      prm_cnf = json.dumps([{"targets": ar}], indent=4)
      inv.write(prm_cnf)
      inv.write("\n")
    inv.close()
    logger.debug(prm_cnf)
    logger.info("Successfully get %s hosts info" % (component))
  except KeyError:
    logger.warning("Where is no %s component in inventory, skipping" % (component))
    pass

prom_config(args.svc,args.port,args.destPath)
