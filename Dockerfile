FROM ubuntu:latest

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git make cmake python clang libgtk2.0-dev libx11-dev cpio

VOLUME [ "/usr/src/webrtc" ]
WORKDIR /usr/src/webrtc

RUN mkdir -p build

WORKDIR /usr/src/webrtc/build

CMD ["/bin/bash"]
