# Các ghi chép về Devstack

## Chuẩn bị

- Nâng cấp các gói cần thiết
```sh
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && init 6
```

- Tạo user stack
```sh
adduser stack
apt-get -y install sudo 
apt-get -y install git
echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```

### Bắt đầu cài devstack 

- Đăng nhập với tài khoản stack hoặc chuyển sang user stack
```sh
su - stack
```

- Tải gói từ devstack về

```sh
Tải gói mới nhất: 

 git clone https://github.com/openstack-dev/devstack.git

Hoặc chỉ định gói:
 git clone -b stable/liberty https://github.com/openstack-dev/devstack.git

```

### CINDER - Các ghi chép devstack với cinder

- Mặc định thì devstack sẽ tạo ra ổ loop để cài đặt cinder volume. Nếu muốn sử dụng ổ sdb, sdc ... thì cần thực hiện như sau
 - Thêm ổ cứng thứ 2 cho máy cài devstack, trong hướng dẫn này sử dụng là sdb
 - Cấu hình lvm cho ổ cứng thứ 2 này, với tên volume là stack-volume
 
 ```sh
 pvcreate /dev/sdb
 vgcreate stack-volumes /dev/sdb
 ```
 - Khai báo trong file local.conf đoạn sau
 ```sh
 ....
 VOLUME_GROUP="stack-volumes"
 ```
 

 
### Xử lý devstack sau khi cài xong
```sh

###=====Cấu hình sau khi cài đặt devstack xong cần cấu hình đề VM ra được internet======####

### CÁCH 1
# Cách giữ nguyên dải IP public (EXT) cho OpenStack - devstack sau khi cài và giúp máy ảo có thể ra được internet.
# Lúc này IP ADD của eth0 là dải 192.168.1.0
#Khi cài devstack xong, ip public sẽ là dải 172.16.4.0/24 và ip private là 10.0.0.0/24
# Do vậy để ra được internet cần phải thực hiện NAT sang card eth0 bằng lệnh sau:

     sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE



### CÁCH 2
# Thay đổi IP Public (EXT) - sao cho trùng với dải ip của eth0
###Thay đổi port cho br-ex
          ovs-vsctl add-port br-ex eth0

## Sửa file /etc/network/interface với thông số như sau:

# The primary network interface
#auto eth0
#iface eth0 inet static
#address 192.168.1.20
#netmask 255.255.255.0
#gateway 192.168.1.2
#dns-nameservers 8.8.8.8

auto eth0
iface eth0 inet manual
up ifconfig $IFACE 0.0.0.0 up
up ip link set $IFACE promisc on
down ip link set $IFACE promisc off
down ifconfig $IFACE down

auto br-ex
iface br-ex inet static
    address 192.168.1.20
    netmask 255.255.255.0
    gateway 192.168.1.2
    dns-nameservers 8.8.8.8

 ## Khởi động lại dịch vụ mạng hoặc khởi động lại cả openstack (nếu khởi động lại openstack nhớ chạy lệnh rejoin-stack.sh)
### SAu đó cấu hình lại dải IP Public trùng với dải ip của card eth0 là ok

```
 
### Cai dat devstack khi dung sau proxy

https://yapale.wordpress.com/2014/11/15/installing-devstack-behind-proxy/

http://www.rushiagr.com/blog/2014/08/05/devstack-behind-proxy/


- Khai báo dòng này để cài các gói offline nếu cần 
OFFLINE=True
