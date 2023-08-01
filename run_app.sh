#!/bin/bash

# Declare and assign the value to the variable
docker_image_name="nodejs-sample-app-1"
temp_image_name="temp-nodejs-sample-app"
temp_container_name="temp-nodejs-container"
temp_volume_name="temp-nodejs-volume"

# Function to build the Docker image
build_image() {
  echo "Building the Docker image..."
  docker build -t "$docker_image_name:$1" --build-arg NODE_ENV="$1" .
}

# Function to stop and remove the Docker container
stop_and_remove_container() {
  echo "Stopping and removing the container..."
  docker stop "$1"
  docker rm "$1"
}

# Function to remove the Docker image
remove_image() {
  echo "Removing the image..."
  docker rmi "$docker_image_name:$1"
}

# Function to run the Docker container
run_container() {
  echo "Running the Docker container..."
  docker run -p 3000:3000 -v "$(pwd)":/app --name "$1" "$docker_image_name:$2"
}

# Function to run the temporary Docker container with dynamically allocated host port
run_temp_container() {
  echo "Running the temporary Docker container with dynamically allocated host port..."
  if docker run -P --rm -v "$(pwd)":/app --name "$temp_container_name" "$1"; then
    echo "Temporary container ran successfully."
    return 0
  else
    echo "Failed to run the temporary container."
    return 1
  fi
}

# Function to create a volume to save the state of the app
create_temp_volume() {
  echo "Creating a temporary volume to save the state of the app..."
  docker volume create "$temp_volume_name"
}

# Function to backup app data to the temporary volume
backup_app_data() {
  echo "Backing up app data to the temporary volume..."
  docker run --rm -v "$(pwd)":/app -v "$temp_volume_name":/backup alpine cp -a /app /backup
}

# Function to restore app data from the temporary volume
restore_app_data() {
  echo "Restoring app data from the temporary volume..."
  docker run --rm -v "$(pwd)":/app -v "$temp_volume_name":/backup alpine cp -a /backup/app /app
}

# Function to check the logs of the application inside the container
check_application_logs() {
  container_id=$(docker ps -q -f name=nodejs-sample-app-1-container)

  if [ -z "$container_id" ]; then
    echo "Container is not running. Cannot check application logs."
    return 1
  fi

  echo "Checking application logs..."
  log_output=$(docker logs "$container_id")  # Replace with the correct log command for your application

  # Look for specific log messages that indicate successful startup of the application
  if echo "$log_output" | grep -q "Server started on port 3000"; then
    echo "Application is running."
    return 0
  else
    echo "Application has crashed."
    return 1
  fi
}

# Function to show usage instructions
show_usage() {
  echo "Invalid argument. Usage: $0 [dev|prod]"
}

# Trap signals for cleanup
trap 'cleanup' ERR

# Check if an argument is provided
if [ $# -ne 1 ]; then
  show_usage
  exit 1
fi

# Validating the provided argument
if [ "$1" != "dev" ] && [ "$1" != "prod" ]; then
  show_usage
  exit 1
fi

# Check if the Docker container exists and stop it if running
if docker ps -a | grep -q "$docker_image_name-container"; then
  # Stop and remove the existing container
  stop_and_remove_container "$docker_image_name-container"
fi

# Check if the Docker image exists and remove it
if docker image ls -q "$docker_image_name:$1" >/dev/null; then
  remove_image "$1"
fi

# need to check here for new 
# Check if the main container exists; if not, build and run it directly
if ! docker ps -a | grep -q "$docker_image_name-container"; then
  # Create a volume to save the state of the app
  create_temp_volume

  # Backup app data to the temporary volume
  backup_app_data

  # Build the Docker image
  if build_image "$1"; then
    # Run the Docker container with the fixed port 3000
    run_container "$docker_image_name-container" "$1"

    # Check the application logs after running the container
    # there are need to check. is the temporary container is running ?
    if check_application_logs; then
      echo "Application is running. Proceed with other tasks..."
      exit 0
    else
      echo "Application has crashed. Investigate and take appropriate actions..."
      exit 1
    fi
  else
    echo "Failed to build the Docker image."
    # Restore app data from the temporary volume to rollback changes
    restore_app_data
    exit 1
  fi
fi

# ... (rest of your script)

# Continue with the rest of your script (e.g., running the temporary container)


# # Create a volume to save the state of the app
# create_temp_volume

# # Backup app data to the temporary volume
# backup_app_data



# # Build the Docker image
# if build_image "$1"; then
#   # Run the temporary container to trigger the build
#   run_temp_container "$docker_image_name:$1"
# else
#   echo "Failed to build the Docker image."
#   # Restore app data from the temporary volume to rollback changes
#   restore_app_data
#   exit 1
# fi

# Run the Docker container with the fixed port 3000
# run_container "$docker_image_name-container" "$1"

# ------- start

# is_main_container_running() {
#   docker ps | grep -q "$docker_image_name-container"
# }

# # Check if the main container exists and is running
# if is_main_container_running; then
#   echo "Main container is already running. Skipping temporary container setup..."
# else
#   # Create a volume to save the state of the app
#   create_temp_volume

#   # Backup app data to the temporary volume
#   backup_app_data

#   # Build the Docker image
#   if build_image "$1"; then
#     # Run the temporary container to trigger the build
#     if run_temp_container "$docker_image_name:$1"; then
#       # Run the Docker container with the fixed port 3000
#       if run_container "$docker_image_name-container" "$1"; then
#         # Clean up the temporary volume if everything is successful
#         docker volume rm "$temp_volume_name"
#         echo "Application is running successfully."
#       else
#         echo "Failed to run the main container."
#         # Stop and remove the main container in case of failure
#         stop_and_remove_container "$docker_image_name-container"
#         # Restore app data from the temporary volume to rollback changes
#         restore_app_data
#         exit 1
#       fi
#     else
#       echo "Failed to run the temporary container."
#       # Restore app data from the temporary volume to rollback changes
#       restore_app_data
#       exit 1
#     fi
#   else
#     echo "Failed to build the Docker image."
#     # Restore app data from the temporary volume to rollback changes
#     restore_app_data
#     exit 1
#   fi
# fi

# -- closs

# -- start


# # Check if the main container exists and is running
# if is_main_container_running; then
#   echo "Main container is already running. Skipping temporary container setup..."
# else
#   # Create a volume to save the state of the app
#   create_temp_volume

#   # Backup app data to the temporary volume
#   backup_app_data

#   # Build the Docker image
#   if build_image "$1"; then
#     # Run the temporary container to trigger the build
#     if run_temp_container "$docker_image_name:$1"; then
#       # Run the Docker container with the fixed port 3000
#       if run_container "$docker_image_name-container" "$1"; then
#         # Clean up the temporary volume if everything is successful
#         docker volume rm "$temp_volume_name"
#         echo "Application is running successfully."
#       else
#         echo "Failed to run the main container."
#         # Stop and remove the main container in case of failure
#         stop_and_remove_container "$docker_image_name-container"
#         # Restore app data from the temporary volume to rollback changes
#         restore_app_data
#         exit 1
#       fi
#     else
#       echo "Failed to run the temporary container."
#       # Restore app data from the temporary volume to rollback changes
#       restore_app_data
#       exit 1
#     fi
#   else
#     echo "Failed to build the Docker image."
#     # Restore app data from the temporary volume to rollback changes
#     restore_app_data
#     exit 1
#   fi
# fi