#!/usr/bin/env bash
yum update -y
yum install -y wget curl vim

# 关闭防火墙
systemctl disable firewalld --now
# 关闭 selinux
setenforce 0
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
# 关闭 swap
swapoff -a
echo "vm.swappiness = 0">> /etc/sysctl.conf
sed -i 's/.*swap.*/#&/' /etc/fstab

sysctl -p

# 配置内核参数
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# 生效
sysctl --system

# 配置 yum 源
cd /etc/yum.repos.d
mv CentOS-Base.repo CentOS-Base.repo.bak
curl https://mirrors.aliyun.com/repo/Centos-7.repo -o CentOS-Base.repo
sed -i 's/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/CentOS-Base.repo
curl https://mirrors.aliyun.com/repo/epel-7.repo -o epel.repo
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O/etc/yum.repos.d/docker-ce.repo


cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 更新 yum 缓存
yum clean all
yum makecache
yum repolist

# 安装 docker
yum install -y docker-ce
systemctl enable docker && systemctl start docker

# 安装 k8s 相关组件
yum  -y install kubelet-1.16.2 kubeadm-1.16.2 kubectl-1.16.2 ipset
systemctl enable kubelet --now