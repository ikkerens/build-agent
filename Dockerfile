FROM jetbrains/teamcity-minimal-agent:2020.1.5

# Install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH "/home/buildagent/.cargo/bin:$PATH"

# Increase permission level
USER root

# Install dependencies
ENV DEBIAN_FRONTEND=noninteractive
# Generic dependencies
RUN apt-get update && apt-get install -y software-properties-common git \
# Game dependencies
 && apt-get install -y libx11-dev libasound2-dev libudev-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev libssl-dev

# Install golang
RUN add-apt-repository ppa:longsleep/golang-backports && apt-get update && apt-get install -y golang protobuf-compiler \
 && go get google.golang.org/protobuf/cmd/protoc-gen-go \
 && go build -o /usr/bin/protoc-gen-go google.golang.org/protobuf/cmd/protoc-gen-go

# Install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
 && apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io \
 && usermod -aG docker buildagent

# Lower permission level
USER buildagent
