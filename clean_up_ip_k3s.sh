#!/bin/bash

# go to network for k8s
cd /var/lib/cni/networks

# stop k3s and containerd
systemctl stop k3s
systemctl stop containerd

# move network folder
rm -rf cbr0.bak
mv cbr0/ cbr0.bak
mkdir cbr0

# start k3s and containerd process
systemctl start containerd
systemctl start k3s

# copy kubectl config file

mkdir -p ~/.kube && sudo install -T /etc/rancher/k3s/k3s.yaml ~/.kube/config -m 600 -o $USER
