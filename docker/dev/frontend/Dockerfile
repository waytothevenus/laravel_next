# Base on offical Node.js Alpine image
FROM node:22-alpine3.18

WORKDIR /app

COPY ./frontend/package*.json ./

# Install dependencies
RUN npm install

# Copy the entire application code into the container
COPY ./frontend .

# Expose the development server port
EXPOSE 3000

# Set the default command (can be overridden by `docker-compose.yml`)
CMD ["npm", "run", "dev"]