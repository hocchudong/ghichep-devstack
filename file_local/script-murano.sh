#!/bin/bash

export MY_IP=`/sbin/ifconfig eth0 | awk '/inet addr/ {print $2}' | cut -f2 -d ":" `
export GATEWAY=$(/sbin/ip route | awk '/default/ { print $3 }')
export NET=$(echo $MY_IP | awk -F. '{print $1"."$2"."$3}')

# git clone https://git.openstack.org/openstack-dev/devstack
# git clone https://git.openstack.org/openstack/murano

git clone -b stable/kilo https://github.com/openstack-dev/devstack.git
git clone -b stable/kilo  https://git.openstack.org/openstack/murano




cp murano/contrib/devstack/lib/murano devstack/lib/.
cp murano/contrib/devstack/lib/murano-dashboard devstack/lib/.
cp murano/contrib/devstack/extras.d/70-murano.sh devstack/extras.d/.

sed -i "/SESSION_ENGINE = 'django.contrib.sessions.backends.db'/a MURANO_REPO_URL = 'http://storage.apps.openstack.org/'" devstack/lib/murano-dashboard

cat <<EOF > devstack/local.conf

[[local|localrc]]
SERVICE_TOKEN=openstack
ADMIN_PASSWORD=openstack
MYSQL_PASSWORD=openstack
RABBIT_PASSWORD=openstack
SERVICE_PASSWORD=\$ADMIN_PASSWORD


HOST_IP=$MY_IP

LOGFILE=\$DEST/logs/stack.sh.log
LOGDAYS=2
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=\$DEST/data

enable_service tempest
enable_service heat h-api h-api-cfn h-api-cw h-eng
enable_service murano murano-api murano-engine

disable_service n-net
enable_service q-svc
enable_service q-agt
enable_service q-dhcp
enable_service q-l3
enable_service q-meta


#ml2
Q_PLUGIN=ml2
Q_AGENT=openvswitch

# vxlan
Q_ML2_TENANT_NETWORK_TYPE=vxlan


# PUBLIC_INTERFACE=eth0
# Q_USE_PROVIDERNET_FOR_PUBLIC=True
# Q_L3_ENABLED=True
# Q_USE_SECGROUP=True
# OVS_PHYSICAL_BRIDGE=br-ex
# PUBLIC_BRIDGE=br-ex
# OVS_BRIDGE_MAPPINGS=public:br-ex

# FLOATING_RANGE="$GATEWAY/24"
# Q_FLOATING_ALLOCATION_POOL=start=$NET.230,end=$NET.254
# FIXED_RANGE="10.0.0.0/24"
# PUBLIC_NETWORK_GATEWAY="$GATEWAY"


#vnc
enable_service n-novnc
enable_service n-cauth

EOF

cd devstack
./stack.sh


