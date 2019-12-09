#!/bin/bash
#cluster=$1
#address=$2
#vip=$3
set -x
address="master.epaas11d24.epaas.s7.aero:8443"
cluster="epaas11d24"
vip="172.20.92.250"
DS_TIMEOUT=20
declare -A bearer
bearer["epaas11d24"]="uckhSCcBKzc4eYfzctz52E0xdtqa1bAlA1dle9Ms8pY"

#ZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNklpSjkuZXlKcGMzTWlPaUpyZFdKbGNtNWxkR1Z6TDNObGNuWnBZMlZoWTJOdmRXNTBJaXdpYTNWaVpYSnVaWFJsY3k1cGJ5OXpaWEoyYVdObFlXTmpiM1Z1ZEM5dVlXMWxjM0JoWTJVaU9pSjJaV3hsY204aUxDSnJkV0psY201bGRHVnpMbWx2TDNObGNuWnBZMlZoWTJOdmRXNTBMM05sWTNKbGRDNXVZVzFsSWpvaWRtVnNaWEp2TFhSdmEyVnVMVGc0ZG5kcklpd2lhM1ZpWlhKdVpYUmxjeTVwYnk5elpYSjJhV05sWVdOamIzVnVkQzl6WlhKMmFXTmxMV0ZqWTI5MWJuUXVibUZ0WlNJNkluWmxiR1Z5YnlJc0ltdDFZbVZ5Ym1WMFpYTXVhVzh2YzJWeWRtbGpaV0ZqWTI5MWJuUXZjMlZ5ZG1salpTMWhZMk52ZFc1MExuVnBaQ0k2SW1NeU5UUmtOekk1TFdZMU5tSXRNVEZsT1MxaU16QTRMVEF3TlRBMU5qazFNR1JtWXlJc0luTjFZaUk2SW5ONWMzUmxiVHB6WlhKMmFXTmxZV05qYjNWdWREcDJaV3hsY204NmRtVnNaWEp2SW4wLmdPdUxDRVVSQllPZXl4dkRDZzlCejZhYTVWRDV2Yjg4Z0tEY2NNY0taam1kU3Q3SGJpa1JrRDNZcGZnNzRRTEIwVVpuYUJDTVV2allRSElCTE15S1UyUVc5aWd2WUNsY3Z3ejVCVzI5a0FOVXNqb1hkMGlDd3lNMXo0RzlSWWtyMHpYRzJqZzVJUFFwZkpnalk2YlhwNng4TkFFV0dvS25vTzlHT3VjcE5uNXc3MDc2MkpZRDJ6UklKN2hZcmtsODFWT2RjWFVKMGdZUHBXby1sR3Y3WjlUQy1ZYlVnWlRjdDNtQ0FYQTdFR2NtRWE4ZjNsVmhBQTh0RlFuRTNQM3FvRk4xdW9zNHZhZ3Awb1VyenVBbUZyWWVlZ2trYWxSTXBhTm9GX1FtMzVpVVAwOWxwcUlJUFlRbGhmNzhOck43NGJCWmkzdDdNUzRsdkt3RDhaRnlOdw=="
bearer["common11d24"]=""
bearer["common11u24"]=""
bearer["common11p24"]=""
check_pod_exists() {
        curl -s -o /dev/null -w "%{http_code}" --insecure -H "Authorization: Bearer ${bearer[${cluster}]}" "https://${address}/api/v1/namespaces/default/pods/zabbix-tst"
}
check_ds_exists() {
        curl -s -o /dev/null -w "%{http_code}" --insecure -H "Authorization: Bearer ${bearer[${cluster}]}" "https://${address}/apis/extensions/v1beta1/namespaces/default/daemonsets/zabbix-ds"
}
if [[ `check_pod_exists` == 200 || `check_ds_exists` == 200 ]]
then
    curl -s -o /dev/null --connect-timeout 5 -w "%{http_code}" -L -H 'Host: www.ngn.s7' ${vip}
    curl -s -o /dev/null --insecure -XDELETE -H "Authorization: Bearer ${bearer[${cluster}]}" "https://${address}/api/v1/namespaces/default/pods/zabbix-tst"
    curl -s -o /dev/null --insecure -XDELETE -H "Authorization: Bearer ${bearer[${cluster}]}" "https://${address}/api/v1/namespaces/default/secrets/zabbix-tst"
    curl -s -o /dev/null --insecure -XDELETE -H "Authorization: Bearer ${bearer[${cluster}]}" "https://${address}/api/v1/namespaces/default/services/zbx-service"
    curl -s -o /dev/null --insecure -XDELETE -H "Authorization: Bearer ${bearer[${cluster}]}" "https://${address}/apis/extensions/v1beta1/namespaces/default/ingresses/zbx-ingress"
    curl -s -o /dev/null --insecure -XDELETE -H "Authorization: Bearer ${bearer[${cluster}]}" \
        -H "Accept: application/json" -H "Content-Type: application/json" \
        -d '{"propagationPolicy":"Background"}' \
        "https://${address}/apis/extensions/v1beta1/namespaces/default/daemonsets/zabbix-ds"
