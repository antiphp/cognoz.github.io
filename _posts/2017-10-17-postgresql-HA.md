---
layout: post  
title: Postgresql 9.5 HA installation with loadbalancing pgpool2 and phpadmin  
tags: postgres linux HA pgpool2  
---
### Creating HA Postgres cluster with loadbalancing via pgpool2  

### What we have  
hosts:  
primary server postgres01 ip: 192.168.56.21  
standby server postgres02 ip: 192.168.56.22  
virtual ip:  
192.168.56.16  

### Installation and replication  
### ALL nodes  
``add-apt-repository ppa:ondrej/php  
echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /etc/apt/sources.list.d/postgresql.list  
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -  
wget http://archive.ubuntu.com/ubuntu/pool/main/libm/libmemcached/libmemcached6_0.44-1.1build1_amd64.deb && dpkg -i   libmemcached6_0.44-1.1build1_amd64.deb  
apt-get update  
apt-get -y install postgresql-9.5 postgresql-9.5-pgpool2 pgpool2 iputils-arping apache2 php5.6 libapache2-mod-php5.6 php5.6-pgsql``  

sudo visudo:   
``postgres ALL=(ALL) NOPASSWD:ALL
www-data ALL=(ALL) NOPASSWD:ALL #for pgadmin php``  

``passwd postgres  
service postgresql restart  
sudo -u postgres psql  
ALTER USER postgres WITH PASSWORD 'postgres';  
CREATE ROLE replication WITH REPLICATION PASSWORD 'reppassword' LOGIN;  
\q``  

vim /var/lib/postgresql/.pgpass:
``*:*:*:replication:reppassword``  
``chown postgres:postgres /var/lib/postgresql/.pgpass  
chmod 0600 /var/lib/postgresql/.pgpass``  

vim /etc/postgresql/9.5/main/postgresql.conf:
``listen_addresses = '*'  
port = 5433``  

vim /etc/postgresql/9.5/main/pg_hba.conf:  
``host replication replication 192.168.56.21/32 md5  
host replication replication 192.168.56.22/32 md5  
host all postgres 192.168.56.0/24 md5``  
``service postgresql restart``  

### On primary node

vim /etc/postgresql/9.5/main/postgresql.conf:  
``wal_level = hot_standby  
max_replication_slots = 10  
max_wal_senders = 10``  

``service postgresql restart    
sudo -u postgres psql  
SELECT * FROM pg_create_physical_replication_slot('it_postgresql01');``  

### On standby node  

``service postgresql stop  
sudo -i -u postgres  
cd /var/lib/postgresql/9.5  
rm -rf main  
pg_basebackup -v -D main -R -P -h 192.168.56.21 -p 5433 -U replication``  

vim /etc/postgresql/9.5/main/postgresql.conf:  
``hot_standby = on  
hot_standby_feedback = on``  

``sudo -i -u postgres  
cd 9.5/main/  
vim recovery.conf  
standby_mode = 'on'  
primary_slot_name = 'it_postgresql01'  
primary_conninfo = 'host=192.168.56.21 port=5433 user=replication password=reppassword'  
trigger_file = '/etc/postgresql/9.5/main/im_the_master'  
sudo service postgresql start``  

## II  

### On all nodes  
### Basic setup - SSH-key auth, hosts  
vim /etc/hosts:  
``192.168.56.21 postgres01  
192.168.56.22 postgres02  
192.168.56.1 DC1 #gateway for check, pingable``  

``sudo -i -u postgres  
ssh-keygen  
ssh-copy-id postgres@postgres0{1,2}  
ssh-copy-id postgres@postgres0{2,1}  
mkdir /etc/postgresql/9.5/main/repltemplates``  

### On primary node - templates for master/slave configurations  
``cd /etc/postgresql/9.5/main/repltemplates  
scp postgres02:/etc/postgresql/9.5/main/postgresql.conf ./postgresql.conf.standby  
cp /etc/postgresql/9.5/main/postgresql.conf /etc/postgresql/9.5/main/reptemplates/postgresql.conf.primary  
scp -r /etc/postgresql/9.5/main/repltemplates postgres02:/etc/postgresql/9.5/main/repltemplates``  

