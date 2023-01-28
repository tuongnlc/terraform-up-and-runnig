/*
    We define 2 main part:
    1. Filewall rule cho phép gọi vào port 8080
    2. VM với 1 cái public ip-address
    3. Chúng ta sử dụng variable từ file variables.tf
*/

provider "google" { 
    project = "care-dataservice"
    region = "us-central1"
}

#1. Filewall rule cho phép gọi vào port 8080
resource "google_compute_firewall" "firewall" {
  name    = var.firewall_rule
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [var.server_port]
  }

  source_ranges = ["0.0.0.0/0"]

  source_tags = ["web"]
}

#2. 2. VM với 1 cái public ip-address
resource "google_compute_address" "static" {
  name = "ipv4-address"
}


resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  metadata_startup_script = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }
  #Chỗ này là define public ip-address
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    foo = "bar"
  }  

  #Depends_on này là cái vm sẽ sử dụng firewall rule ở trên.
  depends_on = [ google_compute_firewall.firewall ]
}