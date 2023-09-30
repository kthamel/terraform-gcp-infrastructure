# terraform-gcp-infrastructure

Select the required GCP account to configure with SDK, use below command [Web browser is required]

gcloud init 

If previously configued the SDK with the GCP account, its possible to initialize withou the browser. Use below command.

gcloud init --console-only

Print the regions

gcloud compute regions list

Print the region of the currently working project

gcloud config list compute/region 

Set the region for the project, newly created without region

gcloud config set compute/region us-east1

