

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




## worker nodes