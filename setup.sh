#!/bin/bash

# Define variables
BASE_DIR="/usr/local/bin/log_archiver"
ARCHIVER_SCRIPT_PATH="$BASE_DIR/log_archiver.py"
UPLOAD_SCRIPT_PATH="$BASE_DIR/upload_logs_to_s3.py"
ARCHIVER_CRON_JOB="0 2 * * * python3 $ARCHIVER_SCRIPT_PATH" #You can specify other log locations here too if desired.
UPLOAD_CRON_JOB="0 3 * * * python3 $UPLOAD_SCRIPT_PATH"
TERRAFORM_VERSION="latest"

# Create the base directory for the log archiver
echo "Creating directory $BASE_DIR..."
mkdir -p "$BASE_DIR"

# Update package list
echo "Updating package list..."
apt-get update

# Check for Python3 installation
if ! command -v python3 &> /dev/null; then
    echo "Python3 is not installed. Installing..."
    apt-get install -y python3 python3-pip
else
    echo "Python3 is already installed."
fi

# Check for tar installation
if ! command -v tar &> /dev/null; then
    echo "Tar is not installed. Installing..."
    apt-get install -y tar
else
    echo "Tar is already installed."
fi

# Check for crontab installation
if ! command -v crontab &> /dev/null; then
    echo "Crontab is not installed. Installing..."
    apt-get install -y cron
else
    echo "Crontab is already installed."
fi

# Check for AWS CLI installation
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Installing..."
    apt-get install -y awscli
else
    echo "AWS CLI is already installed."
fi

# Install Terraform
if ! command -v terraform &> /dev/null; then
    echo "Terraform is not installed. Installing..."
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
    echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt-get update
    apt-get install -y terraform
else
    echo "Terraform is already installed."
fi

# Check for required Python packages
echo "Checking for required Python packages..."
REQUIRED_PACKAGES=("tarfile" "boto3")  # Include boto3 for S3 uploads

for PACKAGE in "${REQUIRED_PACKAGES[@]}"; do
    if ! python3 -c "import $PACKAGE" &> /dev/null; then
        echo "$PACKAGE is not installed. Installing..."
        pip3 install "$PACKAGE"
    else
        echo "$PACKAGE is already installed."
    fi
done

# Move the Python scripts to the new directory
echo "Moving the Python scripts to $BASE_DIR..."
cp log_archiver.py "$ARCHIVER_SCRIPT_PATH"  # Ensure this script is in the current directory
cp upload_logs_to_s3.py "$UPLOAD_SCRIPT_PATH"  # Ensure this script is in the current directory

# Make the Python scripts executable
chmod +x "$ARCHIVER_SCRIPT_PATH"
chmod +x "$UPLOAD_SCRIPT_PATH"

# Add the cron jobs
echo "Setting up the cron jobs..."
(crontab -l 2>/dev/null; echo "$ARCHIVER_CRON_JOB") | crontab -
(crontab -l 2>/dev/null; echo "$UPLOAD_CRON_JOB") | crontab -

echo "Setup complete! The cron jobs have been added to run daily at 2 AM (log archiving) and 3 AM (uploading to S3)."
