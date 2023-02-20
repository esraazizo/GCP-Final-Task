
resource "google_service_account" "my-svc-gke" {
  account_id = "my-svc-gke-account"
  display_name = "my-svc-gke-account"
}
resource "google_project_iam_member" "cluster" {
  role   = "roles/storage.objectViewer"
  
  member = "serviceAccount:${google_service_account.my-svc-gke.email}"
}

# --------------GKE---------------------------
resource "google_container_cluster" "my-gke" {
  name               = "esraa-cluster"
  location           = "us-east1-b"
  initial_node_count = "1"
  remove_default_node_pool = true
  network                  = google_compute_network.vpc.id
  subnetwork               = google_compute_subnetwork.restricted-subnet.id

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.32.0.0/14"
    services_ipv4_cidr_block = "10.2.0.0/16"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = google_compute_subnetwork.management-subnet.ip_cidr_range
      display_name = "sub1-cidr-range"
    }
  }
  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.16.0.0/28" 
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }
  }
}

#------------------------------------------------------------------

resource "google_container_node_pool" "my-gke-node-pool" {
  name = "esraa-node-pool"
  cluster = google_container_cluster.my-gke.id
  node_count = "1"
  location = "us-east1-b"

 node_config {
    preemptible  = true
    machine_type = "e2-small"

    service_account = google_service_account.my-svc-gke.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
     ]
  }
}
// to install plugin to fetsh the cluster "sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin"


