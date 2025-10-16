# Php, Nginx, and Mysql application
A webpage that displays a simple php.info. 
Tested with Terraform v1.13.3

## HLD (High Level Diagram)
![HLD](/images/HLD.png)

## Installation
Before installation, make sure to create an S3 bucket to store terraform state so you can include in your main.tf

<pre>
git clone https://github.com/artyomprima-cloud/Dataforest.git
cd /Dataforest
terraform init
terraform apply
</pre>

After terraform finishes installation you should see the cloudfront link to view php webpage in terraform output named "domain_name_uri".