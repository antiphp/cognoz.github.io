---
layout: page
title: cheats
permalink: /cheats/
---

### JQ parsing  
Get pretty-printed version  
``cat test.json | jq '.'``  
Get only metadata section  
``cat test.json | jq '.metadata'``  
Accessing field inside metadata  
``cat test.json | jq '.metadata .key'``  
Accessing values inside arrays  
``cat test.json | jq '.metadata[0]'``  
Using conditionals
``cat test.json |  jq .[] | jq 'select(.name == "vtb-rheltest-01").nics[1].ipAddress'``  

### Long resolving time
``cat /etc/resolv.conf
options single-request``  

### Systemd stuff
Reaaaly weird bug in Centos7.6 with systemd-219-67.el7  -
starting some exporter (https://github.com/czerwonk/ping_exporter) with flag   --config.path="path" not equal to   
starting with flag --config.path="path" (this failed)...  

### Java wget old JDK
Login on java website  
Start Download  
Stop downloading  
Get URL with ?AuthParam=  
wget url  

### ipmitool shortcuts
``ipmitool -I lanplus -H FQDN -U username -P 'hardpasswithspecialcymbols' chassis status -L user``  

### HARD cold reboot of Linux (carefull, almost as IMPI reset)  
``echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger``  

### Download office365 onedrive file via wget  
``When you take the original URL and cut the text behind the '?' and add the text: download=1
Example:
original shared file in Office365:
Code: Select all

https://iotc360-my.sharepoint.com/:u:/p/blabla/EdTJBkefastNuBX3n9y9NxUBJeh4Birs6_qBbTMldBiDGg?e=on40g4
modified behind the question mark:
Code: Select all

wget https://iotc360-my.sharepoint.com/:u:/p/blabla/EdTJBkefastNuBX3n9y9NxUBJeh4Birs6_qBbTMldBiDGg?download=1``  

### stupd firewalld  
``firewall-cmd --permanent --zone=public --add-port=2234/tcp``  

### SSH Tunnels
Copy via tunnel  
``# First, open the tunnel
ssh -L 1234:remote2:22 -p 45678 user1@remote1
# Then, use the tunnel to copy the file directly from remote2
scp -P 1234 user2@localhost:file``  

### Megacli Basic info  
``MegaCli -LDInfo -Lall -aALL``   

### Simple html/js code woth hostname printing
``<html>
<body>
<script>
document.write(location.hostname);
</script>
</body>
</html>``

### journalctl  
``journalctl --since "2019-12-20 17:15:00"``  

### Cloud image set pass  
``apt update; apt -y install libguestfs-tools
wget https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img  
virt-customize -a xenial-server-cloudimg-amd64-disk1.img --root-password password:coolpass``  

### Recreate ovs ports with options  
``ovs-vsctl add-port br-tun vxlan-0adc6d0a  -- set interface vxlan-0adc6d0a type=vxlan options:df_default="true" options:dst_port="5789" options:egress_pkt_mark="0" options:in_key=flow options:local_ip="10.220.107.4" options:out_key=flow options:remote_ip=10.220.107.10``  

### Determine qdhcp NS via network  
``for ns in $(ip netns | grep qdhcp | tr '\n' ' '); do echo $ns; ip netns exec $ns ip -4 a | grep 192.168.174; done``  

### Get ram usage staticstics
``ps aux  | awk '{print $6/1024 " MB\t\t" $11}'  | sort -n``  

### awk
Staled queues   
``rabbitmqctl list_queues -p /neutron  | awk -F' ' '$2!="0"'``  

### Apt - adding new deb packages in repo    
``apt-get install dpkg-dev  
mkdir -p /usr/local/mydebs
cd /usr/local/mydebs
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
#Get files locally via apt  
echo "deb file:/usr/local/mydebs ./ >> /etc/apt/sources.list
apt update"``  


### SElinux  
basic stuff for surviving with docker and se  
``semodule -l|grep container
semanage fcontext -l|grep /var/lib/docker
grep avc /var/log/audit/audit.log
restorecon -Frv /var/lib/docker/overlay2/*
grep docker /etc/selinux/targeted/contexts/files/file_contexts``

#### Restore right labels  
`` semanage fcontext -a -t container_var_lib_t '/var/lib/docker(/.*)?'
semanage fcontext -a -t container_share_t '/var/lib/docker/.*/config/\.env'
semanage fcontext -a -t container_file_t '/var/lib/docker/vfs(/.*)?'
semanage fcontext -a -t container_share_t '/var/lib/docker/init(/.*)?'
semanage fcontext -a -t container_share_t '/var/lib/docker/overlay(/.*)?'
semanage fcontext -a -t container_share_t '/var/lib/docker/overlay2(/.*)?'
semanage fcontext -a -t container_share_t '/var/lib/docker/containers/.*/hosts'
semanage fcontext -a -t container_log_t '/var/lib/docker/containers/.*/.*\.log'
semanage fcontext -a -t container_share_t '/var/lib/docker/containers/.*/hostname'``

## Pip upload whl to PYPIserver
``pip install twine
twine upload file_name.whl --repository-url https://pip.server_name.com/``  

## OSA build pip wheels cmd  
``pip wheel --timeout 120 --wheel-dir /tmp/openstack-wheel-output --find-links /var/www/repo/links --find-links /tmp/openstack-wheel-output --constraint /var/www/repo/os-releases/17.1.17/ubuntu-16.04-x86_64/requirements_constraints.txt  --no-binary libvirt-python --no-binary cryptography  --index-url https://pypi.python.org/simple --trusted-host pypi.python.org  --build /tmp/openstack-builder --requirement /var/www/repo/os-releases/17.1.17/ubuntu-16.04-x86_64/requirements.txt  2>&1 | ts > /var/log/repo/wheel_build.log``  

## Cool prompt for compute servers  
Paste it in any .bash_* file  
``cluster_id="id"
role_id="compute"
role="$cluster_id $role_id"
if [[ -n $cluster_id ]]
then
    if [[ $role_id == "compute" ]]
    then
        virsh -h 2&>1
        if [[ $? == 0 ]]
        then
            virsh_cmd="virsh"
        fi
        docker exec nova_libvirt virsh -h 2&>1
        if [[ $? == 0 ]]
        then
            virsh_cmd="docker exec nova_libvirt virsh"
        fi
        if [[ -n $virsh_cmd ]]
        then
            role="$cluster_id $role_id \$($virsh_cmd list | grep -c instance)|\$($virsh_cmd list --inactive | grep -c instance)VMs"
            unset virsh_cmd
        fi
    fi
else
    if [[ -n $role_id ]]
    then
        role=$role_id
    else
        role="none"
    fi
fi
export PS1="\[\e[00;32m\]\u@($role) \h\[\e[0m\]\[\e[00;37m\]:\[\e[0m\]\[\e[00;36m\][\w]\[\e[0m\]\[\e[00;37m\]:#\[\e[0m\] "
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}\007"'
unset role
unset role_id
unset cluster_id``  

### Openshift  
simulate OOM  
``https://access.redhat.com/solutions/47692``  

get hostsubnets (maybe you dont have space in your network):  
``oc get hostsubnets``  
get oauthclient ( maybe you have wrong redirect urls):  
``oc get ouathclient``  
delete all evicted pods:  
``kubectl get po -a --all-namespaces -o json | \
jq  '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) |
"kubectl delete po \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 bash -c``  

get every resource in namespace (k8s too):  
``kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n openshift-monitoring``  
get ovs ports in containers  
``ovs-ofctl -O OpenFlow13 dump-ports-desc br0  
ovs-appctl ofproto/trace br0 "tcp,  nw_dst=10.11.0.1, in_port=2"``    
Problems with datastore "Unable to find VM by UUID. VM UUID: (empty or something)"  
``please, check these  
kubectl get nodes -o json | jq '.items[]|[.metadata.name, .spec.providerID, .status.nodeInfo.systemUUID]'  AND    
cat /sys/class/dmi/id/product_serial``  
Problems with starting privileged container (2 different securityContext):    
``use securityContext IN container spec, not pod:  
securityContext:
  privileged: true
image: registry:18116/heptio-images/velero:v1.1.0
imagePullPolicy: IfNotPresent
name: restic
resources: {}
terminationMessagePath: /dev/termination-log
terminationMessagePolicy: File
volumeMounts:
- mountPath: /host_pods
  mountPropagation: HostToContainer
  name: host-pods
securityContext:
  runAsUser: 0``    
also dont forget about  
``oc adm policy add-scc-to-user privileged system:serviceaccount:testrk2:testnice``  

and about joining networks either  
``oc adm pod-network join-projects --to=velero kube-system``  

Get etcdctl info  
``ETCDCTL_API=3 etcdctl get "" --from-key --endpoints https://172.20.61.11:2379 --cacert="/etc/etcd/ca.crt" --cert="/etc/etcd/server.crt" --key="/etc/etcd/server.key"``  
test fs  
``docker run -it registry:18116/twalter/openshift-nginx /bin/bash ``  
Right way to delete LDAP users:  
``oc delete identity 'provider=ldap ......'``   

How to redirect oauth in Openshift  
``kind: ServiceAccount
metadata:
  annotations:
    serviceaccounts.openshift.io/oauth-redirecturi.first: https://grafana-testfu.domain.com``  
Cronjob for sync ldap users  
oc create -f [cronjob-sync-ldap.yml]({{"/listings/cronjob-sync-ldap.yml"}})  

Bug     
``Error updating node status, will retry: failed to patch status " ......
for node "ep-u1-i-001": The order in patch list:

[map[address:172.20.59.44 type:ExternalIP] map[address:172.20.59.41 type:ExternalIP] map[address:172.20.59.44 type:InternalIP] map[address:172.20.59.41 type:InternalIP]]
 doesn't match $setElementOrder list:``  
 (maybe related to vsphere cloudprovider, but setting up nodeIp in kubelet helps 100%)    
https://bugzilla.redhat.com/show_bug.cgi?id=1552644#c22  

### Docker hacks  
Formatting  
``#!/bin/bash
for container in $( docker ps -a --format {{.ID}} ); do
	buildName="$( docker inspect --format '{{index .Config.Labels "io.openshift.build.name"}}' "${container}" )"
	if [[ -n "${buildName}" ]]; then
		exitCode="$( docker inspect --format '{{.State.ExitCode}}' "${container}" )"
		if [[ "${exitCode}" != 0 ]]; then
			docker rm -v "${container}"
		fi
	fi
done``  

### DevPI server hacks
``pip install devpi-server
mkdir /var/www/devpi
devpi-server --host=0.0.0.0 --serverdir /var/www/devpi --start --init``  

### Ansible ad-hoc with dynamic_inventory  
Ex. 1. Testing new nova code  
``ansible -m copy -a 'src=virt dest=/openstack/venvs/nova-17.1.17/lib/python2.7/site-packages/nova/' -i /opt/openstack-ansible/inventory/dynamic_inventory.py nova_api_container
ansible -m shell -a 'rm -rf /var/log/nova/*; reboot' -i /opt/openstack-ansible/inventory/dynamic_inventory.py nova_api_container``  

### Ansible iterate inside of one of with_items argument  
``- name: Find logs in kolla log dir
  find:
    follow: true
    paths: "{{ sb_kolla_log_path }}/{{ item }}"
    age: "-{{ sb_max_age }}"
    patterns: '*log*'
  with_items: "{{ sb_kolla_log_services }}"
  register: sb_kolla_log_info``  

Structure, we need to iterate through results list and files list:   
``{"msg": { "results": [{files[path]}]}}``  
Result cycle:  
``- name: Fetch Kolla logs from nodes
  fetch:
    src: "{{ item[1].path }}"
    dest: "{{ sb_tmp_dir }}/{{ ansible_hostname }}/{{ item[0].item }}/"
    flat: true
    validate_checksum: false
  with_subelements:
    - "{{ sb_kolla_log_info.results }}"
    - files``  

### Ansible extract custom fact from inventory  
``10.10.10.10 custom_fact=fact
msg: "\{\{ (groups['prometheus'] | map('extract', hostvars, ['custom_fact']) | join(',')).split(',') \}\}"``  

### Convert and upload tar.gz to pypiserver (OSA)  
``cd /opt; mkdir prometheus-client/
cd prometheus-client
pip download prometheus-client
cd /opt/openstack-ansible/
ansible -m shell -a 'ls /var/www/repo/pools/' repo_container
ansible -m copy -a 'src=/opt/prometheus-client dest=/var/www/repo/pools/ubuntu-16.04-x86_64/' repo_container``  

