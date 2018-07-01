# Note: will need to build the provider from source until 0.1.4 is released.
# See here: https://github.com/terraform-providers/terraform-provider-digitalocean
# Then copy the binary to .terraform.d/plugins/
#
#     $ cp $GOPATH/bin/terraform-provider-digitalocean \
#         ~/.terraform.d/plugins/terraform-provider-digitalocean_v0.1.4-pre
#
provider "digitalocean" {
  token       = "${var.do_token}"
  version     = "~> 0.1.4-pre"
}
