import datetime
import time
import requests

parser = argparse.ArgumentParser(description='Example usage: python get_prometheus_metrics.py metrics.txt 01-08-2020 30-08-2020 output_metrics.1')
parser.add_argument('file', type=str, default='metrics.txt',
                    help='service to monitor (haproxy/rabbitmq/galera/compute/openstack)')
parser.add_argument('port', type=int, default=9200,
                    help='exporter port to monitor (9100,9419, etc ..)')
parser.add_argument('--dest-path', dest='destPath', type=str, default="/etc/openstack_deploy/prometheus-inventory",
                    help='output destination folder (default: /etc/openstack_deploy/prometheus-inventory)')
parser.add_argument('--clean-dest', dest='destClean', default=False, action='store_true',
                    help='Pre-clean output destination folder')
args = parser.parse_args()

startdate = '01-2020-08-01'
enddate = '2020-08-03'

with open ("metrics.txt", "r") as metricsfile:
#    metrics=metricsfile.readlines()
    metrics=metricsfile.read().split('\n')


print("Quering metrics %s from %s to %s" % (metrics,startdate,enddate))
raw_input("Press Enter to continue...")

PROMETHEUS = 'http://localhost:9090/'

def get_metric(tstamp,metric):
  print("query for %s metric, stamp, %s" % (metric, tstamp))
  response = requests.get(PROMETHEUS + '/api/v1/query',
    params={
      'query': metric,
      'time': tstamp})
  results = response.json()['data']['result']
  for result in results:
    print result['value'][0]
    datcr=datetime.datetime.fromtimestamp(result['value'][0])
    result.update({'date': datcr})
    print(' {metric}: {value[1]}, {value[0]}, {date}'.format(**result))

start_t_stamp = int(time.mktime(datetime.datetime.strptime(startdate, "%Y-%m-%d").timetuple()))
end_t_stamp = int(time.mktime(datetime.datetime.strptime(enddate, "%Y-%m-%d").timetuple()))
for metric in metrics:
  t_stamp = start_t_stamp
  while t_stamp <= end_t_stamp:
    for h in range(24*60): #24 hours
      t_stamp += 60 # one minute
      get_metric(t_stamp,metric)