check  
``cat /root/.pip/pip.conf  
curl -L ip:port/simple | grep prometheus_client``  

### ansible reboot machines  
``ansible -m shell -a 'reboot' -i contour-auto-deployment/deployment-os/inventory/contour-inv '*'``  

### reboot all components except galera and rabbit  
``ansible -m shell keystone_all,cinder_api,glance_api,memcached,neutron_server,nova_api,nova_compute,heat_api -a 'reboot'``  
### boot from volume  
``nova boot  --block-device source=image,id=fb0b4daf-16f9-400b-ab78-9f93e3de2f1d,dest=volume,size=8,shutdown=preserve,bootindex=0 --key-name rk --nic net-name=flat-net --flavor tiny-vol rk2``  
``openstack security group rule create --dst-port 80 --protocol tcp --remote-ip 0.0.0.0/0 default``  

### Tune OSA  
``ansible -m shell -a "sed -i 's/processes.*/processes = 16/g'  /etc/uwsgi/*" cinder_api
ansible -m shell -a "sed -i 's/threads.*/threads = 16/g'  /etc/uwsgi/*" cinder_api
ansible -m shell -a "sed -i 's/threads.*/threads = 16/g'  /etc/uwsgi/*" nova_api_metadata
ansible -m shell -a "sed -i 's/processes.*/processes = 16/g'  /etc/uwsgi/*" nova_api_metadata
ansible -m shell -a "sed -i 's/threads.*/threads = 32/g'  /etc/uwsgi/*" keystone
ansible -m shell -a "sed -i 's/processes.*/processes = 32/g'  /etc/uwsgi/*"  keystone
ansible -m shell -a "reboot" keystone,cinder_api,nova_api_metadata
ansible -m shell -a "sed -i 's/osapi_compute_workers.*/osapi_compute_workers = 32/g'  /etc/nova/nova.conf"  nova_compute
ansible -m shell -a "sed -i 's/metadata_workers.*/metadata_workers = 32/g'  /etc/nova/nova.conf"  nova_compute
ansible -m shell -a "sed -i 's/^workers = 16/workers = 32/g'  /etc/nova/nova.conf"  nova_compute
ansible -m shell -a "sed -i 's/max_instances_per_host = 50/max_instances_per_host = 500/g'  /etc/nova/nova.conf"  nova_compute
ansible -m shell -a "systemctl restart nova-compute"  nova_compute``  

### OSA reclone git repos in repo_container  
``openstack-ansible -vv -e '{repo_build_git_reclone: True}' playbooks/repo-install.yml
``  

### Git pull every branch  
``git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
git fetch --all
git pull --all``

### Nmap check for DHCP  
``nmap --script broadcast-dhcp-discover -e eth0
check dhcp in network``  

### CentOS virtual KVM hypervisor - no guests boot successful  
If you see smth like "booting from hard drive" then place this in nova-compute.conf  
``[libvirt]
hw_machine_type = x86_64=pc-i440fx-rhel7.2.0``  

### NoVNC configuration  
controller (62)
``[vnc]
novncproxy_host = 10.220.104.62
novncproxy_port = 6080``  
compute   (63)
``[vnc]
novncproxy_host = 10.220.104.63
novncproxy_port = 6080
novncproxy_base_url = http://int.os.local:6080/vnc_auto.html
vncserver_listen = 10.220.104.63
vncserver_proxyclient_address = 10.220.104.63``  

### Ansible ARA openstack  
``source /opt/ansible-runtime/bin/activate
pip install ara
pip install ansible==2.4.6.0 (for queens)
source <(python -m ara.setup.env)
openstack-ansible -vv playbooks/setup-everything.yml  
ara-manage runserver
Browse http://127.0.0.1:9191``  

### Easy way to recreate KVM vm's (script)   
``#!/bin/bash
virsh destroy vm && virsh undefine vm
rm -f /opt/kvm/vm/vm.qcow2
cp ./vm-centos7.qcow2 /opt/kvm/vm/vm.qcow2
virt-install --name vm --virt-type kvm --vcpus 4  --memory 8192 --disk /opt/kvm/vm/vm.qcow2,device=disk,bus=virtio    --disk /opt/kvm/iso/vm.iso,device=cdrom   --graphics none   --boot hd,cdrom,menu=on             --network bridge=br-bond0,model=virtio             --import             --graphics vnc,listen=0.0.0.0 --os-type linux             --os-variant centos7.0   --noautoconsole``  

### Change label on partiton  
``e2label /dev/sda1 ROOT``  

### Installation of CentOS7 on old supermicro servers  
on "Install Centos7" press tab  and add
``nomodeset text``  to the end, press enter  
#### other option  
If you dont see your raid volume in boot menu, you
can try following:  
``boot in UEFI mode
install system
place UEFI disk as number 1 device in bios boot lists
reboot``

### Check filesystem existence on block device
``head -n 30 /dev/sda | hexdump``  

### check udp port  
``nc -v -u -z -w 3 172.29.12.11 514``  

### Check memory  
``top -o %MEM -n 1 -b | head -n20``  

### Skip Gitlab CI during committing  
``git commit -m "something [ci skip]"``  

### Git update referance to latest submodule  
``git clone --recurse-submodules https://repo/scm/gcloud/ansible-playbook-deploy-nodes.git
cd ansible-playbook-deploy-nodes/
cd configs/
git checkout master && git pull
cd ..
git add configs
git commit -m "updating submodule configs to latest"
git push``  

### Git latest commit sha  
``git log -n1 --format=format:"%H"``  

### change rsyslog conf in all lxc containers with restart (recursive)  
``ssh infra  
cd /var/lib/lxc/
cp infra01_nova_api_container-f61f0140/rootfs/etc/rsyslog.d/51-remote-logging.conf ./
m=$(ls -la | grep infra | awk '{print $9}'); for i in $m; do \cp -f 51-remote-logging.conf $i/rootfs/etc/rsyslog.d/; lxc-attach -n $i -- systemctl restart rsyslog; done``  


### If you cant get intel raid menu  
``in bios select RAID not AHCI``  

### Using telnet to access smtp server  
``telnet smtp.domain.ru 25
AUTH LOGIN
334 VXNlcm5hbWU6
ZXBhYXNfa110cA==   #base64 username  
334 UGFzc3dvcmQ6m
bW9vZDlc2No       #base64 password  
535 5.7.0 authentication failed``  

### Send email via Linux CLI (ext smtp server)  
``apt-get install heirloom-mailx  
echo "This is the message body and contains the message" | mailx -v -r "someone@example.com" -s "This is the subject" -S smtp="mail.example.com:587" -S smtp-auth=login -S smtp-auth-user="someone@example.com" -S smtp-auth-password="abc123" -S ssl-verify=ignore yourfriend@gmail.com``  

### Get default grub version and set needed  
``awk '/menuentry/ && /class/ {count++; print count-1"****"$0 }' /boot/grub/grub.cfg``     

### Change tty console in NoVNC Openstack Instance  
``alt+rightarrow / alt+leftarrow``   

### To avoid interface name changes via udev (pass options to kernel):  
``net.ifnames=1 biosdevname=1``  

### Check open ports without netstat and sudo  
``ss -4tpla`` or ``ss -a``  

### After revert from old snapshot or something like this SSL errors everywhere    
wrong date on machine  

### Enable netsted virtualization in KVM guest  
virsh edit vm   
``<cpu>  
<feature policy='require' name='vmx'/>;  
</cpu>``    
### Calculate average from file via bash  
``count=0; total=0; for i in $( cat file.txt ); do total=$(echo $total+$i | bc );((count++)); done; echo "scale=2; $total / $count" | bc``  

### Docker retag / repush images to private registry  
``IMAGES=$(docker images | egrep 'docker.io|quay.io' | awk '{print $1":"$2}')
REPO="ep-iac-harbor-001:5000"
printf "$IMAGES\n" > img.txt
while read -r img; do
  img_img=$(echo $img | cut -d"/" -f2-10)
  echo $REPO/$img_img
  docker tag $img $REPO/$img_img
  docker push $REPO/$img_img
done<img.txt``  
### In oneline
``for img in $(docker images | awk '{print $1":"$2}' | grep -v REPOSITORY | tr '\n' ' '); do docker tag $img harbor.cognoz/$img; docker push harbor.cognoz/$img; done``  

### Docker inspect -> Run  
Nexdrew I love you.  
``docker run --rm -i -v /var/run/docker.sock:/var/run/docker.sock nexdrew/rekcod <container>``  

### Docker access crashing container  
``docker commit CONTAINER NEWIMAGENAME
docker run -ti --entrypoint /bin/bash NEWIMAGENAME``  

### List all Prometheus Labels  
curl / browser  
``http://serverip:serverport/api/v1/label/__name__/values``  

### Query via API some job for timerange  
``curl 'http://PROMIP:9090/api/v1/query_range?query=%7Bjob%3D%27consul_libvirt%27%7D&start=2019-12-04T20:10:30.781Z&end=2019-12-11T10:11:00.781Z&step=150s'``    

### Prometheus delete metrics by name/label  
( add --web.enable-admin-api flag to prometheus )  
``curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={__name__="cloudapi_instance_ok"}'
curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="ruslanbalkin-dev"}'``  


### Alertmanager multiple jobs query  
``up{env="ed-8",job="consul_libvirt"} == 0 and ON(instance)  up{env="ed-8",job="consul_node_exporter"} == 0``  

### Alertmanager PagerDuty integration  
cat /etc/alertmanager/alertmanager.yml  
``#
# Ansible managed
#

global:
  resolve_timeout: 3m
  smtp_smarthost: localhost:25
  smtp_from: alertmanager@newlma.ru
templates:
- '/etc/alertmanager/templates/*.tmpl'
receivers:
- email_configs:
  - to: devops@domain.co
  name: default
- name: pagerduty
  pagerduty_configs:
  - severity: "critical"
    description: "Recieved critical error, react ASAP!"
    service_key: INTEGRATION KEY
    url: "https://events.pagerduty.com/v2/enqueue"
route:
  group_by: [cluster]
  receiver: default
  routes:
  - match:
      severity: 'critical'
    receiver: pagerduty
``  
### Firing test alert AlertManager  
``#!/bin/bash

name="Test alert for pagerduty"
url='http://localhost:9093/api/v1/alerts'

echo "firing up alert $name"

# change url o
curl -XPOST $url -d "[{
        \"status\": \"firing\",
        \"labels\": {
                \"alertname\": \"$name\",
                \"service\": \"test\",
                \"severity\":\"critical\",
                \"instance\": \"Test\"
        },
        \"annotations\": {
                \"summary\": \"IT works!\"
        },
        \"generatorURL\": \"http://prometheus.int.example.net/<generating_expression>\"
}]"``  

### Export / Import Grafana Dashboards from one instance to another  
Export  
``curl -k -u admin:admin "ip:port/api/dashboards/uid/$UID | jq '.dashboard.id = null' > dash.json"``  
Import  
``curl -u admin:admin -H "Content-Type: application/json" -d @dash.json -X POST http://ip:port/api/dashboards/db``   

### Grafana freezes dashboard loading after importing new dashboard  
``{meta {dashboard{refresh: false }}}  SHOULD BE FALSE!!!!``  

### Problems with lab novnc openstack console ? (1006)  
``ssh compute  
vim /etc/nova/nova.conf  
  novncproxy_base_url=https://public_vip_ctrl:6080/vnc_auto.html  
service nova-compute restart``  

### Workaround to force Nginx Ingress reload it's configuration  
``kubectl patch ingress myingress -p '{"metadata":{"labels":{"dummy":"some_unique_new_value"}}}'``  

