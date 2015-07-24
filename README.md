
# Kubernetes demos and apps

This repo ultimately assumes you have an Openstack capable of running a CoreOS cluster with Kubernetes,
but that doesn't keep you from just skipping Openstack or CoreOS altogether.
If you just have a working CoreOS cluster, skip to Fleet deployment.
If you already have a working kubernetes cluster, skip to Pod deployment.

## Openstack Deployment of CoreOS

You'll want to step into terraform/ first. Set terraform.tfvars accordingly.
Then you'll need to set the ip of your openstack ip/host which allows api access.
Afterwards, you can source os_env, 
```
$ . ./os_env
```
and then terraform plan/apply to check things:
```
$ cd terraform
$ terraform plan
#check for sanity
$ terraform apply
```

## Fleet Deployment

First, check the fleet_env file and then source it when you feel it's setup right:
```
$ . ./fleet_env
```

Then you'll want to use the makefile or fleetctl depending on your confidence:
```
$ cd units
$ make kubeapi
# check for errors. you might need to run ```fleetctl journal --lines=150 kube-apiserver``` or other things.
$ make nodes
# In my case, I needed to deploy an openstack fix
$ make openstack-hostname-fix
# if you do end up needing to fix stuff, use this to restart kubelets:
$ make restart-nodes
# if you want to work with a private registry, I've started a few units. Try it out:
$ make registry
```

## Kubernetes Deployment

Make sure to set up a port tunnel with ssh:
```
$ ./kubectl-connect.sh
```

If that fails with the port being in use, you'll need to find and kill the offending ssh tunnel:
```
$ BAD_OL_PID=$(ps -e | grep ssh | grep 8080 | awk '{print $1}')
$ kill $BAD_OL_PID
$ ./kubectl-connect.sh #try try again!
```

Do a sanity check and make sure you see your nodes at this point:
```
$ kubectl get nodes
NAME                 LABELS                                      STATUS
coreos-1.novalocal   kubernetes.io/hostname=coreos-1.novalocal   Ready
coreos-2.novalocal   kubernetes.io/hostname=coreos-2.novalocal   Ready
coreos-3.novalocal   kubernetes.io/hostname=coreos-3.novalocal   Ready
coreos-4.novalocal   kubernetes.io/hostname=coreos-4.novalocal   Ready
```

Now head over to elasticsearch/ to start running with the elasticsearch demo on kubernetes v1.0.1:
```
$ cd elasticsearch/
$ make secret
$ make rc
# this next watch is optional.. when the pulls are complete, you can CTRL-C
$ watch -n .5 kubectl get events --namespace=logevents
# sanity check:
$ kubectl get pods --namespace=logevents
# if things fail you can use kubectl logs or just ssh in and docker logs on the containers
# after things settle down, make a service so you can have a VIP to route/balance with:
$ make service
# ???
$ echo 'Profit!'
```

## Testing it out

Just ssh into a kublet host (the master won't be able to see much) and
use this command to see the VIP's for your service:
```
$ kubelet get services --namespace=logevents
```

Make sure you get the namespace right. Just curl the VIP on port 9200 and go to town!