### On all nodes  
``chown postgres:postgres /etc/postgresql/9.5/main/pg_hba.conf  
chown postgres:postgres -R /etc/postgresql/9.5/main/repltemplates  
mkdir /etc/postgresql/9.5/main/replscripts  
scp -r etc/postgresql/9.5/main/replscripts/ postgres@postgres0{1,2}:/etc/postgresql/9.5/main/  
chown postgres:postgres -R /etc/postgresql/9.5/main/replscripts  
chmod 0744 -R /etc/postgresql/9.5/main/replscripts``  

### On primary node  
### Promoting primary server  
``sudo -u postgres /etc/postgresql/9.5/main/replscripts/promote.sh -f -p reppassword``  

### On slave node  
### Standby initiate  
``sudo -u postgres /etc/postgresql/9.5/main/replscripts/initiate_replication.sh -f -H postgres01 -P 5433 -p reppassword``  

### On primary node  
``mkdir /etc/postgresql/9.5/main/sql  
scp -r etc/postgresql/9.5/main/sql postgres01:/etc/postgresql/9.5/main/  
sudo -u postgres psql -f pgpool-recovery.sql template1  
sudo -u postgres psql -f pgpool_adm.sql template1  
sudo -u postgres psql -f pgpool_adm--1.0.sql template1``  

### On all nodes  
``scp var/lib/postgresql/9.5/main/recovery_1st_stage.sh postgres0{1,2}:/var/lib/postgresql/9.5/main/recovery_1st_stage.sh  
scp var/lib/postgresql/9.5/main/pgpool_remote_start postgres0{1,2}:/var/lib/postgresql/9.5/main/pgpool_remote_start  
scp etc/pgpool2/failover.sh postgres0{1,2}:/etc/pgpool2/failover.sh  
sudo chown postgres:postgres /var/lib/postgresql/9.5/main/pgpool_remote_start :/var/lib/postgresql/9.5/main/recovery_1st_stage.sh   /etc/pgpool2/failover.sh  
chmod 0700 /var/lib/postgresql/9.5/main/pgpool_remote_start /var/lib/postgresql/9.5/main/recovery_1st_stage.sh /etc/pgpool2/failover.sh  
for i in /etc/postgresql/9.5/main/postgresql.conf /etc/postgresql/9.5/main/repltemplates/postgresql.conf.primary   /etc/postgresql/9.5/main/repltemplates/postgresql.conf.standby; do echo "pgpool.pg_ctl = '/usr/lib/postgresql/9.5/bin/pg_ctl'" >> $i; done  
sudo useradd admin  
sudo passwd admin #assume that admin pass is pa55w0rd  
pg_md5 pa55w0rd #hash 97bf34d31a8710e6b1649fd33357f783``  
sudo vim /etc/pgpool2/pcp.conf:  
``admin:97bf34d31a8710e6b1649fd33357f783  
postgres:e8a48653851e28c69d0506508fb27fc5``  

### On primary node  
``sudo -i -u postgres createuser --pwprompt admin #pass pa55w0rd``  

#On all nodes  
vim /etc/postgresql/9.5/main/pg-hba.conf:  
``host replication replication 192.168.56.21/32 md5  
host replication replication 192.168.56.22/32 md5  
host all postgres 192.168.56.0/16 md5  
host all all 192.168.56.21/32 trust  
host all all 192.168.56.22/32 trust``  

