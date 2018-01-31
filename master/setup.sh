#!/bin/sudo bash

set -e
set -x

# install the kubernetes system containers
atomic install --system --system-package=no --name kube-apiserver registry.centos.org/centos/kubernetes-apiserver:latest
atomic install --system --system-package=no --name kube-scheduler registry.centos.org/centos/kubernetes-scheduler:latest
atomic install --system --system-package=no --name kube-controller-manager registry.centos.org/centos/kubernetes-controller-manager:latest

# deploy a local docker registry mirror
docker create -p 5000:5000 -v /var/lib/local-registry:/var/lib/registry -e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/var/lib/registry -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io --name=local-registry registry:2
mkdir -p /var/lib/local-registry
chcon -Rvt svirt_sandbox_file_t /var/lib/local-registry
cp /tmp/master_config/local-registry.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable local-registry.service
systemctl start local-registry.service

# configure and start etcd
cp /tmp/master_config/etcd.conf /etc/etcd/etcd.conf
systemctl enable etcd
systemctl start etcd

# configure and start flanneld
cat <<EOF > flanneld-conf.json
{
  "Network": "172.16.0.0/12",
  "SubnetLen": 24,
  "Backend": {
    "Type": "vxlan"
  }
}
EOF
curl -L http://localhost:2379/v2/keys/atomic.io/network/config -XPUT --data-urlencode value@flanneld-conf.json
curl -L http://localhost:2379/v2/keys/atomic.io/network/config | python -m json.tool
systemctl enable flanneld.service
systemctl start flanneld.service
rm -f flanneld-conf.json

# configure and start the kubernetes services
cp /tmp/master_config/kube-config /etc/kubernetes/config
cp /tmp/master_config/kube-apiserver /etc/kubernetes/apiserver
systemctl start kube-apiserver
systemctl start kube-scheduler
systemctl start kube-controller-manager

# give them some time to start
sleep 5s

# see if all the expected services are running and listening on the correct
# ports
ss -tulnp | grep -E "(kube)|(etcd)|(docker)"
