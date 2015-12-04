# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker.
# ------------------------------------------------------------------------------
# Pull base image.
FROM kdelfour/supervisor-docker
MAINTAINER Kevin Delfour <kevin@delfour.eu>

# ------------------------------------------------------------------------------
# Install base
RUN apt-get update
RUN apt-get install -y build-essential g++ curl libssl-dev apache2-utils git libxml2-dev sshfs

# ------------------------------------------------------------------------------
# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs
RUN npm update npm -g

# ------------------------------------------------------------------------------
# Install yo bower grunt-cli
RUN npm install -g yo bower grunt-cli
    
# ------------------------------------------------------------------------------
# Install yo generator angular 
RUN npm install generator-karma -g
RUN npm install generator-angular -g

# ------------------------------------------------------------------------------
# Create user cloud9user
RUN adduser --disabled-password --gecos "" cloud9user && \
  echo "cloud9user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV HOME /home/cloud9user

RUN mkdir /cloud9
RUN chown cloud9user.cloud9user /cloud9
RUN sudo chown -R cloud9user.cloud9user /home/cloud9user


# ------------------------------------------------------------------------------
# Add volumes
RUN mkdir /workspace
RUN chown -R cloud9user.cloud9user /workspace
#VOLUME /workspace

USER cloud9user

# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone https://github.com/c9/core.git /cloud9
WORKDIR /cloud9
RUN scripts/install-sdk.sh

# Tweak standlone.js conf
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js 

# Add supervisord conf
ADD conf/cloud9.conf /etc/supervisor/conf.d/

# ------------------------------------------------------------------------------
# Clean up APT when done.
USER root
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 8080
EXPOSE 3000

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["sudo", "supervisord", "-c", "/etc/supervisor/supervisord.conf"]
USER cloud9user
RUN git config --global url.http://.insteadOf git://
