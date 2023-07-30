#!/bin/bash

# 1: smaple command just buld and run docker

# Build the Docker image
# docker build -t nodejs-sample-app-1 .

# Run a container based on the built image
# docker run -p 3000:3000 nodejs-sample-app-1


# 2: Development and Production Mode

# Function to show usage instructions
show_usage() {
  echo "Usage: $0 [development|production]"
}

# Check if an argument is provided
if [ $# -ne 1 ]; then
  show_usage
  exit 1
fi

# Validating the provided argument
if [ "$1" != "development" ] && [ "$1" != "production" ]; then
  show_usage
  exit 1
fi

# Build the Docker image based on the provided mode
if [ "$1" == "development" ]; then
    echo "Started: Development"
    # Build the Docker image
    docker build -t nodejs-sample-app-1:development --build-arg NODE_ENV=development .

    # Run a container based on the built image with development directory like "$(pwd)"
    docker run -p 3000:3000 -v "$(pwd)":/app nodejs-sample-app-1:$1 

else
    echo "Started: Production Mode"
    docker build -t nodejs-sample-app-1:production --build-arg NODE_ENV=production .

    # Run a container based on the built image
    docker run -p 3000:3000 nodejs-sample-app-1:$1
    
fi

#docker stop nodejs-sample-app-1:$1
# docker run -p 3000:3000 -v "$(pwd)":/app nodejs-sample-app-1:$1

# 3: Start the application based on the provided mode

# if [ "$1" == "development" ]; then
#   echo "Running in development mode with nodemon..."
#   npm run start:dev
# else
#   echo "Running in production mode..."
#   npm run start:prod
# fi
