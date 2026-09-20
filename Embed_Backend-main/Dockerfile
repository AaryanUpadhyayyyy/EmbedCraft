# Build/Run Stage
FROM node:20-slim

# Set environment variables
ENV NODE_ENV=production
ENV PORT=4000

# Create app directory and set ownership
WORKDIR /usr/src/app

# Copy dependency specifications and set node ownership
COPY --chown=node:node package*.json ./

# Install ONLY production dependencies (reduces image size and security surface area)
RUN npm install --omit=dev

# Copy source code with correct ownership
COPY --chown=node:node . .

# Ensure uploads directory exists and is owned by node
RUN mkdir -p uploads/pages && chown -R node:node uploads

# Execute as non-privileged node user for security hardening
USER node

# Expose port (defaults to 4000)
EXPOSE 4000

# Start command
CMD ["node", "index.js"]
