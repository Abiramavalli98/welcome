terraform {
 required_version = ">= 1.0.0"


 required_providers {
   google = {
     source  = "hashicorp/google"
     version = "~> 5.0" # This will use the latest 5.x.x version
   }
 }
}


# 2. Configure the Google Cloud Provider
provider "google" {
 # Replace this with your actual GCP Project ID
 # Or use a variable like var.project_id
 project = "abi-project-431802"
  # Default region (matches the local.region in the previous code)
 region  = "us-central1"      
}
