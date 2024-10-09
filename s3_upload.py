import os
import boto3
from botocore.exceptions import NoCredentialsError

# Define your S3 bucket and the local archive directory
S3_BUCKET = "log-archiver-bucket"  # Replace with your S3 bucket name
ARCHIVE_BASE_DIR = "/usr/local/bin/log_archiver/archives"

def upload_to_s3(file_name):
    s3_client = boto3.client('s3')

    try:
        # Upload the file
        s3_client.upload_file(file_name, S3_BUCKET, os.path.basename(file_name))
        print(f"Successfully uploaded {file_name} to S3 bucket {S3_BUCKET}.")
    except FileNotFoundError:
        print(f"The file {file_name} was not found.")
    except NoCredentialsError:
        print("Credentials not available.")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

def upload_archives():
    # Iterate through the archive directory and upload each .tar.gz file
    for file in os.listdir(ARCHIVE_BASE_DIR):
        if file.endswith('.tar.gz'):
            file_path = os.path.join(ARCHIVE_BASE_DIR, file)
            upload_to_s3(file_path)

if __name__ == '__main__':
    upload_archives()
