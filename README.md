# terraform-gcp-infrastructure

Select the required GCP account to configure with SDK, use below command [Web browser is required]

gcloud init 

If previously configued the SDK with the GCP account, its possible to initialize withou the browser. Use below command.

gcloud init --console-only

Print the regions

gcloud compute regions list

Print the AZs

gcloud compute zones list

Print the region of the currently working project

gcloud config list compute/region 

Set the region for the project, newly created without region

gcloud config set compute/region us-east1

Set the AZ for the project, according to the selected region from above

gcloud config set compute/zone us-east1-b

List authorized accounts to the project 

gcloud auth list

Change the active account 

gcloud config set account kthamel.ptg@gmail.com

Switch to the default account configurations

gcloud config configurations activate default

List available components

gcloud components list

Install new component from above list

gcloud components install COMPONENT_ID

Remove components installed from above list

gcloud components removes COMPONENT_ID