## Consul  
### Start as client  
``consul agent -bind=10.36.22.50 -retry-join=10.36.22.100 -config-dir=/etc/consul.d -data-dir=/opt/consul -encrypt "string"``  
### Could not decrypt message  
on client or server do  ``rm -rf data_dir/cerf/*``  
### Get leader  
``consul operator raft list-peers``  

### Exposing UDP services k8s   
[udp_expose]({{"/listings/cheats/udp_expose.yml"}})  

#### Check connectivity  
In ubuntu container  
``apt update && apt install netcat  
netcat -ul -p54``  
in another place  
``echo reply-me | ./nc.traditional -u VIP 54``  

#### Check websocket  
``wget https://github.com/vi/websocat/releases (ubuntu/win)
websocat -q -uU ws://mediaserver.kurento.ru/kurento; echo $?;
check  server logs``  

### Huge node.js apps build  
``docker-compose build --build-arg NODE_OPTIONS=--max-old-space-size=5600 my.app``
### Kubernetes get pod ips by selectors  
``kubectl get pods --selector=app=service_test_pod -o jsonpath='{.items[*].status.podIP}'
10.0.1.2 10.0.2.2``   

### How prevent kernel to detect soft RAID  
``nomdmonddf nomdmonisw``  

### SSH passpharse using in script  
cat helper.sh  
``exec cat``  
cat script.sh  
``eval $(ssh-agent)   
export SSH_ASKPASS=./helper.sh  
export DISPLAY=  
echo ${PASSPHRASE} | SSH_ASKPASS=./helper.sh ssh-add ${KEY} 2> /dev/null  
ssh targetVM  
``  
### Specify ssh options (password authentication)  
``ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no``  

### Watch file/dir changes  
``inotifywait -mr /var/log/ssh_audit.log``  

### Nginx CentOS 403 on files  
``1. sestatus - need to be permissive  
2. user root in conf``  

### Simple python logging (uniq lines) in file   
``import logging  
import logging.handlers   
import distutils  
from distutils import dir_util  

logger = logging.getLogger('ssh_audit')  
logger.setLevel(logging.WARNING)  
hdlr = logging.FileHandler('/var/log/ssh_audit.log.dup')  
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')  
hdlr.setFormatter(formatter)  
logger.addHandler(hdlr)  
logger.warning('Authorized Key for host {0} and user {1} was   reloaded'.format(host, user[2]))``  

### Python openstackclient queue bug  
error:
``openstack server list
..
File "/opt/mcs_venv/lib/python2.7/site-packages/openstack/utils.py", line 13, in <module>
  from multiprocessing import queue
ImportError: cannot import name queue``  
fix:  
``pip install openstacksdk==0.35.0 #faulty versions are ~0.40+``  

### Python openstackclient v1.contrib cinder bug  
error:  
``openstack server create
...
 File "/opt/mcs_venv/lib/python2.7/site-packages/osc_lib/clientmanager.py", line 47, in ...
make_client
    from cinderclient.v1.contrib import list_extensions
ImportError: No module named v1.contrib
``  
fix:  
``pip install python-cinderclient==4.3.0``  

### uniq lines  
``os.system("awk '!x[$0]++' /var/log/ssh_audit.log.dup >   /var/log/ssh_audit.log")   
``
### Java workarounds (jre8)  
1. start 'configure java' app
2. security - high level - edit security list - insert website url  
3. If you get 'unable to launch app' err message - click details  
in case of MD5RSA algorithm rejection edit with notepad file  
``/c/program files/java/jre8.../lib/security/java.security``  
and remove this algorithm from all 'disable' lines  

## ClickHouse CentOS  
DO NOT use official yandex repo - its garbage.  
Instead, use altinity repo:  
``[altinity_clickhouse]
baseurl = https://packagecloud.io/altinity/clickhouse/el/7/$basearch
enabled = 1
gpgcheck = 0
gpgkey = https://packagecloud.io/altinity/clickhouse/gpgkey
name = Altinity ClickHouse Repo``  


### Echo pipeline over SSH  
`` echo 'string' | ssh ubuntu@10.1.3.3 "cat >> /target/file"``  

### Simulate Low load on server (1M file)   
``while true; do rsync --bwlimit=1000000 /usr/local/bin/node_exporter lold; sleep 2; done``    

### Check internet speed in cli (via speedtest.com by ookla)  
``curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -``  

### Stupid situation around include/python.h  
error: #include "python.h": No such file  
Go to /usr/include. where you have 2 dirs presumably -
python2.7 and python3.6  
map everything from python2.7:  
``ln -sv python2.7/* /usr/include/``  
### And same situation around virtualenv/multiprocessing etc
error:
``Modules/_multiprocessing/multiprocessing.h:6:20: fatal error: Python.h: No such file or directory
   #include "Python.h"
                      ^
    compilation terminated.``  
fix:
``cp -r /usr/include/python2.7/ /opt/venv/include/ #or ln -s if you prefer``  

### Check json from page (chrome)    
F12 -> Network -> Preserver log  

### Using rsync with append  
``rsync --append-verify SOURCE DEST``    

### Iptables basics  
flush rules  
``service iptables-persistent flush``  
print chains with line-numbers  
``iptables -nvL --line-numbers``  
delete rule by number and chain  
``iptables -D INPUT 3``  
prerouting to other port (if port 9090 is not accessible)  
``iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 9090``  
delete
``iptables -t nat -D PREROUTING 1``  
list
``iptables -L -n -t nat --line-numbers``  

### Tarantool basics
connect  
``tarantoolctl connect /var/run/tarantool/tarantool-storage.<instance-name>.control
require('membership').members()``  

### OpenStack high memory usage  
- decrease number of workers in services confs  
- decrease number of processes/threads in /etc/uwsgi/..  

### NodeJS webserver
``apt-get install -y nodejs npm nodejs-legacy  
npm install -g http-server  
http-server -p 81``  

### ASCII with CRLF terminators, removing CRLF  
``vim filename  
:set fileformat=unix  
:wq``  

### MYSQL consistent backup & restore  
``mysqldump --all-databases --single-transaction > all_databases.sql  
mysql -p < all_databases.sql``  

### MYSQL reboostrap failed cluster  
``mysql -e "SET GLOBAL wsrep_provider_options='pc.bootstrap=yes';"``  

### MySQL restore root privileges or password  
``systemctl stop mysql
mysqld_safe --skip-grant-tables &
mysql
UPDATE mysql.user SET Grant_priv='Y', Super_priv='Y' WHERE User='root';
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';
#OR
UPDATE mysql.user SET Password=PASSWORD('NEW-PASSWORD') WHERE User='root';
FLUSH PRIVILEGES;
SHUTDOWN;``  

### Mysql create remote user with perm  (kolla example)  
``docker exec -it mariadb mysql -uroot -ppassw0rd
CREATE USER 'ha'@'localhost' IDENTIFIED BY 'passw0rd';
CREATE USER 'ha'@'%' IDENTIFIED BY 'passw0rd';
GRANT ALL ON *.* TO 'ha'@'localhost';
GRANT ALL ON *.* TO 'ha'@'%';``  
check  
``docker exec -it mariadb mysql -uha -ppassw0rd``  

### Fuel plugins - Add version: 2.0.0 in deployment_tasks via VIM  
``'%s/^\s&ast;role: .&ast;/  version: 2.0.0\r&/g'``  

### Check missed packages on interfaces  
 ``ip -s -s link show``  

### Debug resource start via pcs  
``pcs resource debug-start``  

### check buffers:  
``ethtool -g``  

### set up maximum buffer for Nic  
``ethtool -G  rx``    
add this change to script - (RHEL)  
vim   /etc/sysconfig/network-scripts/ifcfg-NIC  
``ETHTOOL_OPTS="-G  rx <buffer size>"``    
### !!!Changes to Tx buffer are not recommended because of devices on other side of link  

### Check crm disk status  (full disk)  
``crm node status-attr  show "#health_disk"      
delete flag  
crm node status-attr node01.local delete "#health_disk"``      

### Recursive sed replacement in files  
``find . -type f -exec sed -i 's/foo/bar/g' {} +``  

### Recursive cut/execute  
removing logs with date  
``find /home/debian/backups/mongodb_*  -mtime +31  -exec rm {} \;``  
or
``find $i -type f -name *.log -exec cp /dev/null {} \;``  
or create script and execute it  
``find $i -type f -name *.log -exec script;``  
or use arguments  
``find ./ -type f -exec grep -iHf ~/patterns.txt  {} + > ~/<log_destination>/username.txt``    

### Recursive Disk Usage  
``du -h --max-depth=1 /var/log | sort -hr``  
### WIFI connection password  
vim /etc/NetworkManager/system-connections/conn_name.conf  
``[wifi security]  
psk =``  

### Creating patches  
``diff -Naur oldfile newfile >new-patch``  

### Disabling cloud-init datasource search  
``echo 'datasource_list: [ None ]' | sudo -s tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg``  
### Disabling service via update-rc.d  
``update-rc.d drbd disable``  

### Broadcast message in console  
``wall _message_``  

### Enabling corosync autostart  
vim /etc/default/corosync  
``change NO on YES``  

### Git insecure certificates  
``git config http.sslVerify false``
or  
`` export GIT_SSL_NO_VERIFY=1``  
or  
``git -c http.sslVerify=false clone https://example.com/path/to/git``    


### Git change git scheme to https  
`` git config --global url."https://".insteadOf git://``  

### Stash /unstash git
``git stash #hide files
git stash pop #undo``

### Git remove binary files  
``git log -p | grep ^Binary
#paste all needed names in fl_del files
fls=$(awk '{print $1}' ../fl_del | sort -u | tr '\n' ' ')
for i in $fls; do git filter-branch --force --index-filter "git rm -rf --cached --ignore-unmatch $i" HEAD --all; done
git push --force origin --all
``

### Using deprecated branches  
``git checkout kilo-eol``  

### Repush tag  
Delete and push:  
``git checkout v1.1.0
git add -A
git commit -m "something"
git tag -d v1.1.0
git tag v1.1.0
git push origin v1.1.0 -f``  

### Weird login after pushing  
Presumably, you have a wrong email in git global config.
Push strategy = simple also could help  
``git config --global  -e
git config --global push.default simple``  

### Enable password cache in git store  
``git config credential.helper cache``  

### Submitting existing repository in new gerrit repo  
``git clone $repo-from-stash  
cd $repo  
git checkout $branches #creating branches  
git remote add gerrit $gerrit-repo  
for i in {1000..1}; do echo $i; git reset --hard HEAD~$i; if [[ $? == 0 ]]; then break; fi;  done #searching for first commit for squashing  
git merge --squash HEAD@{1}    #squashing  
git commit  
git pull gerrit $branch     #fetching repo to common ancestor  
git-review #Voila!``  
repeat all steps for all branches   

### Sed all files in dir  
``find . -type f -print0 | xargs-0 sed -i 's/str1/str2/g'``  

### FC scsi bus rescan  
``echo 1 > /sys/class/fc_host/host#/issue_lip``  
or apt install sg3_utils SCSI bus rescan  
``echo “- - -” > /sys/class/scsi_host/hostH/scan``  
or (working on fuel/vsphere)  
``ls /sys/class/scsi_device/  
2:0:0:0  3:0:0:0  
echo 1 > /sys/class/scsi_device/2\:0\:0\:0/device/rescan    
echo 1 > /sys/class/scsi_device/3\:0\:0\:0/device/rescan``  

### Drop vm cache  
``echo 3 > /proc/sys/vm/drop_caches``  

### Identify wwn of fc card  
``cat /sys/class/fc_host/hostX/device/fc_host/hostX/node_name``  

### Find deb package by filename  
``dpkg -S file.name``  

### Find rpm package by filename  
``rpm -qi --filesbypkg $package``  

### QCOW2 to VMDK openstack convertation  
``qemu-img create -O vmdk -o adapter_type=lsilogic,compat6 ubuntu.qcow2 ubuntu.vmdk``  

### How to avoid drbd "start mounting" / "start daemon" race condition  
vim /etc/network/if-up.d/drbd-start  
``#! /bin/sh  
/etc/init.d/drbd start``  
vim /etc/fstab  
``/dev/drbd1 /home ext3 _netdev,relatime 0 2``  

### Openstack keepalived vip in instances  
1. create new neutron port  
2. install keepalived, configure (Search by tag keepalived on this site)  
3. ``neutron port-update  $vm1_portid --allowed-address-pairs type=dict list=true   ip_address=VIP,mac_address=mac1 ip_address=vm_ip1,mac_address=mac_vm1``    
4. ``neutrom port-update $vm2_portid --allowed-address-pairs type=dict list=true   ip_address=VIP,mac_address=mac_vm2 ip_address=vm_ip2,mac_address=mac_vm2``  
5. Open ICMP rule in security group  
6. start keepalived, check connectivity  

### Keepalived scripts not working  
vrrp_script definition must be declared ABOVE(!!!IMPORTANT!!!) vrrp_instance. It will not work in any other case.   

### Install simple VM via virsh  
``qemu-img create -f qcow2 /var/lib/libvirt/images/cloud-linux.img 15G   
virt-install --connect qemu:///system --hvm --name cloud-linux --ram 1548 --vcpus 1 --cdrom path_to_iso --disk path=/var/lib/libvirt/images/cloud-linux.img,format=qcow2,bus=virtio,cache=none --network network=default,model=virtio --memballoon model=virtio --vnc --os-type=linux --accelerate --noapic --keymap=en-us --video=cirrus --force``  

### Issue with virt-sparsify on late kernel 4.40 (kernel panic)  
1. https://bugs.launchpad.net/ubuntu/+source/supermin/+bug/1743300/comments/11  
2. Download kernel packages 4.10.0-20..42 in Dir  
3. export variables like its done in 1743300 bug  

### LXC containers  
Serious bug:  
on boot of multiple lxc containers, source bridge will get MAC from random container, and after that, Min MAC ADDRESS among container interfaces.  
To prevent it you should put option   
``hw_bridge MACADDRESS``  
in source bridge interfaces config.  

### Samba create share  
``useradd sambashare   
passwd sambashare  
apt -y install samba samba-client  
smbpasswd -a sambashare``    

cat /etc/samba/smb.conf  
``[global]  
    workgroup = SAMBA  
    security = user  
    passdb backend = smbpasswd  
    kernel share modes = no  
    kernel oplocks = no  
    map archive = no  
    map hidden = no  
    map read only = no  
    map system = no  
    store dos attributes = yes  
[annual-reports]  
   comment = For testing a Gluster volume exported through CIFS  
   path = /opt/annual-reports/  
   read only = no  
   guest ok = yes  
service samba restart``   


### Windows7 doesnt use hosts file  
_Solution by Wol_[Beware if spacing in windows 7 hosts file](http://geekswithblogs.net/JanS/archive/2009/06/17/beware-of-spacing-in-windows7-hosts-file.aspx)  
1. cd \Windows\System32\drivers\etc ###go to the directory where the hosts file lives  
2. attrib -R hosts ###just in case it's Read Only, unlock it  
3. notepad hosts ###now you have a copy of hosts in Notepad  
4. del hosts ###yep. Delete hosts. Why this is necessary -- why ANY of this should be necessary -- I have no clue  
5. Now go into Notepad and Ctrl-S to put the hosts file back. Note: Ctrl-S should save it as "hosts" without any extension. You want this. Be sure not to let Notepad save it as "hosts.txt"  
6. ipconfig /flushdns --possibly unnecessary, but I did it this way and it worked  
7. attrib +R hosts --make hosts file Read Only, which adds as much security as you think it does  

### Windows get sorted diskusage in directory (powershell)  
``$startDirectory = 'E:\MSSQL\Backups\'
$directoryItems = Get-ChildItem $startDirectory | Where-Object {$_.PSIsContainer -eq $true} | Sort-Object
 foreach ($i in $directoryItems)
{
    $subFolderItems = Get-ChildItem $i.FullName -recurse -force | Where-Object {$_.PSIsContainer -eq $false} | Measure-Object -property Length -sum | Select-Object Sum
    $i.FullName + " -- " + "{0:N2}" -f ($subFolderItems.sum / 1GB) + " GB"
}``  

## Postgresql Pgpool Patroni  
Reload postgres  
``sudo su postgres;  pg_ctlcluster 9.6 main reload``  

Create test base and user with pass  
``sudo su postgres;  create database testhba;create user tst with encrypted password 'mypass';grant all privileges on database testhba to tst;``  

Check recovery nodes  
``sudo -u postgres psql -h 172.21.3.41 -p 5432 -x -c "show pool_nodes;"  
sudo -u postgres psql -h 172.21.3.229 -p 5432 -x -c "select pg_is_in_recovery();"``  

List clusters  
``export PATRONI_ETCD_HOST=localhost:2379  
patronictl list psql_cluster``  

Change postgres parametrs cia etcd in patroni:  
``etcdctl ls --recursive -p | grep -v '/$' | xargs -n 1 -I% sh -c 'echo -n %:; etcdctl get %;'
etcdctl set /service/psql_cluster/config '{"ttl":30,"maximum_lag_on_failover":1048576,"retry_timeout":10,"postgresql":{"use_pg_rewind":true,"parameters":{"max_connections": 1500}},"loop_wait":10}'``  

### More ETCD cli  
``export ETCDCTL_API=3; etcdctl --endpoints=https://$(hostname -i):2379 --cacert=/etc/etcd/ca.pem --cert=/etc/etcd/kubernetes.pem --key=/etc/etcd/kubernetes-key.pem member list``  

### Testing LB  
``sudo -u postgres pgbench -i  
sudo -u postgres pgbench -p 5432 -h pgpool_vip -c 10 -S -T 10 postgres  
sudo -u postgres psql -p 5432 -h pgpool_vip -c "show pool_nodes" postgres``  

### PCP commands  
``pcp_node_count -h /var/run/postgresql -p 9898  
pcp_attach_node -h /var/run/postgresql -p 9898 0 (return node after reboot)``  

### Mcollective  
Some mcollective useful commands  
``mco rpc -v excurte_shell_command execute cmd="shotgun2 short-report" -I master``  

## Cisco   
### Monitoring in console  
``term mon``  

### Check link   
_on server_  
``ifconfig interface up``    
_on switch_  
``show status int eth1/1``   

### Check interface status: show interface status  
``Grep: | include ....``    
_Check config_  
``show run conf | inc``  

### qemu  
Inspect qcow2 image  
``qemu-img convert name.qcow2 name.raw  
parted name.raw  
unit B  
print  | determine offset  
mount -o loop,offset=1048576 cfg01-day01-2018.4.0.raw /opt/mount/  
``  


## Cisco LACP  
_cdp vpc_  
1. enable cdp  
2. enable vpc  
3. create vpc domain  
4. configure keepalive dest mgmt-ip-peer source mgmt-ip    
5. create portchannel group LACP mode active  
6. feature lacp  
TRUNK  
7. configure if-range  
8. spanning tree  
9. assign if-range to portchannel   

Example  
``eth1809-3: conf t  
eth1809-3(config): interface port-channel 1  
eth1809-3(config): negotiate auto  
eth1809-3(config): vpc 1  
eth1809-3(config): switchport mode trunk  
eth1809-3(config): exit  
eth1809-3(config): interface eth1/1  
eth1809-3(config): no sh  
eth1809-3(config): switchport mode trunk  
eth1809-3(config): channel-group 1 mode active  
eth1809-3(config): exit  
eth1809-3(config): wr``  

### Enable Jumbo frames  
``cz-eth1809-3(config)# policy-map type network-qos jumbo  
cz-eth1809-3(config-pmap-nq)#   class type network-qos class-default  
cz-eth1809-3(config-pmap-nq-c)#           mtu 9216  
cz-eth1809-3(config-pmap-nq-c)# system qos  
cz-eth1809-3(config-sys-qos)#   service-policy type network-qos jumbo``  

### Kakfa /zookeeper  
Get topics from remote zookeeper via kafka  
``cd /opt/kafka/*/
bin/kafka-topics.sh --list --zookeeper 10.0.1.45:2181``  