``scp etc/pgpool2/pgpool.conf postgres0{1,2}:/etc/pgpool2/  
ssh postgres01  
sed -i 's/postgres01/YOURMASTERHOSTNAME/g' /etc/pgpool2/pgpool.conf  
sed -i 's/postgres02/YOURSLAVEHOSTNAME/g' /etc/pgpool2/pgpool.conf  
sed -i 's/192.168.56.16/YOURVIP/g' /etc/pgpool2/pgpool.conf  
sed -i 's/enp0s8/YOURDEVICE/g' /etc/pgpool2/pgpool.conf``  
``ssh postgres02  
sed -i 's/postgres01/YOURSLAVEHOSTNAME/g' /etc/pgpool2/pgpool.conf  
sed -i 's/postgres02/YOURMASTERHOSTNAME/g' /etc/pgpool2/pgpool.conf  
sed -i 's/enp0s8/YOURDEVICE/g' /etc/pgpool2/pgpool.conf``  

### On one host, change config, and scp to other  
sudo vim [/etc/pgpool2/pgpool.conf](/listings/2017-10-17-postgresql-HA/pgpool.conf)

### On primary node

sudo vim /etc/pgpool2/pgpool.conf:
``wd_hostname = 'postgres01'  
wd_port = 9000  
heartbeat_destination0 = 'postgres02'  
heartbeat_destination_port0 = 9694  
other_pgpool_hostname0 = 'postgres02'  
other_pgpool_port0 = 5432  
other_wd_port0 = 9000``  

### On standby node  

sudo vim /etc/pgpool2/pgpool.conf:  
``wd_hostname = 'postgres02'  
wd_port = 9000  
heartbeat_destination0 = 'postgres01'  
heartbeat_destination_port0 = 9694  
other_pgpool_hostname0 = 'postgres01'  
other_pgpool_port0 = 5432  
other_wd_port0 = 9000``  

### On all nodes

``scp bin/ip_w root@postgres0{1,2}:/bin/  
scp bin/ip_w root@postgres0{1,2}:/sbin/  
scp usr/bin/arping_w root@postgres0{1,2}:/usr/bin/  
chmod 0755 /bin/ip_w /usr/bin/arping_w /sbin/ip_w  
sudo chown postgres:postgres /bin/ip_w /usr/bin/arping_w /sbin/ip_w  
sudo update-rc.d enable pgpool2``  

sudo vim /etc/pgpool2/pool_hba.conf:  
``host all all 0.0.0.0/0 md5``  

### On primary node  
``cd /etc/pgpool2/  
sudo pg_md5 -f /etc/pgpool2/pgpool.conf -m -u admin pa55w0rd  
sudo pg_md5 -f /etc/pgpool2/pgpool.conf -m -u postgres postgres   
scp pool_passwd postgres02:/etc/pgpool2/  
sudo -i -u postgres psql  
ALTER USER admin WITH SUPERUSER;  
ALTER USER postgres WITH SUPERUSER;``  

### On all nodes  
``sudo chown www-data /etc/pgpool2/pcp.conf  
sudo chown www-data /etc/pgpool2/pgpool.conf  
sudo chmod 0644 /etc/pgpool2/pgpool.conf  
sudo service pgpool2 start``  

sudo vim /var/www/.pcppass:  
``*:*:admin:pa55w0rd  
*:*:postgres:postgres``  
``sudo cp /var/www/.pcppass /root/   
sudo cp /var/www/.pcppass /var/lib/postgresql/  
scp portal/install_portal.sh ./ && chmod +x install_portal.sh   
./install_portal.sh  
sudo chown www-data:www-data /var/www/.pcppass  
sudo chmod 600 /var/www/.pcppass  
service apache2 restart``  

### In browser  
Go to http://192.168.56.16/pgpooladmin/install/index.php  
english -> ok ->  
pgpool.conf File -> /etc/pgpool2/pgpool.conf  
pcp.conf File -> /etc/pgpool2/pcp.conf  
pgpool command -> /usr/sbin/pgpool  
pcp directory -> /usr/sbin/  

### On all nodes  
``scp attach_node.sh postgres0{1,2}:/etc/postgresql/9.5/main/replscripts/attach_node.sh``  
sudo -u postgres crontab -e:  
``@reboot /etc/postgresql/9.5/main/replscripts/attach_node.sh``  
