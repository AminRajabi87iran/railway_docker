FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install standard SSH server and netcat (ultra-lightweight web binder)
RUN apt-get update && apt-get install -y \
    openssh-server \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# FIX: Added -p flag so it won't crash if the directory already exists
RUN mkdir -p /var/run/sshd

# Set your root password (CHANGE 'mysecurepassword' to your own!)
RUN echo 'root:mysecurepassword' | chpasswd

# Configure SSH to allow root login using a password on port 22
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Inform Docker that ports 22 (SSH) and 10000 (Web health check) are used
EXPOSE 22 10000

# Start SSH daemon, then use netcat to satisfy Railway's mandatory HTTP health check
CMD ["sh", "-c", "/usr/sbin/sshd && while true; do nc -l -p ${PORT:-10000} -c 'echo -e \"HTTP/1.1 200 OK\\n\\nOK\"'; done"]