## Vmware/vsphere  
### Port security configure  
1. Hosts  
2. Host  
3. Configure  
4. Networking  
5. vswitch edit  
6. Disable all security checkbox  


### Disconnected /deactivated datastore  
``Check your license first``    

### Influxdb openstack access  
1. find astute.yaml, and values  influxdb_dbname, influxdb_username, influxdb_userpass and in vips section -  vips>influxdb>ipaddr
2. access database
``influx -host IPADDR -username INFLUXDB_USERNAME -password INFLUXDB_USERPASS -database INFLUXDB_DBNAME  
precision rfc3339  
SHOW MEASUREMENTS
SHOW DIAGNOSTICS  
SELECT * FROM node_status GROUP BY * ORDER BY DESC LIMIT 1  
SHOW FIELD KEYS FROM virt_memory_total``  
3. If there is no metrics in influx you can try to restart  heka/hindsight on nodes with kafka:  
``ps aux | grep heka;  for i in $dddd; do kill -9 $i; done``  

### Influx cache maximum memory size exceeded 6109  
_Sample from logs_  
``14:52:07 reading file /data1/influxdb/wal/sysnoc/default/2/\_00703.wal, size 10504926 [cacheloader] 2016/03/24 14:52:09 reading file   /data1/influxdb/wal/sysnoc/default/2/\_00704.wal, size 10494123 run: open server: open tsdb store: [shard 2] cache maximum memory size exceeded``  

Solution  
vim tsdb/engine/tsm1/cache.go  
``@@ -306,6 +306,12 @@ func (c &ast;Cache) Delete(keys []string) {  
       }   
   }   

+func (c &ast;Cache) SetMaxSize(size uint64) {  
+    c.mu.Lock()  
+    c.maxSize = size  
+    c.mu.Unlock()  
+}  
+``  
vim tsdb/engine/tsm1/engine.go  
``@@ -659,6 +659,14 @@ func (e &ast;Engine) reloadCache() error {  
         return err  
     }  

+    limit := e.Cache.MaxSize()  
+    defer func() {  
+        e.Cache.SetMaxSize(limit)  
+    }()   
+  
+    // Disable the max size during loading  
+    e.Cache.SetMaxSize(0)  
+  
     loader := NewCacheLoader(files)``  
restart influxdb  
``service influxdb restart``  

