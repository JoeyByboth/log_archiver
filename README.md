# log_archiver

The idea for this project was taken from: https://roadmap.sh/projects/log-archive-tool

The goal was to make something useful for archiving logs and uploading them to a remote location (in this case, Amazon S3) in an automated fashion. I also wanted to include a rentention period to keep disk space healthy. This should be fairly simple to integrate into any existing environment and fine tuned to whatever requirements you may have. This project leverages Python, Bash, Terraform, and AWS. 

I built this entirely in an Ubuntu container so it should carry over to whichever environment you choose, as long as it's Debian based. 

Setup Instructions: 

Clone the Repository:
You can clone to any directory of your choice, we will be building a separate directory to host the tool during the next steps. 

Setup the Environment: 
Run bash setup.sh to bootstrap the environment. Here are some things to keep note of.

Base directory for the project is here: /usr/local/bin/log_archiver 
You can edit this variable in the script if you wish for it to be different. 

This will install the following:
Apt Packages:
Python3, Python3-pip 
Tar
Crontab
AWS CLI
Terraform

Pip Packages:
Tarfile
Boto 3

The cron jobs will be created here as well. Currently set for log archiving to happen at 2am and s3 upload at 3am. Update the variables in the script if you wish for this to be different. 

Setup AWS:
Run the following command: 
aws configure 

This will prompt for you input to your access key and secret. There are other ways to approach this so do what's best for you. This is the approach I used for development and I'm writing these instructions for local usage. 

If you do not know how to obtain these credentials, refer to AWS IAM documentation. 

Setup Terraform and S3 Bucket:

*Ensure you are in the directory you cloned the repo to, not directory of the project. 
You can change the bucket name and region in the main.tf file.
You do not need to use the provided Terraform, I just wanted to include it for local development purposes so you would have what you need to test full functionality. The method you create the bucket and upload files should be fine tuned to what works best for you. 

Initialize Terraform
terraform init 

Test your configuration: 
terraform plan

Create the bucket:
terraform apply

Test the Setup:

The Cron Job created will default to the logs found in /var/log and it will archive all of them. If you wish to specify a directory, the command to run will be:
python log_archiver.py /path/to/directory/

If you just run:
python log_archiver.py

It will default to /var/log 

Of course, you should update the cron jobs if you have a specific directory you want to archive. 

The current retention period is set to 90 days, you can change this variable in the python script. 

Remember the Base Directory is the one you are using for Cron, so your edits should be made to the scripts in there, not the directory you cloned the repo to. 

The S3 upload script is simple, you just run it. If you deviate from the Base Directory I provided, you need to update the variable, ARCHIVE_BASE_DIR, in the S3_upload.py script as well. 

