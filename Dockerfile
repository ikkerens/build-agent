FROM jetbrains/teamcity-agent:2022.04.3-linux-sudo

# Install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH "/home/buildagent/.cargo/bin:$PATH"
RUN rustup component add llvm-tools-preview

# Increase permission level
USER root

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
# Generic dependencies
RUN apt-get update && apt-get install -y software-properties-common git \
# Game dependencies
 && apt-get install -y libx11-dev libasound2-dev libudev-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev libssl-dev build-essential pkg-config

# Install golang
ARG GOLANG_VERSION=1.19
RUN apt-get update && apt-get install -y protobuf-compiler wget \
 && wget https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz \
 && tar -C /usr/local -xzf go$GOLANG_VERSION.linux-amd64.tar.gz \
 && rm go$GOLANG_VERSION.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

RUN GO111MODULE=off go get google.golang.org/protobuf/cmd/protoc-gen-go \
 && GO111MODULE=off go build -o /usr/bin/protoc-gen-go google.golang.org/protobuf/cmd/protoc-gen-go

# Install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
 && apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io \
 && usermod -aG docker buildagent
 
# Install kubectl
RUN sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list \
 && apt-get update \
 && apt-get install -y kubectl

# Lower permission level
USER buildagent