else
    curl -s -o /dev/null --insecure -XPOST  \
        -H "Authorization: Bearer ${bearer[${cluster}]}"  \
        -H 'Content-Type: application/json' \
        -d '{"apiVersion":"v1","kind":"Secret","metadata":{"name":"zabbix-tst","namespace":"default","labels":{"app":"zbx"}},"type":"kubernetes.io/dockerconfigjson","data":{".dockerconfigjson":"eyJhdXRocyI6eyJuZXh1cy1yZWdpc3RyeS5zNy5hZXJvOjE4MTE2Ijp7InVzZXJuYW1lIjoiZXBhYXMtcmVnaXN0cnkiLCJwYXNzd29yZCI6IjkkYyVCNW1aek5CQSNGIiwiZW1haWwiOiJlcGFhcy1zdXBwb3J0QHM3LnJ1IiwiYXV0aCI6IlpYQmhZWE10Y21WbmFYTjBjbms2T1NSakpVSTFiVnA2VGtKQkkwWT0ifX19"}}' \
        "https://${address}/api/v1/namespaces/default/secrets" || exit 1
    #Create DS accross nodes
    curl -s -o /dev/null --insecure -XPOST \
        -H "Authorization: Bearer ${bearer[${cluster}]}"  \
        -H 'Content-Type: application/json' \
        -d '{"apiVersion":"extensions/v1beta1","kind":"DaemonSet","metadata":{"labels":{"app":"zbx"},"name":"zabbix-ds","namespace":"default"},"spec":{"template":{"metadata":{"labels":{"app":"zbx","name":"zabbix-tst"}},"spec":{"containers":[{"image":"nexus-registry.s7.aero:18116/nginx-unprivileged:1-fixperm","imagePullPolicy":"Always","name":"zbx-tst","securityContext":{"runAsUser":"101"}}],"imagePullSecrets":[{"name":"zabbix-tst"}]}}}}' \
        "https://${address}/apis/extensions/v1beta1/namespaces/default/daemonsets" || exit 1
    #Wait a little while pods are spawned
    sleep $DS_TIMEOUT
    #Get desired number of pods for ds
    DS_DESIRED=$(curl --insecure -XGET \
        -H "Authorization: Bearer ${bearer[${cluster}]}" \
        -H 'Content-Type: application/json' \
        "https://${address}/apis/extensions/v1beta1/namespaces/default/daemonsets/zabbix-ds" | jq .status.desiredNumberScheduled)
    #Get number of pods with ready status
    DS_READY=$(curl --insecure -XGET \
        -H "Authorization: Bearer ${bearer[${cluster}]}" \
        -H 'Content-Type: application/json' \
        "https://${address}/apis/extensions/v1beta1/namespaces/default/daemonsets/zabbix-ds" | jq .status.numberReady)
    if [[ ${DS_DESIRED} != ${DS_READY} ]]; then
      exit 1
    fi
    curl -s -o /dev/null --insecure -XPOST \
        -H "Authorization: Bearer ${bearer[${cluster}]}"  \
        -H 'Content-Type: application/json' \
        -d '{"apiVersion":"v1","kind":"Pod","metadata":{"name":"zabbix-tst","namespace":"default","labels":{"app":"zbx"}},"spec":{"securityConext":{"runAsUser":"101"},"nodeSelector":{"node-role.kubernetes.io/infra":"true"},"containers":[{"name":"nginx","image":"nexus-registry.s7.aero:18116/nginx-unprivileged:1-fixperm","imagePullPolicy":"Always"}],"imagePullSecrets":[{"name":"zabbix-tst"}]}}' \
        "https://${address}/api/v1/namespaces/default/pods" || exit 1
    curl -s -o /dev/null --insecure -XPOST  \
        -H "Authorization: Bearer ${bearer[${cluster}]}" \
        -H 'Content-Type: application/json' \
        -d '{"apiVersion":"v1","kind":"Service","metadata":{"name":"zbx-service","namespace":"default","labels":{"app":"zbx"}},"spec":{"ports":[{"port":8080,"targetPort":8080}],"type":"ClusterIP","selector":{"app":"zbx"}}}' \
        "https://${address}/api/v1/namespaces/default/services" || exit 1
    curl -s -o /dev/null --insecure -XPOST  \
        -H "Authorization: Bearer ${bearer[${cluster}]}" \
        -H 'Content-Type: application/json' \
        -d '{"apiVersion":"extensions/v1beta1","kind":"Ingress","metadata":{"name":"zbx-ingress","namespace":"default"},"spec":{"rules":[{"host":"www.ngn.s7","http":{"paths":[{"backend":{"serviceName":"zbx-service","servicePort":8080},"path":"/"}]}}]}}' \
        "https://${address}/apis/extensions/v1beta1/namespaces/default/ingresses" || exit 1
    echo '200'
fi
