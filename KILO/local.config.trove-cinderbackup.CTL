[[local|localrc]]
DEST=/opt/stack

# Logging
LOGFILE=$DEST/logs/stack.sh.log
VERBOSE=True
SCREEN_LOGDIR=$DEST/logs/screen
OFFLINE=False

# HOST
#EDITME
HOST_IP=10.10.10.249

# Networking
FLOATING_RANGE="10.10.10.0/24"
FIXED_RANGE="10.0.0.0/24"
Q_FLOATING_ALLOCATION_POOL=start=10.10.10.50,end=10.10.10.90
PUBLIC_NETWORK_GATEWAY="10.10.10.10"
PUBLIC_INTERFACE=eth0


disable_service n-net
enable_service q-svc
enable_service q-agt
enable_service q-dhcp
enable_service q-meta
enable_service q-l3

#ml2
Q_PLUGIN=ml2
Q_AGENT=openvswitch

# vxlan
Q_ML2_TENANT_NETWORK_TYPE=vxlan

# gre
#Q_ML2_TENANT_NETWORK_TYPE=gre

# VLAN configuration
#Q_ML2_TENANT_NETWORK_TYPE=vlan
#ENABLE_TENANT_VLANS=True
#ENABLE_TENANT_TUNNELS=False
#ML2_VLAN_RANGES=tenant-vlan:200:300,public
#PHYSICAL_NETWORK=physnet1
#OVS_PHYSICAL_BRIDGE=br-eth1
#TENANT_VLAN_RANGE=1000:1999

# Credentials
ADMIN_PASSWORD=openstack
MYSQL_PASSWORD=openstack
RABBIT_PASSWORD=openstack
SERVICE_PASSWORD=openstack
SERVICE_TOKEN=tokentoken

# Ceilometer
# Enable the ceilometer metering services
#enable_service ceilometer-acompute ceilometer-acentral ceilometer-anotification ceilometer-collector
# Enable the ceilometer alarming services
#enable_service ceilometer-alarm-evaluator,ceilometer-alarm-notifier
# Enable the ceilometer api services
#enable_service ceilometer-api

# Swift
enable_service s-proxy s-object s-container s-account
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f6

#CINDER
CINDER_MULTI_LVM_BACKEND=True
CINDER_ENABLED_BACKENDS=lvm:lvmdriver-1,lvm:lvmdriver-2
##Enable Cinder-Backup
enable_service c-bak

#Trove
enable_service trove,tr-api,tr-tmgr,tr-cond

# Enable Heat
enable_service heat h-api h-api-cfn h-api-cw h-eng

# Enable Murano
# enable_service murano murano-api murano-engine

#scheduler
enable_service n-sch
SCHEDULER=nova.scheduler.chance.ChanceScheduler

#vnc
enable_service n-novnc
enable_service n-cauth
