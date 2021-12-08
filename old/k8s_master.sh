#!/bin/bash

sudo kubeadm init --apiserver-advertise-address=192.168.50.11 --pod-network-cidr=192.168.50.0/24