## Haproxy  
If haproxy cannot start on all nodes after deployment ('cannot bind soc' after /usr/lib/ocf/resource.d/fuel/ns_haproxy reload), check this nonlocal_bind bug   
[bug](https://bugs.launchpad.net/fuel/+bug/1659205)

Solution  
``ip netns delete haproxy  
/usr/lib/ocf/resource.d/fuel/ns_haproxy start  
crm resource cleanup clone_p_haproxy``  

### Haproxy ssl  
Enabling tls on grafana  
``scp kibana.lma.mos.cloud.sbrf.ru.chain.pem kaira6:/var/lib/astute/haproxy/``  
vim /var/lib/astute/haproxy/kibana  
``bind 10.127.32.37:80  
bind 10.127.32.37:443 ssl crt /var/lib/astute/haproxy/kibana.lma.mos.cloud.sbrf.ru.chain.pem no-sslv3 no-tls-tickets ciphers AES128+EECDH:AES128+EDH:AES256+EECDH:AES256+EDH  
balance source  
option forwardfor  
option httplog  
reqadd X-Forwarded-Proto:\ https  
stick on src  
stick-table type ip size 200k expire 30m  
timeout client 3h  
timeout server 3h``  

Grafana  
``bind 10.127.32.37:80  
bind 10.127.32.37:443 ssl crt   /var/lib/astute/haproxy/grafana.lma.mos.cloud.sbrf.ru.chain.pem no-sslv3 no-tls-tickets ciphers AES128+EECDH:AES128+EDH:AES256+EECDH:AES256+EDH  
balance source  
option httplog  
option httpchk GET /login/ HTTP/1.0  
reqadd X-Forwarded-Proto:\ https  
stick on src  
stick-table type ip size 200k expire 30m``  
DELETE this line  
``option forwardfor``  

## Swift  
### Swift with Ceph - troubleshooting  
Kraken release, error: NO_SUCH_BUCKET/ACCOUNT/404  
1. Verify your endpoints, (they should contain :8080/swift/v1/%(tenant_id)s postfix)   
2. Check your ceph.conf    
``[client.radosgw.gateway]  
rgw keystone api version = v2.0  
rgw keystone url = http://192.168.0.2:35357  
rgw_keystone_admin_token = P.......iu.f..  
rgw swift account in url = true  
rgw keystone implicit tenants = false``  
3. restart all radosgw services on all radosgw nodes  
``service radosgw-all restart``  

## GOlang

### Get started  
insert in the end of /root/.profile   
``export GOROOT=/usr/local/go
export GOPATH=$HOME/GoProjects
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH``  
Get Go  
``cd /opt/
wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
tar -xzf go1.13.1.linux-amd64.tar.gz
mv go /usr/local
export GOROOT=/usr/local/go
mkdir $HOME/GoProjects
export GOPATH=$HOME/GoProjects
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH``  

Make test repo  
``mkdir -p $HOME/GoProjects/src/github.com/user/hello``  
vim $HOME/GoProjects/src/github.com/user/hello/hello.go  
``package main
import "fmt"
func main() {
    fmt.Printf("hello, world\n")
}``  
Setup env variables, check version and compile hello app  
``source /root/.profile  
go install github.com/user/hello
go version
$GOROOT/bin/hello``  
That's it!

### Problems  
1. Clone repo - go get github/user/repo (alternatively, you can manually clone repo in gopath:/src/ dir )  
2. In case of problems with goroot/gopath - unset GOROOT variable  
3. In case of problems with http.requests&ast; (or context) calls - update GOlang to >1.8.3  
4. Find all dependencies for package:  
     ``go list -f '{{join .Deps "\n"}}''``  
5. 'import cycle not allowed' - unset all GO variables, and run  
``go get github/user/repo``  


## SSL  
Generate right self-signed certs  
``openssl req -x509 -newkey rsa:4096 -keyout kibana-lol.it.com.pem -out  kibana-lol.it.com.cert -days 365 -nodes  
echo  kibana-lol.it.com.cert >> kibana-lol.it.bundle  
echo  kibana-lol.it.com.pem  >> kibana-lol.it.bundle``  

P7B windows to x509 cert  
``openssl pkcs7 -inform der -in certnew.p7b -out a.cer
openssl pkcs7 -print_certs -in a.cer -out certnew.crt``   

Version 2 - with CA and AltSubjectName  (CentOS)   
First of all, copy and made these changes to openss.cnf  
``cp /etc/pki/tls/openssl.cnf ./``  
vim openssl.cnf  
``req_extensions = v3_req  
[ v3_req ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = harbor.example``  
Next, made rootca key, crt, csr, and generate certs and keys  
``openssl genrsa -out rootCA.key 4096  
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt
openssl genrsa -out harbor.example.key 2048
openssl req -new -sha256 -key harbor.example.key -subj "/C=RU/ST=MS/O=ITkey, LTD./CN=harbor.example" -reqexts v3_req -config ./openssl.cnf -out harbor.example.csr  
openssl req -in harbor.example.csr -noout -text
openssl x509 -req -days 365 -in harbor.example.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -CAserial serial_numbers -out harbor.example.crt -extensions v3_req -extfile ./openssl.cnf``  
Validate cert/key/SAN  
``openssl rsa -noout -modulus -in harbor.example.key | openssl md5
openssl x509 -noout -modulus -in harbor.example.crt | openssl md5  
openssl x509 -in harbor.example.crt -text -noout  
``
Add certificates to trusted (centos)
``yum install ca-certificates
update-ca-trust force-enable
cp jenkinsRootCA.crt /etc/pki/ca-trust/source/anchors/ #pay attention to .crt "extension"
update-ca-trust extract
``
Check that rootCA in bundle
``awk -v cmd='openssl x509 -noout -subject' ' /BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-bundle.crt
``

### Gitlab SSL
Create ssl dir in configs/ dir, copy certificates there
and change externla_url in configuration, i.e
``mkdir /srv/gitlab/config/ssl #docker
cp gitlab.mb.com.key gitlab.mb.com.crt /srv/gitlab/config/ssl/
>vim /srv/gitlab/config/gitlab.rb
external_url 'https://gitlab.mb.com'
docker restart gitlab
``

### Certbot let-s encrypt manual DNS verification and renewing   
``add-apt-repository ppa:certbot/certbot  
  apt-get install python-certbot-nginx  
  certbot certonly --manual -d DOMAIN1 -d DOMAIN2 -d DOMAIN3 --preferred-challenges dns``  
  After that, text to guy that is responsible for dns challenges for certbot  


### Jenkins ssl (Docker)  
``docker exec -it -u root `docker ps | grep jenkins|awk '{print $1}'` bash  
openssl pkcs12 -export -in .crt -inkey .key -out jenkins.p12  
keytool -importkeystore -srckeystore jenkins.p12 -srcstoretype PKCS12 -destkeystore jenkins_keystore.jks -deststoretype JKS  
keytool -list -v -keystore jenkins_keystore.jks | egrep "Alias|Valid"  
docker run -v /home/ubuntu/johndoe/jenkins:/var/jenkins_home -p 443:8443 jenkins --httpPort=-1 --httpsPort=8443 --httpsKeyStore=/var/jenkins_home/jenkins_keystore.jks --httpsKeyStorePassword=``  

### Ssl root ca cert add  
``mv cacert.crt /etc/ssl/certs/``  

### Check a certificate  
``openssl x509 -in certificate.crt -text -noout``  
or  
``openssl x509 -noout - hash - in cacert.crt``  

### Openstack ca-bundle right order (hosttelecon)  
1. crt      
``Issuer: C=GB, ST=Greater Manchester, L=Salford, O=COMODO CA Limited, CN=COMODO RSA Domain   Validation Secure Server CA  
Subject: OU=Domain Control Validated, OU=EssentialSSL Wildcard, CN=&ast;.atlex.cloud``  
2. Bundle  
2.1
``Issuer: C=GB, ST=Greater Manchester, L=Salford, O=COMODO CA Limited, CN=COMODO RSA   Certification Authority  
Subject: C=GB, ST=Greater Manchester, L=Salford, O=COMODO CA Limited, CN=COMODO RSA Domain   Validation Secure Server CA``  
2.2  
``Issuer: C=SE, O=AddTrust AB, OU=AddTrust External TTP Network, CN=AddTrust External CA Root  
Subject: C=GB, ST=Greater Manchester, L=Salford, O=COMODO CA Limited, CN=COMODO RSA   Certification Authority``  
3. RSA Key  

### SSL Sparc Oracle  
Verify  
``openssl x509 -noout -text -in Elbonia_Root_CA.pem``    
Chmod  
``chmod a+r Elbonia_Root_CA.pem      
cp -p Elbonia_Root_CA.pem /etc/certs/CA/``  
Insert the cert in the end of file _/etc/certs/ca-certificates.crt_  
Hash  
``c_rehash .``  
link  
``/usr/sbin/svcadm restart /system/ca-certificates``  
``update-ca-certificates``  

### Fuel postdeploy ca add  
1. Add cert in UI  
2. ``fuel node --node $i --tasks upload_configuration``    
3. ``fuel node --node $id --tasks $ssl_tasks $haproxy-service-tasks $keystone-service-tasks``    
4. Profit    

### why curl is working but clients are not  
Python-requests looks into /etc/ssl/certs/ , but right after installation _certify_ looks into  
``/usr/lib/python2.7/dist-objecti/certifi/bundle``  
This bundle doesn't include self-signed certificates so it maybe the case why clients couldn't work with your certificates.  
Another thought. You  can append your certificate to ca_certificates.crt and run  
``update-ca-certificates``  
As last resort u can check your chain one more time - maybe you have there bundle's open part while it should not be there.  

## LDAP  
### ldap 2 less  
``ldapsearch -x -LLL -h ****.ru -p 3268 -D openstack_ldap_user@*****.ru -w 'D*****2%$******X5(' -b DC=ti,DC=local -s sub "(sAMAccountName=a.sh******)" -P 3 -e ! chaining=referralsRequired``  
``ldapsearch -x -LLL -h 127.0.0.1 -p 389 -D cn=administrator,dc=local,dc=ru -w BNkmv/OEt+z1su_g_A_p_q_PjO6uA1C1 -b dc=***********,dc=ru -s sub "(sAMAccountName=a.*****ev)"``  
itkey
``ldapsearch -x -D 'cn=name,ou=Service Accounts,ou=IT,ou=IT Key Services,dc=dom,dc=loc' -w 'pass' -H ldap://ip -b "ou=IT Key Services,dc=dom,dc=loc"``  
sk  
``ldapsearch -L -H ldap://ip -x -D 'domain\user' -w "pass" -b 'OU=Users,OU=Foundation,DC=dom,DC=local' '(&(objectCategory=person)(objectClass=*)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))' '(uid: sAMAccountName)'``  - not sure about 1.2.840 part  

## Python using ssl verify cert  
``import requests  
url = 'https://foo.com/bar'  
r = requests.post(url, verify='/path/to/ca')``  
or with urllib3  
``import urllib3
http = urllib3.PoolManager(ca_certs='/etc/ssl/certs/ca-certificates.crt')
r = http.request('GET', 'https://xcloud.x5.ru/marketplace_templates/')
print(r.data)``  

## Zabbix  
### mariadb-mysql  

1. Persistent change of allowed connections   
``vi /etc/my.cnf.d/server.cnf``  
2. Permanent change
``mysql -u root -p; show variables like 'max_connections'
set global max_connections = 1000;``
3. Check _/usr/lib/systemd/system/mariadb.service_  
sudo vi /etc/systemd/system/mariadb.service  
``.include /lib/systemd/system/mariadb.service  
[Service]  
LimitNOFILE=10000  
LimitMEMLOCK=infinity``  
3. Agent timeouts  
vi /etc/zabbix/zabbix-server.conf   
``Timeout 30;``  
4. Poller busy  
vi /etc/zabbix/zabbix-server.conf  
``StartPollers=200;``  
5. Manual integration  
``install agents (wget)  
place scripts in /etc/zabbix/scripts   
Fill _server serveractive userparameters_ options in /etc/zabbix/zabbix-agent.conf  
Log in webui, setup autodiscovery of agents  
Import templates  
Link them on group of nodes``  
Full [post]({{ "/_posts/2017-10-12-zabbix.md" }})  

## Fuel master, docker  
### issues  
jenkins/jenkins image    
1. no running docker daemon/  
solution  
``apt install docker-engine (1.12. if using rancher)``
2. error "cannot connect to docker daemon" during jenkins pipelines/  
solution  
``chmod 777 /var/run/docker.sock in jenkins container``  

### Remove node from db with preventing from pxe boot (cobbler)  
Backup Fuel PostgreSQL databases:
``docker exec –it $id_psql bash
su – postgres
pg_dumpall > dump_date.sql
exit
docker cp $id:/var/lib/pgsql/dump_….sql ./``  
Dump cobbler node vars:  
``docker exec –it $id_cobbler bash
cobbler system dumpvars --name app-strg-05.name.com >> cobbler_vars_strg_05``  

Removing node from Fuel PSQL DB:
``fuel node –node $id –force –delete-from-databases``  

Creating cobbler system for node (preventing bootstrap)  
``fuel exec –it $id_cobbler
cobbler system add --name app-strg-05.name.com --profile ubuntu_1404_x86_64
cobbler system edit --name app-strg-05.name.com --ip-address=PXE_IP --interface=$INTERFACE --mac=MAC --netmask=255.255.255.0 --static=0 --netboot-enabled=False``  
Repeat edit command for every device:  
``cobbler system edit --name app-strg-05.name.com --interface=$INTERFACE --mac=MAC --netmask=255.255.255.0 --static=0 --netboot-enabled=False``  
Test: Reboot node. It should skip bootstrap section (and therefore fuel “discover” state in UI)   

## HELM  
### Installing heapster + grafana + prometheus on kubespray v2.4.0  
``helm -n kube-system --name heapster install --set rbac.create=true stable/heapster   
kubectl -n kube-system get po | grep dashboard ; kubectl delete po $name``    
``helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/  
helm install coreos/prometheus-operator --name prometheus-operator --namespace monitoring  
helm install coreos/kube-prometheus --set global.rbacEnabled=true --name kube-prometheus --namespace monitoring  
helm install -n monitoring --name grafana --set auth.anonymous.enabled=false --set adminUser=admin --set adminPassword=admin --set ingress.enabled=true --set ingress.hosts[0]=grafana.dev.cool.ru  coreos/grafana``  
Go after that in grafana, and change corresponding prometheus datasource   (should be http://kube-prometheus-prometheus:9090)  
Also you need to disable tls in kube-prometheus-exporter-kubelets (if you are experiencing prometheus 401 errors in kubelets), so just go and edit  
``kubectl -n monitoring edit servicemonitor kube-prometheus-exporter-kubelets``  
and if you are usint kubelets-exporter  
``kubectl -n monitoring edit servicemonitor exporter-kubelets``

### get current context  
``kubectl config get-contexts``  

## Rancher  
### bugs  
1. if you are experiencing some net-shit (like no bridge-net failures, empty json response and so)
mb your rancher-agent which runs on rancher-server host has got a wrong ip (docker ip 172...)
Solution  
go to rancher-server node, run on host command 'export CATTLE_AGENT_IP=$ip' and then readd host'
2. If you delete kubernetes stack in rancher and recreate it and your new stack constantly fails, when you should manually remove volumes from vms on which k8s stack based (/var/lib/docker ....).  Main reason for this is that we need purge old config data form etcd volumes.    
## Docker  
### Push limage to remote registry  
``docker login nexus.example.com:18444  
docker build .  
docker tag af340544ed62 nexus.example.com:18444/hello-world:mytag   
docker push nexus.example.com:18444/hello-world:mytag``    
If nothing happens  
vim /etc/docker/daemon.json  
``{ "insecure-registries":["myregistry.example.com:5000"] }   
/etc/init.d/docker restart``  

### basic docker cmd  
``1. dockerctl list  
2. dockerctl check   
3. dockerctl restart <contain.name>  
4. dockerctl backup / restore``  

### Delete all containers  
``docker rm $(docker ps -a -q)``    

### Delete all images  
``docker rmi $(docker images -q)``  

## Fuel  
### Change fuelmenu settings  
``./bootstrap_admin_node.sh``  

### Kernel update to 4.4 for Fuel 9.0   
``cp fuel_bootstrap_cli.yaml fuel_bootstrap_cli.yaml.bak  
sed -i -e 's/generic-lts-trusty/generic-lts-xenial/g' \
  -e '/-[[:blank:]]&ast;hpsa-dkms$/d' fuel_bootstrap_cli.yaml  
fuel-bootstrap build --activate --label bootstrap-kernel44``  

### Fixing fake disks issue on discover nodes  
(unsquah /squah active bootstrap, and add new line with Container)  
https://git.openstack.org/cgit/openstack/fuel-nailgun-agent/commit/?id=13fb4009d3f7c46222791bb9623cb05f8ba42ad8  
``mdraid mdadm``  

### Plugin sync and graph  
vim /var/www/nailgun/plugins/plugin_name/...  
``fuel plugins --sync  
fuel graph --env env_id | grep task``  

### Fuel disable/enable plugins for removing from env  
``fuel --env 1 settings -d  
fuel --env 1 settings -u -f``  

### Fuel rsync library  
``fuel node --node 1 --start rsync_core_puppet --end plugins_rsync``  

### Puppet dir for plugins on master-node (7)  
``/var/www/nailgun/plugins``  

### Removing plugin with 'syntax error near fi' error  
``rpm -e --noscripts $package_name  
If there no active connection to nailgun in gui (7.0)  
and docker cannot check status of containers due to empty pass creds, do:  
1. cp /etc/fuel/astute.yaml.old /etc/fuel/astute.yaml  
2. dockerctl check all``  

### Controller+compute fix  
``fuel role --rel 2  --role controller  --file 1.yaml``  
vi 1.yaml  
``Conflicts: []``  

``fuel role --rel 2  --update --file 1.yaml``  
In UI network settigns -> l3 -> enable DVR  

### Change hostnames for all nodes  
``fuel node | grep -E "^(\ )&ast;[0-9]" | awk '{print $1,$5}' | while read id hostname; do   fuel node --node-id $id --hostname $hostname; done``  

### Fuel-graph  
``fuel graph --download file.dot``    
open this .dot in OmniGraffle Or GraphViz  

### Bugs  
0. Mcollective fail (last_run execution puppetd, yaml)
fix - delete
``/var/lib/puppet/state/last_run_summary.yaml  
/var/lib/puppet/state/last_run_report.yaml``  

1. 8th Fuel often cannot config rabbits container at start, and dont waiting for him
restart puppet apply in rabbitmq container  
``rabbit apply .... nailgun/examples/rabbitmq_only.pp``  
2. You MUST setup correct pxe settings  DURING deployment process of master node. To do so, you need to choose standart installation and after post-installation scripts and reboot press SPACEBAR when you will be prompted to 'press a key'  
3. If you want advanced installation you MUST specify your primary mac adress in bootloader option (press TAB while selecting advanced option and change XX:XX:XX:XX:XX on your mac)  
4. PXEe/admin network MUST have native vlan or nodes will not bootstraped through ubuntu_bootstrap image (cobbler:/var/lib/tftpboot/images/ubuntu_bootstrap)  
5. NO dots '.' in hostnames of controllers - or rabbitmq will fail (NX domain error)  
6. NO small partitions ( ~64 mb) in fuel node config  
7. After every reset of environment disks configuration also resets  
8. After 3 attemps of deploing task (puppet) task will fail, but deploying process will go further  
9. Dont use Qemu hypervisor - use KVM instead  
10. If you using local repo, u must run `fuel-mirror apply -G mos -P ubuntu` - or cloud-init module mcollective will not start and provisiong will fail  
11.  Another possible error after 100% provisiong and node reboot -
if you are using boot-volume it have 2 disks, at least. one small (64mb)
 and one primary. If your provisioning fails maybe its because cloud-init
cannot find it data_source on primary disk(beacuse its on small one).
In this case, use this workaround on nodes on discover phase:
dd if=/dev/zero of=/dev/vdb bs=1M count=64  
12. If you have more than one nodegroup you should check accordance between nodegroups and group_id of nodes or your deployment will like failed with non-understandable error in nailgun like '24' '22' 'gateway' and so.  

### RabbitMQ HA  
1. Queues should be durable and have ONLY 1 matching policy  
2. list non empty queues -
``rabbitmqctl list_queues name consumers messages -p /neutron  | awk -F' ' '$2!="0"'``  

## Elasticsearch and LMA  

## Influx  
### access and query  
``grep timestamp /var/log/influx.log  
log in influx  
use lma;  
Select .... from ... as as;``  

## Elasticsearch  
### check cluster status  
``curl localhost:9200/_cluster/health``  

### Delete old indexes  
vim /etc/elasticsearch/delete_indices.yaml  
``      value: "^log|events|notification.*$"  
        unit_count: 14``  
curator /etc/elasticsearch/delete_indices.yaml  

### figure out which indices are in trouble  
``curl 'localhost:9200/\_cluster/health?level=indices&pretty'``  

### figure out what shard is the problem  
``curl localhost:9200/\_cat/shards``  

### query to all objects  
``curl elastic_vip:9200/_all/compute.instance.exists/_search?
pretty=true&size=10000``  

### query to specific object (events_2017-06-26)  
``curl -XGET '$ES_URL/events_2017-06-26/snapshot.create/_search?pretty'``  

### query indices  
``curl 'localhost:9200/_cat/indices?v'``  

### query mappings  
``curl -XGET '$ES_URL/events_2017-06-26/\_mapping?pretty'``  

### lma_diagnostic  
`` sh lma_diagnostics``  

### check buffer    
``heka-cat -offset=48175879 /var/cache/log_collector/output_queue/elasticsearch_output/0.log | head -n 30``  

### to recover ES index, you can try  
``curl http://ES:9200/log-2016-11-15/_flush?force  
then run  
curl -XPOST 'http://ES:9200/_cluster/reroute'``  
If it's not working you can try to delete this indices  
``curl -XDELETE localhost:9200/log-2016-11-15``  

### checking logs  
``ls -l /var/cache/log_collector/output_queue/elasticsearch_output/  
cat /var/cache/log_collector/output_queue/elasticsearch_output/checkpoint.txt - check if its value is changing   
tail -n 30 /var/log/log_collector.log``  

### about idle packets messages  
this kind of messages (idle pack) are not critical as long as they are changing over the time (numbers of pack per plugin) this could mean that messages are "waiting" for some time to let processing other messages (backpressure in heka terminology)  

### increasing poolsize  can help in case of idle packets  
vim /etc/log_collector/global.toml  
``increase poolsize to 200  
crm resource restart p_clone-log_collector``  

### Python query for health status in case of curl timeout  
``from elasticsearch import Elasticsearch  
es = Elasticsearch()  
print(es.cluster.health(request_timeout=6000))``  

## Rally  
### One-node-deployment ib venv  
``wget -q -O- [https://raw.githubusercontent.com/openstack/rally/master/install_rally.sh](https://raw.githubusercontent.com/openstack/rally/master/install_rally.sh)  
chmod +x install_rally.sh  
./install_rally.sh -d venv``   
vi venv/samples/deployments/existing.json  
``rally deployment create --filename venv/samples/deployments/existing.json --name luxof``

### If you have multi region environment  
1) change two lines (search "region") here on hard-coded name of  your region  ``lib/python2.7/site-packages/rally/osclients.py#L196``   (and if you installed rally in venv in /venv/lib/python.....)
2) Also change line in neutron return in osclients.py  
``L357 client = neutron.Client(self..........   endpoint_override=self.\_get_endpoint(service_type))``  

### In case of multiple networks  
for every failed task do this  
vim /venv/src/sample/tasks/scenarios/nova/boot-and-delete.yaml  
``args:  
        flavor:....  
        image:.....  
        nics: [{"net-id": "id"}]``  

### Customize certification tests  
vi venv/src/certification/openstack/task_arguments.yaml  

``service_list:  
- authentication  
- nova  
- neutron  
- keystone  
- cinder  
- glance  
use_existing_users: false  
image_name: "^(cirros.&ast;uec|TestVM)$"  
flavor_name: "m1.tiny"  
glance_image_location: "/root/cirros-0.3.4-i386-disk.img" (Image must be there, you know)  
smoke: false  
users_amount: 30 (for test run you can use 1)  
tenants_amount: 10  
controllers_amount: 3  
compute_amount: 3  
storage_amount: 4  
network_amount: 3``  

vi venv/lib/python2.7/site-packages/rally/plugins/openstack/scenarios/nova/utils.py  
``line 112: def \_boot_server(self, image_id, flavor_id,  
auto_assign_nic=True, **kwargs)``  

vi src/certification/openstack/scenario/cinder.yaml  
``line 162: CinderVolumes.create_nested_snapshots_and_attach_volume
args:  
nested_level: 5``  

### Rally Start  

``rally task start rally.git/rally/certification/openstack/task.yaml --task-args-file rally.git/rally/certification/openstack/task_arguments.yaml``  

## Ceph Osd Rbd  
Legacy  
start osd via service:  
``start ceph-osd id=14``  
some fstab entries:  
``/dev/sdk3 /var/lib/ceph/osd/ceph-14 xfs rw,relatime,attr2,inode64,allocsize=4096k,logbsize=256k,noquota 0 0``  

### Ceph lockfiles (crushed instances filesystems after evacuation)  
Solution: add capability to issue osd blacklist commands to OS clients  
``ceph auth caps client.<ID> mon 'allow r, allow command "osd blacklist"' osd '<existing osd caps>'``  
list existing blacklist rules  
``ceph osd blacklist ls``  
Other related stuff  
``ceph tell mds.0 client ls
ceph tell mds.0 client evict id=4305
ceph tell mds.0 client evict client_metadata.=4305``  

### Ceph usefull flags during migraton / evacuation etc  
ceph set ..
``noout  
noin
nodeepsrubbing
noscrubbing
nobackfilling  
norebalance (on later versions)``  

### Decrease backfill  
``ceph tell osd.* injectargs '--osd-max-backfills 1'
ceph tell osd.* injectargs '--osd-max-recovery-threads 1'
ceph tell osd.* injectargs '--osd-recovery-op-priority 1'
ceph tell osd.* injectargs '--osd-client-op-priority 63'
ceph tell osd.* injectargs '--osd-recovery-max-active 1'``  

### Get current osd config  
``ceph -n osd.30 --show-config > 30.conf``  
### Get mon config  
``ceph daemon /var/run/ceph/ceph-mon.node01.asok config show``  

### Get mapping for image (pgs)  
``ceph osd map POOLNAME IMAGENAME``  

### Bash pipe to get Ceph backfill_toofull targets for every pg  
``ceph health detail | grep toofull | awk '{print $2}' | xargs -n1 -I {} ceph pg {} query | grep -1 backfill_targets``  

### Ceph get real usage of image
``rbd du $id``  
but it can take a lot of time  
As I heard from one guy, we can create script, that will use  
prefixes from 4MB object, count them and multiply by 4MB.  
This script should go in parallel and very fast, so GOlang is the best choice. Also, if you have shapshots it can be tricky, cause all changes after snapshotting go in some other place, not default map, and you need active fast-diff option, so you can use diff-iterate 2 operation.  

### Ceph tell  
`` ceph tell mon.* injectargs '--mon-allow-pool-delete=true'  
ceph tell osd.* injectargs '--osd_backfill_full_ratio 0.92'``  
Decrease deep-srubbing influence on environment  
Scheduling on night  
``ceph tell osd.* injectargs '--osd_scrub_begin_hour 0'  
ceph tell osd.* injectargs '--osd_scrub_end_hour 8'``    
Decrease chunk size for scrubbing  
``ceph tell osd.* injectargs '--osd_scrub_sleep .2'  
ceph tell osd.* injectargs '--osd-scrub-chunk-min 1'  
ceph tell osd.* injectargs '--osd-scrub-chunk-max 2'``  

higher -> slower recovery  (optimal are 1 for hdd, 0 ssd, 0.25 hybrid)   
``ceph tell 'osd.*' injectargs '--osd_recovery_sleep 0.5'``

### Ceph multiple backends / AZ  
1. Create 1 volume type with backend-name=ceph
2. Put backends in different AZ - dont sure how, probably via different ceph.confs / keyrings on compute nodes in both AZ
3. Create volume via openstack volume create --type ceph --az az1 OR --az az2

### Ceph replace osd (hammer, mitaka mos9)  
Remove old device  
``ceph osd out $osd
stop ceph-osd id=$osd
ceph osd crush rm osd.$osd
ceph auth del osd.$osd
ceph osd rm osd.$i
umount /var/lib/ceph/osd/ceph-$i``  
Add new device (probably you will need reboot to Linux determine new device on place of old (sdd -> sdd for example; not sdd -> sdl))   
``parted /dev/sdd mklabel gpt
parted /dev/sdd mkpart primary 1 26.2  #MB
parted /dev/sdd mkpart primary 27.3 237  
parted /dev/sdd mkpart primary 238 1200000  
parted /dev/sdd set 1 bios_grub  
sgdisk --typecode=3:4fbd7e29-9d25-41b8-afd0-062c0ceff05d -- /dev/sdd (This GUID IS NOT UNIQUE - ITs used for every osd(except journal, where guid= 45B0969E-9B03-4F30-B4C6-B4B80CEFF106))  
ceph-deploy --ceph-conf /root/ceph.conf osd prepare localhost:sdd3  
ceph-deploy --ceph-conf /root/ceph.conf osd activate localhost:sdd3  
ceph auth add osd.30 mon 'allow profile osd' osd 'allow *'  
ceph osd crush add 30 1.09 host=node02.HDD (30 - osd-id, 1.09 - weight)``  
### Ceph Bluestore mount via fuse  
``systemctl stop ceph-osd@ID    
mkdir /mnt/foo
ceph-objectstore-tool --op fuse --data-path /var/lib/ceph/osd/ceph-75 --mountpount /mnt/foo``  

### Delete old osds without monitors  
``systemctl stop ceph-osd@1  
umount /dev/sdb1
ceph-disk zap /dev/sdb``  

### Get config from mon  
``ceph daemon /var/run/ceph/ceph-mon.*.asok config show``  

### Ceph flatten and Delete OpenStack Images  
``rbd -p images ls -l  
rbd -p compute ls -l  
rbd -p compute flatten 43bfc2e8-5842-47c3-ad14-e6ce89c14061_disk  
rbd -p images rm --force 96b69c9c-f96d-4e4a-a7ca-8af478413f2a@snap``  

### Ceph Prevent Rebalancing  
``ceph osd set noout``  

### Ceph debugging
``ceph -s ( Check your active flags (like norecovery, nobackflip, etc...))  
ceph osd tree  
ceph health detail (| grep blocked)  
telnet monitor : 6789 (on ctrl node)  
status ceph-osd id=$id  
ceph pg dump | grep stuck``  

### Allow compute nodes to write in pool  
``ceph auth caps client.compute osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=images, allow rwx pool=compute' mon 'allow r'``  

### ceph log per osd  
``ceph daemon osd.0 log dump``  

ceph log per osd grep slowest recent ops  
``ceph daemon osd.0 dump_historic_ops``  

utlilization of ceph  
``ceph osd reweight-by-utilization 115``  

normal utilization is 120% average_util*120 = % drive full osd  
reweight ceph  
``ceph osd crush reweight osd.13 0.8``  

### Ceph fio instance testing  
 ``fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=test --filename=test --bs=4k --iodepth=64 --runtime=120 --readwrite=randrw --rwmixread=75 --size=15G``  

### Image upload to ceph rbd  
``rbd --pool images ls -l rados put {object-name} {file-path} --pool=data rbd -p images –image-format 2 import cirros-0.3.0-x86-64-disk.img.1 $(uuidgen) rados lspools>``  

## ISCSI  
### ISCSI mapping из rbd (for vmware and others) through tgt  
 ``apt-get install tgt  
 tgtadm --lld iscsi --mode system --op show (‘rbd’ should appear in “Backing stores:” if your tgtd supports rbd.) rbd create iscsi-image --size 50000 tgtadm --lld iscsi --mode target --op new --tid 1 --targetname rbd tgtadm --lld iscsi --mode logicalunit --op new --tid 1 --lun 1 --backing-store iscsi-image --bstype rbd tgtadm --lld iscsi --op bind --mode target --tid 1 -I ALL``  

### ISCSI connect to node  
``iscsiadm -m discovery -t st -p $IP iscsiadm -m node --login iscsiadm -m node -u``  

### Hyper-v Openstack integration win 2012 r2  
On nova-compute

1. Install on windows node https://cloudbase.it/installing-openstack-nova-compute-on-hyper-v/  
2. Configs  
c:/program files(x86)/Cloudbase/Openstack/Nova/etc/nova.conf neutron.conf  
 ``[glance] api_servers=http://endpoint  
 [neutron] url=endpoint; admin_tenant = serviceS; enable_security_groups=true  
 [oslo_messaging] rabbit_host - br_ex ip``  
!! IMPORTANT: enable rabbit listening on 0.0.0.0 on controller node (vi /etc/rabbit/rabbit-env) - and restart it !!  
3. Upload vhd images to glance  
 ``qemu-img convert ubuntu12x64.min -O vpc -o subformat=dynamic ubuntu12x64.vhd
 glance image-create --container-format bare --disk-format vhd --name 'sample' --file 'ubuntu12x64.vhd'``  
4. Check hypervisors in Openstack (horizon - admin - hypervisors, disable all hypervisors, except hyper-v on windows - for testing)  
5. Check logs on windows machine - C:/Openstack/Logs/  
https://ashwaniashwin.wordpress.com/2014/06/27/configure-remote-desktop-connection-to-hyper-v-virtual-machine/
Neutron (vxlan)  
6. We need to create 2 interfaces on VM - first interf in br-ex net and vlan trunk as second.
Make NIC team (VLAN ID=private network id) from second adapter   https://blogs.technet.microsoft.com/keithmayer/2012/11/20/vlan-tricks-with-nics-teaming-hyper-v-in-windows-server-2012/  
Disable firewall. After that you must have connectivity on both interfaces (in br-mesh and br-ex nets)  
Install ovs agent for windows - https://cloudbase.it/open-vswitch-24-on-hyperv-part-1/  
Make ovs settings (br-tun) as on compute nodes  
Add "\_" to c:/program   files/cloudbase/openstack/nova/python2.7/site-packages/hyperv/neutron/hyperv_neutron_agent.py  
https://git.openstack.org/cgit/openstack/networking-hyperv/commit/?id=8bc5a0352379cddc57c618ff745cee301b403b66  

### If you want vlan connectivity between hyperv node and openstack you should use neutron-hyperv-agent  
Pass steps from 1 to 3 and your environment will be ready.  

### Openstack contrail - vm problems  
###$ Problem: No ssh connection to vm or bad net on compute node  
Solution  
``ethtool -K eth0 tx off  
ethtool -K eth1 tx off  
ethtool -K bond0 tx off  
ethtool -k bond0  
(after reboot it disappers, so you need install new cron-  
@reboot ethtool -K eth0 tx off )``  

## Hp snmp hardware monitoring  
``apt-get install snmp snmpd  
iptables -I INPUT 1 -p udp --dport 161 -m comment --comment "snmp port" -j ACCEPT  
iptables -I INPUT 1 -p tcp --dport 161 -m comment --comment "snmp port" -j ACCEPT  
vi /etc/snmp/snmpd.conf agentAddress udp:161  
view - commented  
vi /etc/apt/sources.list.d/hp.list deb   http://downloads.linux.hpe.com/SDR/downloads/MCP/ubuntu precise current/non-free  
apt-get update  
apt-get download libc6-i386=2.19-0ubuntu6.7  
dpkg -i libc6-i386_2.19-0ubuntu6.7_amd64.deb  
apt-get install hp-health  
wget http://downloads.linux.hpe.com/SDR/downloads/MCP/ubuntu/pool/non-free/hp-snmp-agents_10.0.0.1.23-20._amd64.deb  
dpkg -i hp-snmp-agents_10.0.0.1.23-20.\_amd64.deb  
/sbin/hpsnmpconfig  
service snmpd restart  
snmpwalk -v1 -c public localhost 1.3.6.1.4.1.232  
zabbix template - hp_snmp_agents``  

## Supermicro snmp hardware monitoring  
U'll need SuperDoctor 5 (x64) - http://www.supermicro.com/solutions/SMS_SD5.cfm  
Also, you will need java 1.8 (jdk, preferable - just download java from oracle site, unzip and write export PATH=PATH:/opt/java/ to bashrc)  
Scp superdoctor on all nodes  
Run SuperDoctorInstaller x64  
During installation, specify your jdk path - /opt/java/jdk1.8/bin/java; Set other promts to default  
apt-get install snmpd snmp;  
vi /etc/snmp/snmpd.conf pass .1.3.6.1.4.1.10876   /opt/Supermicro/SuperDoctor5/libs/native/snmpagent rwcommunity public 127.0.0.1 rocommunity readonly 127.0.0.1 rwcommunity public 10.216.203.241 trapsink localhost public  
Comment out all lines with 'view' 'access' and so.  
service snmpd restart && service sd5 restart.  
SD5 is very buggy tool, so you'll maybe need another restart/reboot.  
Check logs, check /opt/Supermicro/SuperDoctor5/libs/native/snmpagent -n .1.3.6.1.4.1.10876;  
For hard drives monitoring im using custom bash script with zabbix agent in front.  
Example  
### 10.1  
vi /etc/zabbix/scripts/check_drive.sh  
``!/bin/sh -f  
PATH=$path:/bin:/usr/bin:/usr/ucb REQ="$1"  
echo $REQ  
udisks --show-info /dev/sda | grep FAIL > /dev/null; sda=$?  
echo "sda -$sda sdb -$sdb sdc -$sdc sdd -$sdd" >> /tmp/log  
echo "$RET"  
case "$REQ" in sda) echo "$sda" ;; esac``  
### 10.2
vi /etc/zabbix/zabbix_agentd.conf  
``Drives  
UserParameter=drive.status.sda,/etc/zabbix/scripts/check_drive.sh sda 10.3 service zabbix_agent restart``  
### Zabbix haproxy default bug  
vi /etc/zabbix/scripts/haproxy.sh  
``"-v")  
OPER='value'  
IFS=$'.'  
QA=($2)  
unset IFS  
HAPX=${QA[0]}  
HASV=${QA[1]}  
ITEM=${QA[2]}``  

