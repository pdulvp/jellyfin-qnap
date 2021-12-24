# jellyfin for QNAP

## Requirements
- WSL debian bullseye
- QDK2 : https://github.com/qnap-dev/qdk2/releases

## Download
- Download `jellyfin-server_XYZ_amd64.deb` and `jellyfin-web_XYZ_all.deb` from https://repo.jellyfin.org/releases/server/debian/stable/
- Download `jellyfin-ffmpeg_XYZ-bullseye_amd64.deb` from https://repo.jellyfin.org/releases/server/debian/ffmpeg/

## How to build
- Launch `./jellyfin-server.sh`
- Launch `./jellyfin-ffmpeg.sh`
- Launch `./package.sh`
