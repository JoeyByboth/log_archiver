# Log Archiver Tool Overview

This project is inspired by [Roadmap.sh](https://roadmap.sh/projects/log-archive-tool). The primary goal is to create a useful tool for archiving logs and uploading them to a remote location (Amazon S3) automatically. It includes a retention period to maintain healthy disk space.

This tool is designed to be easily integrated into any existing environment and can be fine-tuned to meet your specific requirements. The project leverages Python, Bash, Terraform, and AWS.

The development was carried out in an Ubuntu container, ensuring compatibility with any Debian-based environment. 

## Setup Instructions

### Clone the Repository

Clone the repository to your desired directory:

```bash
git clone <url-to-repo> 
```
### Setup the Environment

Run the following script to bootstrap the environment:

```bash
bash setup.sh
```
#### Notes:
The base directory for the project is set to __/usr/local/bin/log_archiver__. You can edit this variable in the script if you wish to use a different location.
The setup will install the following:

    Apt Packages:
        - Python3
        - Python3-pip
        - Tar
        - Crontab
        - AWS CLI
        - Terraform

    Pip Packages:
        - Tarfile
        - Boto3
The cron jobs will also be created during this setup. By default, log archiving occurs at 2 AM and S3 uploads at 3 AM. You can update the schedule in the script as needed.


### Setup AWS

Run the following command to configure your AWS CLI:

```bash
aws configure
```

You will be prompted for your AWS access key and secret. For different approaches to authentication, refer to the AWS IAM documentation. 

### Setup Terraform and S3 Bucket

Navigate to the directory where you cloned the repo (not the project directory).
You can change the bucket name and region in the main.tf file. The provided Terraform configuration is for local development and testing purposes.

Initialize Terraform:

```bash
terraform init
```

Test your configuration:

```bash
terraform plan
```

Create the bucket:
```bash
terraform apply
```

### Test the Setup

The cron job created will default to archiving logs found in /var/log. If you want to specify a different directory, run the command:

```bash
python log_archiver.py /path/to/directory/
```

If you run this, it will default to /var/log. :
```bash
python log_archiver.py
```

Remember to update the cron jobs if you want to archive a specific directory.

The current retention period is set to 90 days, which you can adjust in the Python script.

__Important:__ The base directory used for cron jobs is the one specified in the setup. Make edits to the scripts in that directory, not in the directory where you cloned the repo. S3 Upload Script

The S3 upload script is straightforward; just run it. If you deviate from the provided base directory, make sure to update the ARCHIVE_BASE_DIR variable in the upload_logs_to_s3.py script accordingly.






