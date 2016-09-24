# Các ghi chép về Devstack

## Chuẩn bị

- Nâng cấp các gói cần thiết
```sh
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && init 6
```

- Tạo user stack
```sh
apt-get -y install sudo git

adduser stack

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

### NEUTRON - Các ghi chép devstack với NEUTRON

- Khai báo chỉ sử dụng IPv4 trong devstack. Mặc định từ bản Kilo trở đi, devstack enable cả IPv4 và IPv6
```sh
IP_VERSION=4
```

- Khai báo tham số MTU cho các máy ảo.
```sh
- Lúc này các máy ảo sẽ có MTU được đặt với giá trị ở dòng khai báo sau:

# Set MTU
Q_ML2_PLUGIN_PATH_MTU=1454

```

#### Sử dụng devstack với mô hình Provider network (không có L3 Agent)
```sh
Tham khảo file NO-L3-controller-local.conf
```

#### Sử dụng devstack với mô hình Selfservice-network (có L3 Agent)


### CINDER - Các ghi chép devstack với cinder

- Mặc định thì devstack sẽ tạo ra ổ loop để cài đặt cinder volume. Nếu muốn sử dụng ổ sdb, sdc ... thì cần thực hiện như sau
 - Thêm ổ cứng thứ 2 cho máy cài devstack, trong hướng dẫn này sử dụng là sdb
 - Cấu hình lvm cho ổ cứng thứ 2 này, với tên volume là stack-volume
 
 ```sh
 pvcreate /dev/sdb
 vgcreate stack-volumes-lvmdriver-1 /dev/sdb
 ```
    - Khai báo trong file local.conf đoạn sau
        ```sh
        ....
        VOLUME_GROUP="stack-volumes-lvmdriver-1"
        ...
        ```

- Nếu muốn sử dụng ổ `vdb` làm nơi lưu trữ Volume thì thực hiện các bước sau khi khởi động lại máy cài cinder

    - Kiểm tra xem có ổ vdb hay chưa bằng lệnh `lsblk`
    
        ```sh
        root@c-dev:~# lsblk
        NAME                         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
        sr0                           11:0    1   574M  0 rom
        vda                          253:0    0    60G  0 disk
        |-vda1                       253:1    0   243M  0 part /boot
        |-vda2                       253:2    0     1K  0 part
        `-vda5                       253:5    0  59.8G  0 part
          |-c--dev--vg-root (dm-0)   252:0    0  55.8G  0 lvm  /
          `-c--dev--vg-swap_1 (dm-1) 252:1    0     4G  0 lvm
        vdb                          253:16   0    30G  0 disk
        ```
    - Sửa dòng dưới trong file `/etc/lvm/lvm.conf` (Dòng này mặc định không có, devstack tự thêm vào, lưu ý `vdb`)
    
        ```sh
        global_filter = [ "a|loop0|", "a|loop1|", "a|vda5|", "a|vdb|", "r|.*|" ]  # from devstack
        ```
    
    - Tạo LVM physical volume 
    
        ```sh
        pvcreate /dev/vdb
        ```
    
    - Tạo  LVM volume group (lưu ý tên `stack-volumes-lvmdriver-1`)
    
    ```sh
    vgcreate stack-volumes-lvmdriver-1 /dev/sdb
    ```
    
    - Kiểm tra lại xem volume group đã được tạo hay chưa bằng lệnh `vgdisplay`
    
        ```sh
        root@c-dev:~# vgdisplay
          --- Volume group ---
          VG Name               stack-volumes-lvmdriver-1
          System ID
          Format                lvm2
          Metadata Areas        1
          Metadata Sequence No  3
          VG Access             read/write
          VG Status             resizable
          MAX LV                0
          Cur LV                2
          Open LV               2
          Max PV                0
          Cur PV                1
          Act PV                1
          VG Size               30.00 GiB
          PE Size               4.00 MiB
          Total PE              7679
          Alloc PE / Size       768 / 3.00 GiB
          Free  PE / Size       6911 / 27.00 GiB
          VG UUID               W2JYeD-u2FD-h1Ff-vbLO-tB8f-JoLd-7rOMBw

          --- Volume group ---
          VG Name               c-dev-vg
          System ID
          Format                lvm2
          Metadata Areas        1
          Metadata Sequence No  3
          VG Access             read/write
          VG Status             resizable
          MAX LV                0
          Cur LV                2
          Open LV               1
          Max PV                0
          Cur PV                1
          Act PV                1
          VG Size               59.76 GiB
          PE Size               4.00 MiB
          Total PE              15298
          Alloc PE / Size       15298 / 59.76 GiB
          Free  PE / Size       0 / 0
          VG UUID               BgfMe0-DGIT-Pyq8-BXFo-5LgJ-XScZ-cdTCRH
        ```
        
    - Sau đó chạy `rejoin-stack`

          
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

#### Fix lỗi cho CINDER 
```sh
Fix lỗi Cinder
- Gõ lệnh dưới trước khi chạy .rejoin-stack

sudo losetup /dev/loop0 /opt/stack/data/stack-volumes-default-backing-file
sudo losetup /dev/loop1 /opt/stack/data/stack-volumes-lvmdriver-1-backing-file

```
 
### Cai dat devstack khi dung sau proxy

https://yapale.wordpress.com/2014/11/15/installing-devstack-behind-proxy/

http://www.rushiagr.com/blog/2014/08/05/devstack-behind-proxy/


- Khai báo dòng này để cài các gói offline nếu cần 
OFFLINE=True


- ODL 

https://gist.github.com/gvranganvtn


### Tham khảo
- http://ronaldbradford.com/blog/tag/devstack/
