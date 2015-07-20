resource "openstack_compute_floatingip_v2" "kuber-master" {
    pool = "${var.floatingip_pool}"
}

resource "template_file" "master-user-data" {
    filename = "./user-data"
    vars {
        machine_name = "kuberdemo-master"
        initial_cluster_token = "${var.initial_cluster_token}"
        public_ipv4 = "${openstack_compute_floatingip_v2.kuber-master.address}"
        initial_cluster = "kuberdemo-master=http://${openstack_compute_floatingip_v2.kuber-master.address}:2380,${join(",", template_file.kuber-address-lines.*.rendered)}"
        fleet_metadata = "master=true"
    }
}

resource "openstack_compute_instance_v2" "master" {
    name = "coreos-master"
    depends_on = [
        "openstack_compute_floatingip_v2.kuber-master"
    ]
    image_name = "${var.image}"
    flavor_name = "${var.flavor}"
    floating_ip = "${openstack_compute_floatingip_v2.kuber-master.address}"
    key_pair = "kuberdemo-keypair"
    security_groups = ["kuberdemo"]
    user_data = "${template_file.master-user-data.rendered}"
}
