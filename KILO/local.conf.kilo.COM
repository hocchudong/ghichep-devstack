[[local|localrc]]
DEST=/opt/stack

# Logging
LOGFILE=$DEST/logs/stack.sh.log
VERBOSE=True
SCREEN_LOGDIR=$DEST/logs/screen

# Credentials
ADMIN_PASSWORD=openstack
MYSQL_PASSWORD=openstack
RABBIT_PASSWORD=openstack
SERVICE_PASSWORD=openstack
SERVICE_TOKEN=tokentoken

# Host detail
#EDITME
HOST_IP=10.10.10.207
#EDITME
SERVICE_HOST=10.10.10.249
Q_HOST=$SERVICE_HOST

# Services
disable_all_services
ENABLED_SERVICES=neutron,n-cpu,rabbit,q-api,q-agt,n-novnc

#plugin
Q_PLUGIN=ml2
Q_AGENT=openvswitch
#gre
#Q_ML2_TENANT_NETWORK_TYPE=gre

#vxlan
Q_ML2_TENANT_NETWORK_TYPE=vxlan

# VLAN configuration
#Q_ML2_TENANT_NETWORK_TYPE=vlan
#ENABLE_TENANT_VLANS=True
#ML2_VLAN_RANGES=tenant-vlan:200:300,public
#ENABLE_TENANT_TUNNELS=False
#ML2_VLAN_RANGES=physnet1:2001:2999
#PHYSICAL_NETWORK=default
#OVS_PHYSICAL_BRIDGE=br-int
#OVS_PHYSICAL_BRIDGE=br-eth1
#PHYSICAL_NETWORK=physnet1
#TENANT_VLAN_RANGE=1000:1999
