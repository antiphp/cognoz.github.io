import json
import subprocess
import argparse
import logging

parser = argparse.ArgumentParser(description='Example usage: python velero-annotate.py --exclude-ns default,kube-system OR python velero-annotate.py --include-ns minio')
parser.add_argument('--overwrite', dest='overwrite', default=False, action='store_true', help="Force overwrite annotation with backup volume's names")
parser.add_argument('--exclude-ns', dest='excludeNs', default='', help='NS to exclude from annotation process')
parser.add_argument('--include-ns', dest='includeNs', default='', help='NS to include for annotation process. Mutually exclusive with --exclude-ns')
args = parser.parse_args()

#Logging block
logger = logging.getLogger("velero_annotate")
logger.setLevel(logging.INFO)
fh = logging.FileHandler("./velero_annotate.log")
formatter = logging.Formatter('%(asctime)s %(levelname)s %(name)s [-]  %(message)s')
fh.setFormatter(formatter)
logger.addHandler(fh)


process = subprocess.Popen("oc get ns | grep -v NAME | awk '{print $1}' | tr '\n' ' '", stdout=subprocess.PIPE, shell=True)
NS = process.stdout.read().split(' ')

if args.excludeNs and args.includeNs:
  print "Pleases, use exclude-ns or include-ns flag but not both"
  logger.info("Invoked with both exclude-ns and include-ns flags, exiting")
  exit(1)

if args.excludeNs:
  NS = list(set(NS) - set(args.excludeNs.split(',')))
#remove garbage
while("" in NS) :
    NS.remove("")

if args.includeNs:
  NS = args.includeNs.split(',')

logger.info("Annotation will be proceed with this NS list: %s" % NS)
#Get NS with PVC -> Get all pods in NS -> get volumes definition for pods in NS -> annotate each pvc
for n in NS:
  process = subprocess.Popen("oc get pvc -n %s" % n, stdout=subprocess.PIPE, shell=True)
  NAS = process.stdout.read()
  if NAS != '':
    process = subprocess.Popen("oc get po -n %s | grep -v NAME | awk '{print $1}' | tr '\n' ' '" % n, stdout=subprocess.PIPE, shell=True)
    PO = process.stdout.read().split(' ')
    while("" in PO) :
      PO.remove("")
    for p in PO:
      process = subprocess.Popen("oc get po %s -n %s -o json | jq .spec.volumes" % (p,n), stdout=subprocess.PIPE, shell=True)
      try:
        logger.info("Get .spec.volumes for pod %s in NS %s" % (p,n))
        PoJS = json.loads(process.stdout.read())
        PvC = []
        PvCs = ''
        try:
          for v in PoJS:
            try:
              if v['persistentVolumeClaim'] != "":
                PvC.append(v['name'])
            except:
              logger.info("Not PVC type volume, proceeding further")
          PvCs = ','.join(map(str, PvC))
          if PvCs:
            if args.overwrite:
              process = subprocess.Popen("oc -n %s annotate --overwrite pod/%s backup.velero.io/backup-volumes=%s" % (n,p,PvCs), stdout=subprocess.PIPE, shell=True)
            else:
              process = subprocess.Popen("oc -n %s annotate pod/%s backup.velero.io/backup-volumes=%s" % (n,p,PvCs), stdout=subprocess.PIPE, shell=True)
            logger.info("Successfully annotated pod %s in NS %s for volume('s) %s" % (p,n,PvCs))
        except:
          logger.warning("No volumes for pod %s in NS %s" % (p,n))
      except:
        logger.warning("failed loading volumes json for pod %s in NS %s" % (p,n))
print("All pods with connected pvc were annotated!")
logger.info("All pods with connected pvc were annotated!")
