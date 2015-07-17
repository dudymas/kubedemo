resource "openstack_compute_keypair_v2" "kuberdemo-keypair" {
    name = "kuberdemo-keypair"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTySHW4gd005HhvjwvXHs7kc9G53FCM7YApL/NYrJrLnQEFOh5eOiEH4i3DedNV+bBtCGfl7ShPHKhPRqN1FKkQz3jRYbSx9rz3YBVr93yu8tsxr/4E4DkG118NEaUnYsQbl8EneT1R3N6SOOnV3n3Pi11Hj7QdtpCR6ireYIyT4OBIkYH/ZB3+jX6O/I51/WArhpZJ4Rt913kWznNkVAKn3CLVLyDX9bDqR8fhIPoaC3Du5KWm0/C+ZGssmruaFOCDexrsdScI5+R63MZbo6pKHuLcu6fpu70nyY/HLah36xwiJIxSljvO3uXDwVwEBFLrWax47PowvaYc7jp7jQD kuberdemo"
}

resource "openstack_compute_secgroup_v2" "kuberdemo" {
    name = "kuberdemo"
    description = "k8s demo communication permissions"
    rule {
        from_port = "-1"
        to_port = "-1"
        ip_protocol = "icmp"
        cidr = "0.0.0.0/0"
    }
    rule {
        from_port = "1"
        to_port = "65535"
        ip_protocol = "tcp"
        cidr = "0.0.0.0/0"
    }
}
