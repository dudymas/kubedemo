<!-- BEGIN MUNGE: UNVERSIONED_WARNING -->

<!-- BEGIN STRIP_FOR_RELEASE -->

<img src="http://kubernetes.io/img/warning.png" alt="WARNING"
     width="25" height="25">
<img src="http://kubernetes.io/img/warning.png" alt="WARNING"
     width="25" height="25">
<img src="http://kubernetes.io/img/warning.png" alt="WARNING"
     width="25" height="25">
<img src="http://kubernetes.io/img/warning.png" alt="WARNING"
     width="25" height="25">
<img src="http://kubernetes.io/img/warning.png" alt="WARNING"
     width="25" height="25">

<h2>PLEASE NOTE: This document applies to the HEAD of the source tree</h2>

If you are using a released version of Kubernetes, you should
refer to the docs that go with that version.

<strong>
The latest 1.0.x release of this document can be found
[here](http://releases.k8s.io/release-1.0/examples/elasticsearch/README.md).

Documentation for other releases can be found at
[releases.k8s.io](http://releases.k8s.io).
</strong>
--

<!-- END STRIP_FOR_RELEASE -->

<!-- END MUNGE: UNVERSIONED_WARNING -->

# Elasticsearch for Kubernetes

This directory contains the source for a Docker image that creates an instance
of [Elasticsearch](https://www.elastic.co/products/elasticsearch) 1.5.2 which can 
be used to automatically form clusters when used
with [replication controllers](../../docs/user-guide/replication-controller.md). This will not work with the library Elasticsearch image
because multicast discovery will not find the other pod IPs needed to form a cluster. This
image detects other Elasticsearch [pods](../../docs/user-guide/pods.md) running in a specified [namespace](../../docs/user-guide/namespaces.md) with a given
label selector. The detected instances are used to form a list of peer hosts which
are used as part of the unicast discovery mechansim for Elasticsearch. The detection
of the peer nodes is done by a program which communicates with the Kubernetes API
server to get a list of matching Elasticsearch pods. To enable authenticated
communication this image needs a [secret](../../docs/user-guide/secrets.md) to be mounted at `/etc/apiserver-secret`
with the basic authentication username and password.

Here is an example replication controller specification that creates 4 instances of Elasticsearch which is in the file
[eventstream-rc.yaml](eventstream-rc.yaml).

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  labels:
    name: eventstream-db
    namespace: logevents
  name: eventstream-db
spec:
  replicas: 4
  selector:
    name: eventstream-db
  template:
    metadata:
      labels:
         name: eventstream-db
    spec:
      containers:
      - name: es
        image: kubernetes/elasticsearch:1.0
        env:
          - name: "CLUSTER_NAME"
            value: "logevents-db"
          - name: "SELECTOR"
            value: "name=eventstream-db"
          - name: "NAMESPACE"
            value: "mytunes"
        ports:
        - name: es
          containerPort: 9200
        - name: es-transport
          containerPort: 9300
        volumeMounts:
        - name: apiserver-secret
          mountPath: /etc/apiserver-secret
          readOnly: true
      volumes:
      - name: apiserver-secret
        secret:
          secretName: apiserver-secret
```

The `CLUSTER_NAME` variable gives a name to the cluster and allows multiple separate clusters to
exist in the same namespace.
The `SELECTOR` variable should be set to a label query that identifies the Elasticsearch
nodes that should participate in this cluster. For our example we specify `name=eventstream-db` to
match all pods that have the label `name` set to the value `eventstream-db`.
The `NAMESPACE` variable identifies the namespace
to be used to search for Elasticsearch pods and this should be the same as the namespace specified
for the replication controller (in this case `mytunes`). 

Before creating pods with the replication controller a secret containing the bearer authentication token
should be set up. A template is provided in the file [apiserver-secret.yaml](apiserver-secret.yaml):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: apiserver-secret
  namespace: NAMESPACE
data:
  token: "TOKEN"
```

Replace `NAMESPACE` with the actual namespace to be used and `TOKEN` with the basic64 encoded
versions of the bearer token reported by `kubectl config view` e.g.

```console
$ kubectl config view
...
- name: kubernetes-logging_kubernetes-basic-auth
...
  token: yGlDcMvSZPX4PyP0Q5bHgAYgi1iyEHv2
 ...   
$ echo yGlDcMvSZPX4PyP0Q5bHgAYgi1iyEHv2 | base64
eUdsRGNNdlNaUFg0UHlQMFE1YkhnQVlnaTFpeUVIdjIK=
```

resulting in the file:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: apiserver-secret
  namespace: mytunes
data:
  token: "eUdsRGNNdlNaUFg0UHlQMFE1YkhnQVlnaTFpeUVIdjIK="
```

which can be used to create the secret in your namespace:

```console
kubectl create -f examples/elasticsearch/apiserver-secret.yaml --namespace=mytunes
secrets/apiserver-secret
```

Now you are ready to create the replication controller which will then create the pods:

```console
$ kubectl create -f examples/elasticsearch/eventstream-rc.yaml --namespace=mytunes
replicationcontrollers/eventstream-db
```

It's also useful to have a [service](../../docs/user-guide/services.md) with an load balancer for accessing the Elasticsearch
cluster which can be found in the file [eventstream-service.yaml](eventstream-service.yaml).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: eventstream-server
  namespace: mytunes
  labels:
    name: eventstream-db
spec:
  selector:
    name: eventstream-db
  ports:
  - name: db
    port: 9200
    targetPort: es
  type: LoadBalancer
```

Let's create the service with an external load balancer:

```console
$ kubectl create -f examples/elasticsearch/eventstream-service.yaml --namespace=mytunes
services/eventstream-server
```

Let's see what we've got:

```console
$ kubectl get pods,rc,services,secrets --namespace=mytunes

NAME             READY     STATUS    RESTARTS   AGE
eventstream-db-cl4hw   1/1       Running   0          27m
eventstream-db-x8dbq   1/1       Running   0          27m
eventstream-db-xkebl   1/1       Running   0          27m
eventstream-db-ycjim   1/1       Running   0          27m
CONTROLLER   CONTAINER(S)   IMAGE(S)                       SELECTOR        REPLICAS
eventstream-db     es             kubernetes/elasticsearch:1.0   name=eventstream-db   4
NAME           LABELS          SELECTOR        IP(S)            PORT(S)
eventstream-server   name=eventstream-db   name=eventstream-db   10.0.45.177      9200/TCP
                                               104.197.12.157
NAME                  TYPE                                      DATA
apiserver-secret      Opaque                                    1
```

This shows 4 instances of Elasticsearch running. After making sure that port 9200 is accessible for this cluster (e.g. using a firewall rule for Google Compute Engine) we can make queries via the service which will be fielded by the matching Elasticsearch pods.

```console
$ curl 104.197.12.157:9200
{
  "status" : 200,
  "name" : "Warpath",
  "cluster_name" : "mytunes-db",
  "version" : {
    "number" : "1.5.2",
    "build_hash" : "62ff9868b4c8a0c45860bebb259e21980778ab1c",
    "build_timestamp" : "2015-04-27T09:21:06Z",
    "build_snapshot" : false,
    "lucene_version" : "4.10.4"
  },
  "tagline" : "You Know, for Search"
}
$ curl 104.197.12.157:9200
{
  "status" : 200,
  "name" : "Callisto",
  "cluster_name" : "mytunes-db",
  "version" : {
    "number" : "1.5.2",
    "build_hash" : "62ff9868b4c8a0c45860bebb259e21980778ab1c",
    "build_timestamp" : "2015-04-27T09:21:06Z",
    "build_snapshot" : false,
    "lucene_version" : "4.10.4"
  },
  "tagline" : "You Know, for Search"
}
```

We can query the nodes to confirm that an Elasticsearch cluster has been formed.

```console
$ curl 104.197.12.157:9200/_nodes?pretty=true
{
  "cluster_name" : "mytunes-db",
  "nodes" : {
    "u-KrvywFQmyaH5BulSclsA" : {
      "name" : "Jonas Harrow",
...
        "discovery" : {
          "zen" : {
            "ping" : {
              "unicast" : {
                "hosts" : [ "10.244.2.48", "10.244.0.24", "10.244.3.31", "10.244.1.37" ]
              },
...
      "name" : "Warpath",
...
        "discovery" : {
          "zen" : {
            "ping" : {
              "unicast" : {
                "hosts" : [ "10.244.2.48", "10.244.0.24", "10.244.3.31", "10.244.1.37" ]
              },
...
        "name" : "Callisto",
...
        "discovery" : {
          "zen" : {
            "ping" : {
              "unicast" : {
                "hosts" : [ "10.244.2.48", "10.244.0.24", "10.244.3.31", "10.244.1.37" ]
              },
...
      "name" : "Vapor",
...
        "discovery" : {
          "zen" : {
            "ping" : {
              "unicast" : {
                "hosts" : [ "10.244.2.48", "10.244.0.24", "10.244.3.31", "10.244.1.37" ]
...
```

Let's ramp up the number of Elasticsearch nodes from 4 to 10:

```console
$ kubectl scale --replicas=10 replicationcontrollers eventstream-db --namespace=mytunes
scaled
$ kubectl get pods --namespace=mytunes
NAME             READY     STATUS    RESTARTS   AGE
eventstream-db-063vy   1/1       Running   0          38s
eventstream-db-5ej4e   1/1       Running   0          38s
eventstream-db-dl43y   1/1       Running   0          38s
eventstream-db-lw1lo   1/1       Running   0          1m
eventstream-db-s8hq2   1/1       Running   0          38s
eventstream-db-t98iw   1/1       Running   0          38s
eventstream-db-u1ru3   1/1       Running   0          38s
eventstream-db-wnss2   1/1       Running   0          1m
eventstream-db-x7j2w   1/1       Running   0          1m
eventstream-db-zjqyv   1/1       Running   0          1m
```

Let's check to make sure that these 10 nodes are part of the same Elasticsearch cluster:

```console
$ curl 104.197.12.157:9200/_nodes?pretty=true | grep name
"cluster_name" : "mytunes-db",
      "name" : "Killraven",
        "name" : "Killraven",
          "name" : "mytunes-db"
        "vm_name" : "OpenJDK 64-Bit Server VM",
          "name" : "eth0",
      "name" : "Tefral the Surveyor",
        "name" : "Tefral the Surveyor",
          "name" : "mytunes-db"
        "vm_name" : "OpenJDK 64-Bit Server VM",
          "name" : "eth0",
      "name" : "Jonas Harrow",
        "name" : "Jonas Harrow",
          "name" : "mytunes-db"
        "vm_name" : "OpenJDK 64-Bit Server VM",
          "name" : "eth0",
      "name" : "Warpath",
        "name" : "Warpath",
          "name" : "mytunes-db"
        "vm_name" : "OpenJDK 64-Bit Server VM",
          "name" : "eth0",
      "name" : "Brute I",
        "name" : "Brute I",
          "name" : "mytunes-db"
        "vm_name" : "OpenJDK 64-Bit Server VM",
          "name" : "eth0",
      "name" : "Callisto",
        "name" : "Callisto",
          "name" : "mytunes-db"
        "vm_name" : "OpenJDK 64-Bit Server VM",
          "name" : "eth0",
      "name" : "Vapor",
        "name" : "Vapor",
          "name" : "mytunes-db"
        "vm_name" : "OpenJDK 64-Bit Server VM",
          "name" : "eth0",
      "name" : "Timeslip",
        "name" : "Timeslip",
          "name" : "mytunes-db"
        "vm_name" : "OpenJDK 64-Bit Server VM",
          "name" : "eth0",
      "name" : "Magik",
        "name" : "Magik",
          "name" : "mytunes-db"
        "vm_name" : "OpenJDK 64-Bit Server VM",
          "name" : "eth0",
      "name" : "Brother Voodoo",
        "name" : "Brother Voodoo",
          "name" : "mytunes-db"
        "vm_name" : "OpenJDK 64-Bit Server VM",
          "name" : "eth0",
```


<!-- BEGIN MUNGE: GENERATED_ANALYTICS -->
[![Analytics](https://kubernetes-site.appspot.com/UA-36037335-10/GitHub/examples/elasticsearch/README.md?pixel)]()
<!-- END MUNGE: GENERATED_ANALYTICS -->
