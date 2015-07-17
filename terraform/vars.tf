variable "size" {
    default = 3
}
variable "floatingip_pool" {
    default = "nova"
}
variable "image" {
    default = "CoreOS-alpha"
}
variable "flavor" {
    default = "m1.small"
}
variable "tenant_name" {
    default = "kuberdemo"
}
variable "initial_cluster_token" {}
