#!/bin/bash -e

mkdir -p /home/core/share/demo/bin

bins=( kubectl kubelet kube-proxy kube-apiserver kube-scheduler kube-controller-manager )
for b in "${bins[@]}"; do
	curl -L https://storage.googleapis.com/kubernetes-release/release/v1.0.0/bin/linux/amd64/$b > bin/$b
	chmod a+x bin/$b
done
