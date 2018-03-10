resource "google_compute_instance" "controller" {
  name = "controller-${count.index}"
  machine_type = "n1-standard-1"
  can_ip_forward = "true"

  tags = ["controller", "kube-thw"]

  boot_disk {
    initialize_params {
      size  = 20
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.kube-thw-subnet-a.name}"
    address = "10.240.0.1${count.index}"
    access_config {}
  }

  service_account {
    scopes = ["compute-rw","storage-ro","service-management","service-control","logging-write","monitoring"]
  }

  count = 3
}

resource "google_compute_instance" "worker" {
  name = "worker-${count.index}"
  machine_type = "n1-standard-1"
  can_ip_forward = "true"

  tags = ["worker", "kube-thw"]

  boot_disk {
    initialize_params {
      size  = 20
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.kube-thw-subnet-a.name}"
    address = "10.240.0.2${count.index}"
    access_config {}
  }

  service_account {
    scopes = ["compute-rw","storage-ro","service-management","service-control","logging-write","monitoring"]
  }

  metadata {
    pod-cidr = "10.200.${count.index}.0/24"
  }

  count = 3
}

resource "google_compute_target_pool" "kube-thw" {
  name = "kube-thw-pool"

  instances = ["${google_compute_instance.controller.*.self_link}"]
}

resource "google_compute_forwarding_rule" "kube-thw-apiserver" {
  name       = "kube-thw-apiserver"
  target     = "${google_compute_target_pool.kube-thw.self_link}"
  ip_address = "${google_compute_address.kube-thw.address}"
  port_range = "6443"
}
