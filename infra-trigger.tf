resource "google_cloudbuild_trigger" "example" {
  project = "alert-flames-286515"
  name    = "Kubernetes-Playground-Trigger"
  disabled = false
  service_account = "projects/alert-flames-286515/serviceAccounts/cloudbuildaccount@alert-flames-286515.iam.gserviceaccount.com"

  trigger_template {
    repo_name   = "github_rjones18_gcp-kubernetes-cluster-playground"
    branch_name = "main"
  }
  filename = "cloudbuild.yaml"
}