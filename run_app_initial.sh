#!/bin/bash

# 2: Development and Production Mode

# Function to show usage instructions
show_usage() {
  echo "Usage: $0 [dev|prod]"
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


# Function to install npm packages if needed
install_packages() {
  echo "Installing npm packages..."
  npm install
}

# Check if npm packages are installed
if npm ls --silent; then
  echo "All npm packages are installed."
else
  install_packages
fi

# Build the Docker image based on the provided mode
if [ "$1" == "dev" ]; then
    npm run start:dev
else
    npm run start:prod
fi
