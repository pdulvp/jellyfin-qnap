FROM debian:bookworm

ARG DOTNET_VERSION="9.0"

RUN apt-get update
RUN apt-get install -y jq binutils xz-utils wget unzip gnupg ca-certificates curl

RUN apt-get install -y libicu-dev icu-devtools
RUN wget -O- https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel ${DOTNET_VERSION} --install-dir /usr/local/bin

RUN dpkg --add-architecture amd64
RUN dpkg --add-architecture arm64
RUN apt update -o APT::Architecture="arm64" -o APT::Architectures="arm64"
RUN apt update -o APT::Architecture="amd64" -o APT::Architectures="amd64"
