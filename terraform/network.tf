resource "openstack_networking_network_v2" "private_1" {
  name = "kubey_hole"
  admin_state_up = "true"
}

resource "openstack_networking_router_v2" "private_router" {
  name = "get_to_d_choppa"
  external_gateway = "${var.external_network}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  network_id = "${openstack_networking_network_v2.private_1.id}"
  cidr = "192.168.1.0/24"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "private_to_external" {
  router_id = "${openstack_networking_router_v2.private_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
}
