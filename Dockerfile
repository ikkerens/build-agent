FROM jetbrains/teamcity-agent:2021.1.2-linux-sudo

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
 && apt-get install -y libx11-dev libasound2-dev libudev-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev libssl-dev build-essential pkg-config

# Install golang
RUN apt-get update && apt-get install -y protobuf-compiler wget \
 && wget https://golang.org/dl/go1.17.linux-amd64.tar.gz \
 && tar -C /usr/local -xzf go1.17.linux-amd64.tar.gz \
 && rm go1.17.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

RUN GO111MODULE=off go get google.golang.org/protobuf/cmd/protoc-gen-go \
 && GO111MODULE=off go build -o /usr/bin/protoc-gen-go google.golang.org/protobuf/cmd/protoc-gen-go

# Install postgres
ENV PATH=$PATH:/usr/lib/postgresql/12/bin
RUN apt-get install -y postgresql postgresql-contrib && systemctl enable postgresql.service

# Install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
 && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
 && apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io \
 && usermod -aG docker buildagent

# start.sh
COPY start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh

# Lower permission level
USER buildagent

CMD ["/usr/bin/start.sh"]
