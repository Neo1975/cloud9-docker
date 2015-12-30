# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker.
# ------------------------------------------------------------------------------
# Pull base image.
FROM kdelfour/supervisor-docker
MAINTAINER Daniele Fornaciari <d.fornaciari@gmail.com>

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
RUN npm install -g yo bower grunt-cli deployd
    
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
RUN mkdir /deployd
RUN chown -R cloud9user.cloud9user /deployd
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

WORKDIR /deployd 
RUN dpd create dpd 
WORKDIR /deployd/dpd
#RUN dpd keygen 
#RUN dpd showkey
#RUN dpd -H ${MONGO_PORT_27017_TCP_ADDR} -P ${MONGO_PORT_27017_TCP_PORT} -n ${MONGO_PORT_27017_DB}

# ------------------------------------------------------------------------------
# Clean up APT when done.
USER root
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 8080
EXPOSE 3000
EXPOSE 2403

env MONGO_PORT_27017_TCP_ADDR localhost
env MONGO_PORT_27017_TCP_PORT 27017
env MONGO_PORT_27017_DB db

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["sudo", "supervisord", "-c", "/etc/supervisor/supervisord.conf"]
USER cloud9user
RUN git config --global url.http://.insteadOf git://
