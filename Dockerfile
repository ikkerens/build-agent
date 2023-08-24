FROM jetbrains/teamcity-agent:2023.05.2-linux-sudo

# Install rust
# This is a comment to trigger CI, I've done this 1 time now.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH "/home/buildagent/.cargo/bin:$PATH"
RUN rustup component add llvm-tools-preview && rustup target add x86_64-pc-windows-gnu

# Increase permission level
USER root

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive

# Temp: Add perforce until Ubuntu/perforce get their stuff together
RUN curl -fsSL https://package.perforce.com/perforce.pubkey | apt-key add - \
 && add-apt-repository "deb [arch=amd64] https://package.perforce.com/apt/ubuntu $(lsb_release -cs) release"

# Generic dependencies
RUN apt-get update && apt-get install -y ca-certificates software-properties-common git \
# Game dependencies
 && apt-get install -y libx11-dev libasound2-dev libudev-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev libssl-dev build-essential pkg-config mingw-w64

# Install golang
ARG GOLANG_VERSION=1.21.0
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
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
 && apt-get update \
 && apt-get install -y kubectl

# Lower permission level
USER buildagent
