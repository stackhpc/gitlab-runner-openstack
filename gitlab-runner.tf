terraform {
  required_version = ">= 0.14"

  # We need the OpenStack provider
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}


variable "name" {
  type = string
  description = "The name of the runner, used in resource names."
  default = "gitlab-runner"
}

variable "image_id" {
  type = string
  description = "The ID of an Ubuntu 20.04 image to use for the runner."
}

variable "flavor_name" {
  type = string
  description = "The name of the flavor to use for the runner."
}

variable "network_id" {
  type = string
  description = "The ID of the network to attach the runner to."
}

variable "docker_bip" {
  type = string
  description = "The CIDR to use for the Docker bridge."
  default = "172.17.0.1/16"
}

variable "gitlab_host" {
  type = string
  description = "The host of the GitLab server to connect to."
}

variable "scheme" {
  type = string
  description = "The scheme to use for the GitLab server."
  default = "https"
}

variable "registration_token" {
  type = string
  description = "The registration token to use when registering the runner."
}

variable "ca_file" {
  type = string
  description = "Path to a custom CA to use, if required."
  default = ""
}

variable "docker_image" {
  type = string
  description = "Default Docker image for the executor."
  default = "ubuntu:focal"
}

variable "docker_network_mode" {
  type = string
  description = "The Docker network mode to use for the executor. One of 'bridge' or 'host'."
  default = "host"
}

variable "docker_privileged" {
  type = bool
  description = "Indicates whether to use privileged containers for the executor."
  default = false
}

variable "register_extra_args" {
  type = string
  description = "Extra command line arguments for the 'gitlab-runner register' command."
  default = ""
}


resource "openstack_networking_secgroup_v2" "secgroup" {
  name                 = var.name
  delete_default_rules = true   # Fully manage with terraform
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_compute_instance_v2" "node" {
  name      = var.name
  image_id  = var.image_id
  flavor_name = var.flavor_name

  network {
    uuid = var.network_id
  }

  security_groups = ["${openstack_networking_secgroup_v2.secgroup.name}"]

  user_data = templatefile(
    "${path.root}/install.sh.tftpl",
    {
      name = var.name,
      docker_bip = var.docker_bip,
      gitlab_host = var.gitlab_host,
      scheme = var.scheme,
      registration_token = var.registration_token,
      ca_file = var.ca_file,
      docker_image = var.docker_image,
      docker_network_mode = var.docker_network_mode,
      docker_privileged = var.docker_privileged,
      register_extra_args = var.register_extra_args
    }
  )
}
