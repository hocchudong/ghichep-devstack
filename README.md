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

### VOLUME - CINDER

- Mặc định thì devstack sẽ tạo ra ổ loop để cài đặt cinder volume. Nếu muốn sử dụng ổ sdb, sdc ... thì cần thực hiện như sau
 - Thêm ổ cứng thứ 2 cho máy cài devstack, trong hướng dẫn này sử dụng là vdb
 - Cấu hình lvm cho ổ cứng thứ 2 này, với tên volume là stack-volume
 
 ```sh
 pvcreate /dev/sdc
 vgcreate stack-volumes /dev/sdc
 ```
 - Khai báo trong file local.conf đoạn sau
 ```sh
 ....
 VOLUME_GROUP="stack-volumes"
 ```
 

### Cai dat devstack khi dung sau proxy

https://yapale.wordpress.com/2014/11/15/installing-devstack-behind-proxy/

http://www.rushiagr.com/blog/2014/08/05/devstack-behind-proxy/


- Khai báo dòng này để cài các gói offline nếu cần 
OFFLINE=True
