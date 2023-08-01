#!/bin/bash

# Declare and assign the value to the variable
docker_image_name="nodejs-sample-app-1"

# Function to build the Docker image
build_image() {
  echo "Building the Docker image..."
  docker build -t "$docker_image_name:$1" --build-arg NODE_ENV="$1" .
}

# Function to stop and remove the Docker container
stop_and_remove_container() {
  echo "Stopping and removing the existing container..."
  docker stop "$docker_image_name-container"
  docker rm "$docker_image_name-container"
}

# Function to remove the Docker image
remove_image() {
  echo "Removing the existing image..."
  docker rmi "$docker_image_name:$1"
}

# Function to run the Docker container
run_container() {
  echo "Running the Docker container..."
  docker run -p 3000:3000 -v "$(pwd)":/app --name "$docker_image_name-container" "$docker_image_name:$1"
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
if docker ps -a | grep -q "$docker_image_name-container"; then
  if docker container stop "$docker_image_name-container"; then
    docker container rm "$docker_image_name-container"
  else
    echo "Failed to stop and remove the existing container."
    exit 1
  fi
fi

# Check if the Docker image exists and remove it
if docker image ls | grep -q "$docker_image_name:$1"; then
  if docker image rm "$docker_image_name:$1"; then
    echo "Removed the existing image."
  else
    echo "Failed to remove the existing image."
    exit 1
  fi
fi

# Build the Docker image
if build_image "$1"; then
  # Run the Docker container
  run_container "$1"
else
  echo "Failed to build the Docker image. Using existing image and running the container..."
  # Run the Docker container with the existing image
  run_container "$1"
fi

