#!/bin/bash

# Declare and assign the value to the variable
docker_image_name="nodejs-sample-app-1"
temp_image_name="temp-nodejs-sample-app"
temp_container_name="temp-nodejs-container"

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
  docker run -P --rm -v "$(pwd)":/app --name "$temp_container_name" "$1"
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

# Check if the main container exists; if not, build and run it directly
if ! docker ps -a | grep -q "$docker_image_name-container"; then
  # Build the Docker image
  if build_image "$1"; then
    # Run the Docker container with the fixed port 3000
    run_container "$docker_image_name-container" "$1"
    exit 0
  else
    echo "Failed to build the Docker image."
    exit 1
  fi
fi

# Build the Docker image
if build_image "$1"; then
  # Run the temporary container to trigger the build
  run_temp_container "$docker_image_name:$1"
else
  echo "Failed to build the Docker image."
  exit 1
fi

# Run the Docker container with the fixed port 3000
run_container "$docker_image_name-container" "$1"
