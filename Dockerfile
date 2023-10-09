FROM jenkins/jenkins:2.414.2-jdk17

USER root

# Install necessary packages and add Docker repository
RUN apt-get update && \
    apt-get -y install lsb-release curl && \
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Switch back to Jenkins user and install plugins
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"

