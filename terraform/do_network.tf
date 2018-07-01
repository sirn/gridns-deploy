resource "digitalocean_floating_ip" "sg" {
  droplet_id = "${digitalocean_droplet.sg.id}"
  region     = "${digitalocean_droplet.sg.region}"
}
