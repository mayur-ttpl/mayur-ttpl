#calling scipt from script folder
data "template_file" "shell-script" {
  template = "${file("${path.module}/script/config.sh")}"
  /*vars = {
    consul_address = "${aws_instance.consul.private_ip}"
  }*/
}

data "template_cloudinit_config" "config" {
  gzip = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}