### ARP Debug  
``arp -na   
arping -I <interface> dst  
arp -d IP (delete if mismathing mac)  
tcpdump -vv -an -i b_management -e arp``  

## Murano Bugs  
vim /usr/lib/python2.7/dist-packages/murano/api/v1/catalog.py  
``search def get_ui  
insert line tempf.flush()``  

## Mysql  
### create base for grafana  
Grafana  
``create database grafana;  
create user 'grafana'@'%' identified by 'grafana';  
grant all privileges on grafana.&ast; to 'grafana'@'%';  
quit;``  

### Create base ad table for new grafana  
``create database grafana;
GRANT USAGE ON `grafana`.* to 'grafana'@'mysqlserver.example.com' identified by 'password';
GRANT ALL PRIVILEGES ON grafana.* to 'grafana'@'%';
flush privileges;
use grafana;
create table `session` (`key`   char(16) not null, `data`  blob, `expiry` int(11) unsigned not null, primary key (`key`)) ENGINE=MyISAM default charset=utf8;``  


## Postgres  
### Update value in json field via jsonb  
``UPDATE report SET content = jsonb_set(content::JSONB, '{"1.1."}','"new_value"') where member_id='1';``  
 
## Puppet notes  
### Default parameter values   
Use with capitalized resource spec wihout title   
``Exec { path => ['/usr/bin', '/bin'] }``  

