FROM debian:bullseye

ARG QDK_VERSION="2.4.0"
ARG DOTNET_VERSION="9.0"

RUN apt-get update
RUN apt-get install -y jq wget unzip gnupg ca-certificates

RUN wget -O /tmp/qdk.zip https://github.com/qnap-dev/QDK/archive/refs/tags/v${QDK_VERSION}.zip
RUN unzip -d /tmp /tmp/qdk.zip
RUN rm -rf /tmp/qdk.zip

RUN chmod 755 /tmp/QDK-${QDK_VERSION}/InstallToUbuntu.sh
RUN cd /tmp/QDK-${QDK_VERSION} && ./InstallToUbuntu.sh install;
RUN rm -rf /tmp/QDK-${QDK_VERSION}

RUN apt-get install -y libicu-dev icu-devtools
RUN wget -O- https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel ${DOTNET_VERSION} --install-dir /usr/local/bin
