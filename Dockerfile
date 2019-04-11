FROM alpine

RUN apk update
RUN apk upgrade
RUN apk add alpine-sdk bash bash-doc bash-completion git clang make cmake libstdc++ python tar xz

VOLUME [ "/usr/src/webrtc" ]
WORKDIR /usr/src/webrtc

RUN mkdir -p build

WORKDIR /usr/src/webrtc/build

CMD ["/bin/bash"]
