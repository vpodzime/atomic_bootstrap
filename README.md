# Atomic Bootstrap

Vagrant definitions, config files and shell scripts to deploy a simple
Atomic-based cluster. Heavily inspired by
http://www.projectatomic.io/docs/gettingstarted/

## Steps to setup a cluster

1. `export NODES=4` or any other desired number of nodes
2. `vagrant up master` to deploy a master VM
3. `vagrant up` to deploy the nodes
4. `vagrant ssh master`
5. `kubectl get node` to see if the cluster is properly set up

## Disclaimer

**This is in no way meant to be a production-ready solution! Among the other
  issues, all security mechanisms of the cluster are disabled.**