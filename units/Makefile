.PHONY: kubeapi nodes openstack-hostname-fix registry

kubeapi:
	fleetctl start master/*
	sleep 1
	fleetctl list-units

reset-kubeapi:
	fleetctl destroy master/*
	fleetctl start master/*

openstack-hostname-fix:
	fleetctl start fixes/hosts.service
	sleep 1
	fleetctl list-units

nodes:
	fleetctl start worker/*
	sleep 1
	fleetctl list-units

restart-nodes:
	fleetctl stop worker/*
	fleetctl start worker/*
	sleep 1
	fleetctl list-units

registry:
	fleetctl start registry/registry-config.service
	sleep 1
	[ ! "$$(fleetctl list-units | grep registry-config | grep failed)" = "" ] && exit(1)
	fleetctl start registry/*
	sleep 1
	fleetctl list-units
