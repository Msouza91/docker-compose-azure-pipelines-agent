FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ENV TARGETARCH="linux-x64"

RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt update \
    && apt upgrade \
    && apt install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        git \
        libicu70 \
        zip \
        unzip \
        build-essential \
        cmake \
	apt-transport-https \
	gnupg \
	lsb-release \
	python3-pip \
	python3-dev

# Install docker for building images
RUN groupadd -g 993 docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

RUN echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

# Create agent user and set up home directory
RUN useradd -m -d /home/agent agent
RUN chown -R agent:agent /azp /home/agent

RUN usermod -aG docker agent

USER agent

# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT ./start.sh