### Native mysql commands  
``use module "puppetlabs-mysql"``  
### Variable in variable  
``for facter $mule = "ipaddress_${name}" $donkey = inline_template("<%= scope.lookupvar(mule) %>") notify { "Found interface $donkey":; }``  
### Chain in conditional  
``$cinder_volume_exist = inline_template("<% if File.exist?('/etc/init.d/cinder-volume')   -%>;true<% end -%>") cinder_config {  
                   .......  
}  
if $cinder_volume_exist == 'true' {  

  exec {"service cinder restart"  
           command =&gt; "service cinder-volume restart",  
  }  
Cinder_config &lt;||&gt; ~&gt; Exec['service cinder restart']  
}``  
### accessing arrays  
``$arr[0]``  
### hiera_hash  
``/etc/fuel/clsuter/id/astute.yaml``  
### Array var in resource declaration  
``define process_osd {  

exec { "Prepare OSD $name":  

      command =&gt; "ceph-deploy --ceph-conf /root/ceph.conf osd prepare   localhost:$name$arr_len"  
 }  
}  
process_osd { $dev : }``  

### Bridges  
FDB (in case of changed net provider, for example):  
``bridge fdb show dev vxlan-16700141
bridge fdb replace 00:1d:aa:79:85:05 dev vxlan-16700141 master``  

