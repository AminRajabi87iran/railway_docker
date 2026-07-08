FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies, python3, and the OpenSSH Server
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    ca-certificates \
    wget \
    sudo \
    python3 \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH daemon
RUN mkdir /var/run/sshd

# Set a root password (change 'rootpassword' to whatever you want)
RUN echo 'root:rootpassword' | chpasswd

# Permit root login via SSH configuration
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose both the SSH port (22) and your web server port (10000)
EXPOSE 22 10000

# Start the SSH service in the background, then run the Python server to hold the port open
CMD ["sh", "-c", "/usr/sbin/sshd && python3 -m http.server ${PORT:-10000}"]
