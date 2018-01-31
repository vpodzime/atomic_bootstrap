#!/bin/sudo bash

set -e
set -x

node_ip=$1

test -n "$node_ip"

cp /tmp/node_config/docker /etc/sysconfig/docker
cp /tmp/node_config/flanneld /etc/sysconfig/flanneld
cp /tmp/node_config/kube-kubelet /etc/kubernetes/kubelet
sed -ri "s/@NODE_IP@/${node_ip}/g" /etc/kubernetes/kubelet
cp /tmp/node_config/kube-config /etc/kubernetes/config

systemctl enable flanneld kubelet kube-proxy
systemctl start flanneld kubelet kube-proxy
systemctl status flanneld kubelet kube-proxy
