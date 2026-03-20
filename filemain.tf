terraform {
 required_providers {
   google = {
     source  = "hashicorp/google"
     version = "~> 5.0"
   }
 }
}


provider "google" {
 project = var.project_id
 region  = var.region
}
# 1. Enable necessary APIs (Cloud Build, Cloud Run, Artifact Registry, etc.)
resource "google_project_service" "required_apis" {
 for_each = toset([
   "sourcerepo.googleapis.com",
   "artifactregistry.googleapis.com",
   "cloudbuild.googleapis.com",
   "run.googleapis.com",
   "iam.googleapis.com",
   "logging.googleapis.com"
 ])
 service            = each.key
 disable_on_destroy = false
}


# 2. Cloud Source Repository (CSR)
resource "google_sourcerepo_repository" "repo" {
 name       = "my-app-reponew"
 depends_on =[google_project_service.required_apis]
}


# 3. Artifact Registry for Docker Images
resource "google_artifact_registry_repository" "registry" {
 location      = var.region
 repository_id = "my-app-registrynew"
 description   = "Docker repository for Cloud Run images"
 format        = "DOCKER"
 depends_on    = [google_project_service.required_apis]
}


# 4. User-Managed Service Account for Cloud Build (Fixes your previous error)
resource "google_service_account" "build_sa" {
 account_id   = "cicd-build-sa"
 display_name = "CI/CD Cloud Build Service Account"
}


# Grant necessary permissions to the Build Service Account
resource "google_project_iam_member" "build_sa_roles" {
 for_each = toset([
   "roles/logging.logWriter",            # Required to write build logs
   "roles/artifactregistry.writer",      # Required to push Docker images
   "roles/run.developer",                # Required to deploy to Cloud Run
   "roles/iam.serviceAccountUser",       # Required to act as the Cloud Run runtime SA
   "roles/source.reader"                 # <--- ADD THIS LINE: Required to clone the Source Repository
 ])
 project = var.project_id
 role    = each.key
 member  = "serviceAccount:${google_service_account.build_sa.email}"
}


# 5. Cloud Run Service (Baseline)
# Note: We use a dummy image initially. Cloud Build will overwrite this.
resource "google_cloud_run_v2_service" "app" {
 name     = "my-app-servicenew"
 location = var.region
 ingress  = "INGRESS_TRAFFIC_ALL"


 template {
   containers {
     # Placeholder image for initial creation
     image = "us-docker.pkg.dev/cloudrun/container/hello"
   }
 }


 # This prevents Terraform from reverting the image back to the placeholder
 # next time you run `terraform apply` after Cloud Build has deployed a new version.
 lifecycle {
   ignore_changes = [
     template[0].containers[0].image,
     client,
     client_version
   ]
 }
 depends_on = [google_project_service.required_apis]
}
# 6. Cloud Build Trigger
resource "google_cloudbuild_trigger" "trigger" {
 name        = "my-app-main-triggernew"
 description = "Trigger to build and deploy to Cloud Run on push to main"


 trigger_template {
   branch_name = "^main$"
   repo_name   = google_sourcerepo_repository.repo.name
 }


 # Explicitly using the user-managed service account configured above!
 service_account = google_service_account.build_sa.id


 # Inline build configuration (cloudbuild.yaml equivalent)
 build {
   # Step 1: Build the Docker Image
   step {
     name = "gcr.io/cloud-builders/docker"
     args =[
       "build",
       "-t",
       "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.registry.name}/my-app:$COMMIT_SHA",
       "."
     ]
   }
   # Step 2: Push the Docker Image to Artifact Registry
   step {
     name = "gcr.io/cloud-builders/docker"
     args =[
       "push",
       "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.registry.name}/my-app:$COMMIT_SHA"
     ]
   }
   # Step 3: Deploy to Cloud Run
   step {
     name       = "gcr.io/google.com/cloudsdktool/cloud-sdk"
     entrypoint = "gcloud"
     args =[
       "run",
       "deploy",
       google_cloud_run_v2_service.app.name,
       "--image",
       "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.registry.name}/my-app:$COMMIT_SHA",
       "--region",
       var.region,
       "--project",
       var.project_id
     ]
   }
   options {
     logging = "CLOUD_LOGGING_ONLY"
   }
 }


 depends_on =[
   google_project_iam_member.build_sa_roles
 ]
}
