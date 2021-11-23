#!/bin/bash

# update
sudo yum -y update

# install utils
sudo yum -y install net-tools

# install packages
sudo yum -y install epel-release vim git curl wget kubelet kubeadm kubectl --disableexcludes=kubernetes

# disable SELinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

# disable swap memory
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a


# iptables이 bridge의 트래픽을 보도록 설정
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/k8s.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system


# container runtime은 containerd 사용
# dockershim은 depreacted 될거고 결국 docker도 containerd를 사용한다.
# install depencency
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y && yum install -y containerd.io

sudo mkdir -p /etc/containerd
sudo containerd config default > /etc/containerd/config.toml


# install kubernetes
sudo tee /etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet


# firewall 끈다. 어짜피 내부 VM 이니까..
# 켜고 port 개방 할거면
# https://kubernetes.io/docs/reference/ports-and-protocols/
# 참고하여 master, worker 에 따라 열면 된다.
sudo systemctl disable --now firewalld