## NEUTRON provider network FUEL deployment  
### Get future deployment settings  
``fuel deployment --env $env_id –default``  
### Update template for each node (Put these sections to the end of template)  
vim deployment_3/&ast;.yaml transformations  
``action: add-br name: br-private-phys  
action: add-br name: br-private provider: ovs  
action: add-patch bridges:  
br-private  
br-private-phys provider: ovs mtu: 65000  
action: add-port name: bond0 bridge: br-private-phys``  

Upload templates  
``fuel deployment --env $env_id --upload``  

## Neutron tips  
### In case of network unreachable in cloud-init  
``crm resource restart p_clone_neutron_dhcp_agent``  
### In case of connection refused  
``service neutron-l3-agent restart``  

## NEUTRON Provider network  
### configuring provider network  
``controller  
brctl addbr br-aux0  
brctl addif br-aux0 eth1  
ovs-vsctl add-br br-prv  
ovs-vsctl add-port br-prv aux0-prv  
set Interface aux0-prv type=internal  
brctl addif br-aux0 aux0-prv  
ifconfig br-aux0 up  
ifconfig br-prv up  
ifconfig aux0-prv up``  

compute  
``brctl addbr br-aux0    
brctl addif br-aux0    
eth2 ovs-vsctl  
add-br br-prv  
ovs-vsctl add-port br-prv aux0-prv  
set Interface aux0-prv type=internal  
brctl addif br-aux0 aux0-prv  
ifconfig br-aux0 up  
ifconfig br-prv up  
ifconfig aux0-prv up  
nano /etc/network/interfaces.d/ifcfg-aux0-prv  
iface aux0-prv  
inet manual  
ovs_bridge br-prv  
ovs_type OVSIntPort  
nano /etc/network/interfaces.d/ifcfg-br-aux0  
auto br-aux0  
iface br-aux0  
inet manual  
bridge_ports eth2 aux0-prv  
nano /etc/network/interfaces.d/ifcfg-br-prv  
auto br-prv  
allow-ovs br-prv  
iface br-prv  
inet manual  
ovs_ports aux0-prv  
ovs_type OVSBridge dfs  
nano -c /etc/neutron/plugin.ini  
… [ml2_type_vlan] … network_vlan_ranges = physnet1:33:63 [ovs] ... bridge_mappings =   physnet1:br-prv ...``  

controller
``service neutron-server restart  
crm resource restart p_neutron-plugin-openvswitch-agent  
crm resource restart p_neutron-l3-agent``  

compute  
``service neutron-plugin-openvswitch-agent restart  
service nova-compute restart``  

VERIFY  
``neutron net-create --provider:network_type=vlan \
--provider:physical_network=physnet1 --provider:segmentation_id 33 net33``  

## NEUTRON tips  

### Attaching fixed ip to vm  
``neutron port-create --tenant-id #tenant_id \
--fixed-ip subnet_id=#subnet_id,ip_address=...   
nova interface-attach --port-id #port_id #instance_id``  

### Adding static route to qrouter (ovs-vswitch)  
``neutron router-update #router_id --routes type=dict list=true \
destination=10.0.0.0/8,nexthop=10.1.3.1``  

## SaltStack  
###  Grains  
list grains  
``salt \* grains.ls (or salt-call grains.ls local)``  
### mighty one-liner  
``sudo useradd saltadmin -m -s /bin/bash && sudo mkdir /home/saltadmin/.ssh/ && sudo echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDToAsqw/DBPTS9JcbrjpIJDwzYHGrCCHkgW5mWnbmwBQvyvdmQtQdB3zkKXHeFI2AanhTErmek7TYwWOw/sVbNyQ3NxSssEsbI8sjnT7uzSE3qI+lHAMFxggYZJeFCvMBh2GbsCITg0+jiuBmp46HutphkRzEA9qCfNrK4m4nh0yz7kVrZM4OMCpMWwZ+0HtqA6SBKPL4DyIwmGYRBUYxQXyJLQMlD/K9+bpZv+69kCDERlOPbTGWQaxAx9c+sOvC43AaddDvtp6/Cmezir8kd6avdRhlpSpYubGcWv4n0M689L3kfiD1CT4kQkuyO8wnryVbDsJKmdtfqx2esng1H saltadmin@skl-salt-master-101' > /home/saltadmin/.ssh/authorized_keys && sudo chown -R saltadmin:saltadmin /home/saltadmin/ && sudo apt update && sudo apt install python-minimal && echo 'saltadmin ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo``  

### problems with multipline pillar and file.managed  
`` USE IDENT  
 file.managed:  
    - name: /var/opt/mssql/secrets/passwd  
    - contents: |  
        {{ pillar['SA_passwd'] | indent(8) }}``  
### Changed hostnames on minion  
``on salt-minion  
1. update /etc/salt/minion_id   
2. rm -rf /etc/salt/pki/minion/*
3. systemctl restart salt-minion  
on salt-master  
1. salt-key -L  
2. salt-key -a $id``  

### Simple Salt master and Salt minion configs  
Salt-master  
``file_roots:  
  base:  
    - /home/saltadmin/SALT/salt  
hash_type: sha256  
pillar_roots:  
  base:  
    - /home/saltadmin/SALT/pillar  
log_file: /var/log/salt/master  
log_level: warning  
log_level_logfile: trace  
``  
Salt-minion  
``master: 10.1.35.9  
hash_type: sha256  
file_recv_max_size: 10000  
``  

## Nexus 3  
### Simple deploy  
``docker pull sonatype/nexus3  
mkdir /opt/nexus-data && chown -R 200 /opt/nexus-data  
docker run -d -p 8081:8081 -p 5000:5000 --name nexus -v /opt/nexus-data:/nexus-data sonatype/nexus3  
cat /opt/nexus-data/admin.password
BROWSER:
login, create docker hosted repo with HTTP connector 5000``  

### OrientDB reset admin  
``ssh
java -jar /opt/sonatype/nexus/lib/support/nexus-orient-console.jar
CONNECT plocal:/nexus-data/db/security admin admin  
update user SET password="$shiro1$SHA-512$1024$NE+wqQq/TmjZMvfI7ENh/g==$V4yPw8T64UQ6GfJfxYq2hLsVrBY8D1v+bktfOxGdt4b/9BthpWPNUy/CBk6V9iA0nHpzYzJFWO8v/tZFtES8CA==" UPSERT WHERE id="admin"  
delete from realm``  
If there still no configuration tab - it's maybe not your fault, try another browser and cacheclaening  
## KUBERNETES  
### Diagnostic net pod  
``kubectl run --generator=run-pod/v1 tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash
#more info - https://github.com/nicolaka/netshoot``  

### Force delete stale pods  
``kubectl delete po POD_NAME  --grace-period=0 --force``  

### Delete all Evicted pods in all namespaces  
``kubectl get po -a --all-namespaces -o json | \
jq  '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) |
"kubectl delete po \(.metadata.name) -n \(.metadata.namespace)"' | xargs -n 1 bash -c``  

### Autoscaler / allocatable  
Check autoscaler status
``kubectl describe -n kube-system configmap cluster-autoscaler-status``  

#Check maximum pods configuration for the node
``kubectl get node NODE-NAME -ojson | jq .status.allocatable.pods``    

### Check Kubernetes API availability  
(create dummy resource and delete it via REST API):  
``Bearer=Token

curl  --insecure -XDELETE -H "Authorization: Bearer $Bearer" 'https://apiURl:8443/api/v1/namespaces/default/configmaps/dummyzb'
sleep 2;
curl -s -o /dev/null -w "%{http_code}" --insecure -XPOST  -H "Authorization: Bearer $Bearer" -H 'Content-Type: application/json' -d '{"apiVersion":"v1","kind":"ConfigMap","metadata":{"name":"dummyzb","namespace":"default"}}'  'https://apiURL:8443/api/v1/namespaces/default/configmaps'``  

### Haproxy frontend/backend stats via socket  
`` echo "show stat" | nc -U /var/lib/haproxy/stats | cut -d "," -f 1,2,5-11,18,24,27,30,36,50,37,56,57,62 | column -s, -t``  
OR more convenient way )):   
``hatop -s /run/haproxy.stat``  

### Create automatically pods via kubelet (for OS)  
``cd /etc/origin/node/pods  
vim mypod.yaml  
systemctl restart origin-node.service``  

### Remove Ctrl-M characters from file (^M)  
``vim filename  
%s/^M//g``  
obvious, yeah)  
Also:  
``sed -e "s/^M//" -i filename``

### Grafana Auth  
``kubectl get deploy -n kube-system  
kubectl edit deploy monitoring-grafana``  
env variables
``- env:  
  - name: INFLUXDB_HOST  
    value: monitoring-influxdb  
  - name: INFLUXDB_SERVICE_URL  
    value: http://monitoring-influxdb:8086  
  - name: GRAFANA_PORT  
    value: "3000"  
  - name: GF_AUTH_BASIC_ENABLED  
    value: "true"  
  - name: GF_AUTH_ANONYMOUS_ENABLED  
    value: "false"  
  - name: GF_SERVER_ROOT_URL  
    value: /  
  - name: GF_SECURITY_ADMIN_PASSWORD  
    value: GrAfAnA  
  - name: GRAFANA_PASSWD  
    value: GrAfAnA``  

### Forward-port  
``kubectl port-forward heketi-37915784-8gkqp :8080``  
Forwarding from 127.0.0.1:38219 -> 8080  
Forwarding from [::1]:38219 -> 8080  
curl localhost:38219/hello  
Hello from heketi   

### Connect to etcd (kubespray)  
On etcd node (not in container) run:  
``netstat -ltupn | grep 2379  
IP=$(netstat -ltupn | grep 2379 | grep -v '127.0.0.1' | awk '{print $4}')

etcdctl --cert-file /etc/ssl/etcd/ssl/member-f00k8setcs01.pem --key-file /etc/ssl/etcd/ssl/member-f00k8setcs01-key.pem --endpoints https://$IP ls``  

### Kubectl debug  
``kubectl -v 10 get po``  

### Expose deployment on ALL nodes via nodeport  
``kubectl expose deployment echoserver --type=NodePort``  
### Check user rights  
``kubectl auth can-i list secrets --namespace dev --as dave``  
### Too long node evacuation (up to 7-10 minutes)  
Start kube-controller-manager with these flags (if you are using rancher, then just upgrade controller-manager service)  
`` --node-monitor-grace-period=16s --pod-eviction-timeout=30s``  

### Find pod by ip   
``kubectl get pods -o wide --namespace monitoring | grep $ip``  

### Old browser dashboard case   
If you get an empty page when you are opening dashboard with url from _cluster info_ command like    
``https://10.1.39.235/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy``  
When you should try complete url for dashboard:  
``https://10.1.39.235/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/workload?namespace=default``  

## Simple Centos bond/bridge interfaces configs  
cat ifcfg-enp130s0f0  
``NAME=enp130s0f0
DEVICE=enp130s0f0
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
MASTER="bond0"
SLAVE=yes
NM_CONTROLLED=no``  
cat bond0  
``DEVICE=bond0
NAME=bond0
TYPE=Bond
BONDING_MASTER=yes
IPV6INIT=no
MTU=9000
ONBOOT=yes
USERCTL=no
NM_CONTROLLED=no
BOOTPROTO=none
BONDING_OPTS="mode=802.3ad xmit_hash_policy=layer2+3 lacp_rate=1 miimon=100"
``
cat ifcfg-bond0.4001
``DEVICE=bond0.4001
NAME=bond0.4001
BOOTPROTO=none
ONPARENT=yes
MTU=9000
VLAN=yes
NM_CONTROLLED=no
BRIDGE=br-storage``   
cat br-storage  
``DEVICE=br-storage
TYPE=Bridge
BOOTPROTO=none
ONBOOT=yes
IPADDR=IP
PREFIX=24
NM_CONTROLLED=no``  
cat /etc/udev/rules.d/71-net-txqueuelen.rules  
``SUBSYSTEM=="net", ACTION=="add", KERNEL=="*", ATTR{tx_queue_len}="10000"``  

## CALICO  
Get your current mtu  
``calicoctl config get --raw=felix IpInIpMtu``  
Setup lower mtu  
``calicoctl config set --raw=felix IpInIpMtu 1400``  
