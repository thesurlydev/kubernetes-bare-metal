

## cluster topology

nuc1 (192.168.7.121) - kubernetes controller
nuc2 (192.168.7.122) - worker node
nuc3 (192.168.7.123) - worker node
nuc4 (192.168.7.124) - worker node


## all nodes

Assuming 500GB disk: 
    - partition 100GB with `ext4` and mount at `/`
    - partition remaining space but leave unformatted and unmounted.

Install Ubuntu 18.04.4 server:
    - install openssh and nothing else.


## controller

```
./01_os-docker-init.sh
./02_k8s-init.sh
./03_kubeadm-init.sh
./04_kubeadm-post-init.sh
./05_weave-network-install.sh
./06_dashboard-install.sh
./07-dashboard-bearer-token.sh
./08_countour-install.sh
./09_rook-ceph-install.sh
```


## worker nodes

```
./01_os-docker-init.sh
./02_k8s-init.sh
./03_copy-kube-config.sh
./10_cluster-join.sh
```