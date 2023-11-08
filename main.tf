resource "google_service_account" "default" {
  account_id   = "my-custom-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_compute_instance" "master_node" {
  count        = 1
  name         = "kubernetes-master-node"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts" # Ubuntu 20.04 LTS
      labels = {
        my_label = "value"
      }
    }
  }

  #   // Local SSD disk
  #   scratch_disk {
  #     interface = "NVME"
  #   }

  network_interface {
    network    = "default"
    network_ip = "10.128.0.21"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"    
  }

  

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}


resource "google_compute_instance" "worker_nodes1" {
  count        = 1 # Deploy 2 VMs
  name         = "kubernetes-vm-worker-1"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts" # Ubuntu 20.04 LTS
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  #   scratch_disk {
  #     interface = "NVME"
  #   }

  network_interface {
    network    = "default"
    network_ip = "10.128.0.24"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"
  }


  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "worker_nodes2" {
  count        = 1 # Deploy 2 VMs
  name         = "kubernetes-vm-worker-2"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts" # Ubuntu 20.04 LTS
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  #   scratch_disk {
  #     interface = "NVME"
  #   }

  network_interface {
    network    = "default"
    network_ip = "10.128.0.14"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}
