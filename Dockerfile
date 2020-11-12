FROM jetbrains/teamcity-minimal-agent:2020.1.5
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH "/home/buildagent/.cargo/bin:$PATH"
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN add-apt-repository ppa:longsleep/golang-backports && apt-get update && apt-get install -y golang golang-goprotobuf-dev libx11-dev libasound2-dev libudev-dev libxcb-render0-dev libxcb-shape0-dev libxcb-xfixes0-dev
USER buildagent

