#!/bin/bash

# Function to build the Docker image
build_image() {
  echo "Building the Docker image..."
  docker build -t nodejs-sample-app-1:$1 --build-arg NODE_ENV=$1 .
}

# Function to stop and remove the Docker container
stop_and_remove_container() {
  echo "Stopping and removing the existing container..."
  docker stop nodejs-sample-app-1
  docker rm nodejs-sample-app-1
}

# Function to remove the Docker image
remove_image() {
  echo "Removing the existing image..."
  docker rmi nodejs-sample-app-1:$1
}

# Function to run the Docker container
run_container() {
  echo "Running the Docker container..."
  docker run -p 3000:3000 -v "$(pwd)":/app --name nodejs-sample-app-1 nodejs-sample-app-1:$1
}

# Function to show usage instructions
show_usage() {
  echo "Invalid argument. Usage: $0 [dev|prod]"
}

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
if docker ps -a | grep -q "nodejs-sample-app-1:$1"; then
  # Try running the new image with a temporary container
  echo "Trying to run the new image with a temporary container..."

  if docker run --name temp-container nodejs-sample-app-1:$1; then
    # Stop and remove the existing container
    echo "Stop and remove the existing container..."
    stop_and_remove_container $1
    # Remove the temporary container
    echo "Remove the temporary container..."
    docker rm temp-container
  else
    # Remove the failed temporary container
    echo "Remove the failed temporary container for failed to run..."
    docker rm temp-container
    echo "Failed to run the new image. Using existing image and container..."
    exit 1
  fi

fi

# Check if the Docker image exists and remove it
if docker image ls | grep -q "nodejs-sample-app-1:$1"; then
  remove_image $1
fi

# Build the Docker image
build_image $1

# Run the Docker container
run_container $1
