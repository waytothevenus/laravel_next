FROM cypress/included:latest

WORKDIR /app

# Copy package files
COPY cypress/package.json cypress/package-lock.json ./

# Install dependencies
RUN npm ci

# Create cypress user (let system assign UID)
RUN adduser --disabled-password --gecos "" cypress \
    && mkdir -p /app/cypress/screenshots /app/cypress/videos \
    && chown -R cypress:cypress /app

USER cypress

CMD ["npx", "cypress", "run"]