# <img src="https://raw.githubusercontent.com/pdulvp/jellyfin-qnap-intel/master/jellyfin/icons/jellyfin_80.gif" width="24px"/> Jellyfin for QNAP &emsp; [![](https://img.shields.io/badge/dynamic/json?labelColor=green&color=BDE055&label=release&query=$[?(@.prerelease==false)].name&url=https%3A%2F%2Fapi.github.com%2Frepositories%2F441484865%2Freleases&style=flat-square)](https://github.com/pdulvp/jellyfin-qnap/releases) [![](https://img.shields.io/badge/dynamic/json?labelColor=yellow&color=EFD68B&label=prerelease&query=$[?(@.prerelease==true)].name&url=https%3A%2F%2Fapi.github.com%2Frepositories%2F441484865%2Freleases&style=flat-square)](https://github.com/pdulvp/jellyfin-qnap/releases)

## Compatibility
- See [Compatibility list](https://github.com/pdulvp/jellyfin-qnap/issues/4) and please add a comment if compatible or not with yours.
- Releases are created automatically from the latest jellyfin releases and are not field-tested nor official ones from Jellyfin or QNAP.
- The latest release with my :+1: is deployed on my QNAP and working properly.

## Enable Video Acceleration in Jellyfin

![](ScreenshotConfig.png)

Go to `Admin > Dashboard`
`Server > Playback`
- `Transcoding` > `Hardware acceleration` : `Video Acceleration API (VAAPI)`
- `Transcoding` > `VA API Device`: `/dev/dri/renderD128`

## HybridDesk Station

To add a shortcut onto the HybridDesk Station, you can use **[@pdulvp/jellyfin-qnap-hd](https://github.com/pdulvp/jellyfin-qnap-hd)**

## Automatic updates

You can use my alternative store link on the App Center to retrieve automatic updates.
See **[pdulvp.fr/qnap-store](https://pdulvp.fr/qstore.html)**

## Build

### Requirements
- WSL debian bullseye
- QDK2 : https://github.com/qnap-dev/qdk2/releases

### How to
- Launch `./make.sh` (note that the script will try to push it on this repository. `push.sh` can be disabled in subscripts `fetch-stable.sh` and `fetch-stable-pre.sh`)
