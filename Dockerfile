# Use the official Node.js 18 image as the base image
FROM node:18-slim

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if exists)
COPY package*.json ./

# Use the build argument to set the NODE_ENV environment variable
ARG NODE_ENV
ENV NODE_ENV $NODE_ENV

# Install npm dependencies
# RUN npm install --production
RUN npm install
# Copy the rest of the application code
COPY . .

# Expose the port on which your Node.js application listens (if applicable)
EXPOSE 3000

# Specify the command to start your Node.js application
# CMD ["node", "index.js"]
# CMD ["npm", "start"]

# Specify the command to start your Node.js application based on the NODE_ENV variable
# CMD ["bash", "run_app.sh", "$NODE_ENV"]

# Use the sh -c command to execute npm start with the NODE_ENV variable
CMD sh -c "npm start $NODE_ENV"
