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

# Copy requirements and install dependencies
RUN pip install .

# Copy project files
COPY ./build/ /app/
COPY ./src/start.sh /app/start.sh

# Start script that launches VNC and your app
RUN chmod +x /app/start.sh

# Expose VNC and web ports
EXPOSE 5900 6080

CMD ["/app/start.sh"]