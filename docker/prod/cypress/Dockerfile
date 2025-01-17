FROM cypress/included:latest

WORKDIR /app

# Copy package files and cypress files
COPY frontend/package.json frontend/package-lock.json ./
COPY frontend/cypress.config.js .
COPY frontend/cypress ./cypress

# Install only production dependencies
RUN npm ci --production

# Add cypress user to avoid permission issues
RUN useradd -m cypress
RUN chown -R cypress:cypress /app

USER cypress

CMD ["npx", "cypress", "run"]