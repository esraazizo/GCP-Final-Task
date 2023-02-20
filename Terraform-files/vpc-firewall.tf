resource "google_compute_network" "vpc" {
  name = "vpc-esraa"
  auto_create_subnetworks = false
}

#-----------------------------------------------------------------
 
resource "google_compute_firewall" "my-firewall" {
  name    = "esraa-firewall"
  network = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22" , "80"]
  }
}