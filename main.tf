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

  
  metadata_startup_script = <<-EOT
    echo "k8s-control" | sudo tee /etc/hostname
    sudo hostname -F /etc/hostname
    cat <<'EOF' | sudo tee /etc/hosts
    127.0.0.1 localhost

    # The following lines are desirable for IPv6 capable hosts
    ::1 ip6-localhost ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    ff02::3 ip6-allhosts
    169.254.169.254 metadata.google.internal metadata

    10.128.0.21 k8s-control
    10.128.0.24 k8s-worker1
    10.128.0.14 k8s-worker2 EOF
    cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
    overlay
    br_netfilter EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter
    cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
    net.bridge.bridge-nf-call-iptables = 1
    net.ipv4.ip_forward                = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    EOF
    sudo sysctl --system
    sudo apt-get update
    sudo apt-get install -y containerd
    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo tee /etc/containerd/config.toml
    sudo systemctl restart containerd
    sudo swapoff -a
    sudo apt-get update && sudo apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
    EOF
    sudo apt-get update
    sudo apt-get install -y kubelet=1.27.0-00 kubeadm=1.27.0-00 kubectl=1.27.0-00
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.27.0
    sudo mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
  EOT

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

  metadata_startup_script = <<-EOT
    echo "k8s-worker1" | sudo tee /etc/hostname
    sudo hostname -F /etc/hostname
    cat << EOF | sudo tee /etc/hosts
    127.0.0.1 localhost

    # The following lines are desirable for IPv6 capable hosts
    ::1 ip6-localhost ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    ff02::3 ip6-allhosts
    169.254.169.254 metadata.google.internal metadata
    10.128.0.21 k8s-control
    10.128.0.24 k8s-worker1
    10.128.0.14 k8s-worker2
    EOF

    cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
    overlay
    br_netfilter
    EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter
    cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
    net.bridge.bridge-nf-call-iptables = 1
    net.ipv4.ip_forward                = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    EOF
    sudo sysctl --system
    sudo apt-get update
    sudo apt-get install -y containerd
    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo tee /etc/containerd/config.toml
    sudo systemctl restart containerd
    sudo swapoff -a
    sudo apt-get update && sudo apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
    EOF
    sudo apt-get update
    sudo apt-get install -y kubelet=1.27.0-00 kubeadm=1.27.0-00 kubectl=1.27.0-00
    sudo apt-mark hold kubelet kubeadm kubectl
  EOT

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

  metadata_startup_script = <<-EOT
    echo "k8s-worker1" | sudo tee /etc/hostname
    sudo hostname -F /etc/hostname
    cat << EOF | sudo tee /etc/hosts
    127.0.0.1 localhost

    # The following lines are desirable for IPv6 capable hosts
    ::1 ip6-localhost ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    ff02::3 ip6-allhosts
    169.254.169.254 metadata.google.internal metadata
    10.128.0.21 k8s-control
    10.128.0.24 k8s-worker1
    10.128.0.14 k8s-worker2
    EOF

    cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
    overlay
    br_netfilter
    EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter
    cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
    net.bridge.bridge-nf-call-iptables = 1
    net.ipv4.ip_forward                = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    EOF
    sudo sysctl --system
    sudo apt-get update
    sudo apt-get install -y containerd
    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo tee /etc/containerd/config.toml
    sudo systemctl restart containerd
    sudo swapoff -a
    sudo apt-get update && sudo apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
    EOF
    sudo apt-get update
    sudo apt-get install -y kubelet=1.27.0-00 kubeadm=1.27.0-00 kubectl=1.27.0-00
    sudo apt-mark hold kubelet kubeadm kubectl
  EOT

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}
