resource "openstack_compute_floatingip_v2" "kuberdemo" {
    pool = "${var.floatingip_pool}"
    count = "${var.size}"
}

resource "template_file" "kuber-address-lines" {
    filename = "./address-line"
    count = "${var.size}"
    vars = {
        machine_num = "${count.index+1}"
        ip_address = "${element(openstack_compute_floatingip_v2.kuberdemo.*.address, count.index)}"
    }
}

resource "template_file" "kuberdemo-user-data" {
    filename = "./user-data"
    count = "${var.size}"
    vars = {
        machine_num = "${count.index+1}"
        initial_cluster_token = "${var.initial_cluster_token}"
        public_ipv4 = "${element(openstack_compute_floatingip_v2.kuberdemo.*.address, count.index)}"
        initial_cluster = "${join(",", template_file.kuber-address-lines.*.rendered)}"
    }
}

resource "openstack_compute_instance_v2" "etcd" {
    name = "coreos-${count.index+1}"
    count = "${var.size}"
    depends_on = [
        "openstack_compute_floatingip_v2.kuberdemo"
    ]
    image_name = "${var.image}"
    flavor_name = "${var.flavor}"
    floating_ip = "${element(openstack_compute_floatingip_v2.kuberdemo.*.address, count.index)}"
    key_pair = "kuberdemo-keypair"
    security_groups = ["kuberdemo"]
    user_data = "${element(template_file.kuberdemo-user-data.*.rendered, count.index)}"
}
