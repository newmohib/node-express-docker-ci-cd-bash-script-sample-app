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
  if docker run -P --rm -v "$(pwd)":/app --name "$temp_container_name" "$1"; then
    echo "Temporary container ran successfully."
  else
    echo "Failed to run the temporary container. Cleaning up..."
    exit 1
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
  # Try running the new image with a temporary container
  echo "Trying to run the new image with a temporary container..."
  if run_temp_container "$1"; then
    # Stop and remove the existing container
    stop_and_remove_container "$docker_image_name-container"
    # Remove the temporary container
    docker rm "$temp_container_name"
  else
    # Remove the failed temporary container
    echo "Failed to run the new image. Using existing image and container..."
    exit 1
  fi
fi

# Check if the Docker image exists and remove it
if docker image ls -q "$docker_image_name:$1" >/dev/null; then
  remove_image "$1"
fi

# Build the Docker image
if build_image "$1"; then
  # Run the Docker container with the fixed port 3000
  run_container "$docker_image_name-container" "$1"
else
  echo "Failed to build the Docker image. Using existing image and running the container..."
  # Run the Docker container with the existing image
  run_container "$docker_image_name-container" "$1"
fi
