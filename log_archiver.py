import os 
import tarfile 
from datetime import datetime, timedelta
import socket
import argparse

# Define the retention period
retention = 90

# Define the archive base directory
archive_base_dir = "/usr/local/bin/log_archiver/archives"
execution_log_path = "/usr/local/bin/log_archiver/execution_log.log"

def generate_output_filename():
    # Get current date/time
    now = datetime.now()
    # Format the date/time 
    formatted_time = now.strftime("%Y%m%d_%H%M%S")
    # Get the hostname of the machine
    hostname = socket.gethostname()
    # Create the file name
    return f"{hostname}_{formatted_time}_logs_archive_.tar.gz"

def archive_logs(log_dir, output_file):
    # Create the full output path in the archive base directory
    full_output_path = os.path.join(archive_base_dir, output_file)
    
    # Create the archive directory if it doesn't exist
    os.makedirs(archive_base_dir, exist_ok=True)
    
    # Opens a new tar.gz file to write to using gzip-compressed format.
    with tarfile.open(full_output_path, "w:gz") as tar:
        # Walk through each directory tree returning a tuple for each directory
        for root, dirs, files in os.walk(log_dir):
            for file in files:
                full_path = os.path.join(root, file)
                tar.add(full_path, arcname=os.path.relpath(full_path, log_dir))
                log_message(f"Added {full_path} to archive.")
    
    log_message(f"Logs archived to {full_output_path}")  # Confirm archive creation

def purge_old_archives(archive_base_dir, days=retention):
    # Calculate the cutoff date
    cutoff_date = datetime.now() - timedelta(days=days)
    
    # Iterate through the archive directory
    for root, dirs, files in os.walk(archive_base_dir):
        for file in files:
            file_path = os.path.join(root, file)
            # Get the file's modification time
            file_mod_time = datetime.fromtimestamp(os.path.getmtime(file_path))
            # If the file is older than the cutoff date, delete it
            if file_mod_time < cutoff_date:
                os.remove(file_path)
                log_message(f"Deleted old archive: {file_path}")

def log_execution(message):
    # Create the directory for the log file if it doesn't exist
    os.makedirs(os.path.dirname(execution_log_path), exist_ok=True)

    # Log the execution message with a timestamp
    with open(execution_log_path, "a") as log_file:
        log_entry = f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} - {message}\n"
        log_file.write(log_entry)
        print(log_entry.strip())  # Also print to terminal

def log_message(message):
    log_execution(message)

if __name__ == '__main__':
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Archive log files from a specified directory.')
    parser.add_argument('log_dir', type=str, nargs='?', default='/var/log', help='The directory containing log files to archive (default: /var/log).')
    args = parser.parse_args()

    output_file = generate_output_filename()
    log_message("Starting log archiving process.")
    archive_logs(args.log_dir, output_file)
    purge_old_archives(archive_base_dir)
    log_message(f"Archived logs to {output_file}")
