"""
  We define 2 main part:
    1. Filewall rule cho phép gọi vào port 8080
    2. VM với 1 cái public ip-address
"""

provider "google" { 
    project = "care-dataservice"
    region = "us-central1"
}

#1. Filewall rule cho phép gọi vào port 8080
resource "google_compute_firewall" "firewall" {
  name    = "test-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_ranges = ["0.0.0.0/0"]

  source_tags = ["web"]
}

resource "google_compute_network" "default" {
  name = "test-network"
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
              nohup busybox httpd -f -p 8080 &
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

  depends_on = [ google_compute_firewall.firewall ]
}