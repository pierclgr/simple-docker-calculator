# Use Python base image
FROM python:3.10-slim

# Install system dependencies including noVNC
RUN apt-get update && apt-get install -y \
    x11vnc \
    xvfb \
    fluxbox \
    tk-dev \
    python3-tk \
    novnc \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy everything from build/ into /app
COPY ./build/ ./

# Make start.sh executable
RUN chmod +x ./start.sh

# Expose ports
EXPOSE 5900 6080

# Default command
CMD ["./start.sh"]