resource "google_compute_network" "kube-thw" {
  name                    = "kube-thw"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "kube-thw-subnet-a" {
  name = "kube-thw-subnet-a"
  network = "${google_compute_network.kube-thw.name}"
  ip_cidr_range = "10.240.0.0/24"
}

resource "google_compute_firewall" "kube-thw-allow-internal" {
  name = "kube-thw-allow-internal"
  network = "${google_compute_network.kube-thw.name}"

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }

  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]
}

resource "google_compute_firewall" "kube-thw-allow-external" {
  name = "kube-thw-allow-external"
  network = "${google_compute_network.kube-thw.name}"

  allow {
    protocol = "tcp"
    ports    =  [22, 6443]
  }
  allow { protocol = "icmp" }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "kube-thw-allow-nginx-service" {
  name = "kube-thw-allow-nginx-service"
  network = "${google_compute_network.kube-thw.name}"

  allow {
    protocol = "tcp"
    ports    =  [31596]
  }
}

resource "google_compute_address" "kube-thw" {
  name = "kube-thw"
}

resource "google_compute_route" "kube-pod-route" {
  name        = "kube-pod-route-10-200-${count.index}-0-24"
  network     = "${google_compute_network.kube-thw.name}"

  dest_range  = "10.200.${count.index}.0/24"
  next_hop_ip = "10.240.0.2${count.index}"
  priority    = 100

  count = 3
}
