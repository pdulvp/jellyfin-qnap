# jellyfin for QNAP version. 

![](https://raw.githubusercontent.com/pdulvp/jellyfin-qnap-intel/master/jellyfin/icons/jellyfin_80.gif)

## Compatibility
- See [Compatibility list](https://github.com/pdulvp/jellyfin-qnap/issues/4) and please add a comment if compatible or not with yours.
- Releases are created automatically from the latest jellyfin releases and are not field-tested nor official ones from Jellyfin or QNAP.
- The latest release with my :+1: is deployed on my QNAP and working properly.

## Enable Video Acceleration in Jellyfin

![](ScreenshotConfig.png)

Go to `Admin > Dashboard`
`Server > Playback`
- Transcoding > Hardware acceleration : Video Acceleration API (VAAPI)
- Transcoding > VA API Device: /dev/dri/renderD128

## Build

### Requirements
- WSL debian bullseye
- QDK2 : https://github.com/qnap-dev/qdk2/releases

### How to
- Launch `./make.sh` (note that the script will try to push it on this repository. `push.sh` can be disabled in subscripts `fetch-stable.sh` and `fetch-stable-pre.sh`)
