resource "digitalocean_droplet" "sg" {
  image              = "freebsd-11-1-x64-zfs"
  ipv6               = true
  name               = "gridns-sg"
  private_networking = true
  region             = "sgp1"
  size               = "s-1vcpu-1gb"
  ssh_keys           = "${var.do_ssh_keys}"
}
