# <img alt="logo" src="https://raw.githubusercontent.com/pdulvp/jellyfin-qnap-intel/master/jellyfin/icons/jellyfin_80.gif" width="24px"/> Jellyfin for QNAP &emsp; (https://github.com/pdulvp/jellyfin-qnap/releases)  ![](https://img.shields.io/github/downloads/pdulvp/jellyfin-qnap/total?label=All%20downloads&labelColor=green&color=BDE055&style=flat-square)

## <img alt="compatibility icon" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/compat.png" width="24px"/> Compatibility <img alt="arrow" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/downarrow.png" height="24px"/>
- See [Compatibility list](https://github.com/pdulvp/jellyfin-qnap/issues/4) and please add a comment if compatible or not with yours.
- Releases are created automatically from the latest jellyfin releases and are not field-tested nor official ones from Jellyfin or QNAP.
- The latest release with my :+1: is deployed on my QNAP and working properly.

## <img alt="hardware icon" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/hard.png" width="24px"/> Installation <img alt="arrow" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/downarrow.png" height="24px"/>

- Download the `.qpkg` from the [Releases](https://github.com/pdulvp/jellyfin-qnap/releases)
- On the `Qnap QTS` > `App Center` > `Settings` > `Allow installation of applications without a valid digital signature`
- On the `Qnap QTS` > `App Center` > `Install Manually`. then choose the downloaded `.qpkg`.
- After installation, on the Jellyfin appearing in the App Center, just wait a bit (~30s) then open it using the `Open` button. It shall open a working web site. (note that if it doesn't open or raise an connection refused, try with default http default port 8096)
- If it is the first time you open, you will have to choose a server (which is the IP of your NAS) and create an user
- If you watch jellyfin on your TV (or so) using Jellyfin Android version (or other), your NAS should then be accessible from it. Just add the NAS ip to access it.

## <img alt="hardware icon" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/hard.png" width="24px"/> Enable Video Acceleration in Jellyfin <img alt="arrow" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/downarrow.png" height="24px"/>

![](ScreenshotConfig.png) ([中文](ScreenshotConfigCh.png))

Go to `Admin > Dashboard`
`Server > Playback`
- `Transcoding` > `Hardware acceleration` : `Video Acceleration API (VAAPI)`
- `Transcoding` > `VA API Device`: `/dev/dri/renderD128`

This shall be OK, but maybe not.

### Troubleshooting while trancoding

Go to `Admin > Dashboard`

* You can find a log of vainfo of your NAS under `Advanced > Logs > vainfo-*.log`. It will helps you to find which driver or options to enable.

* A dedicated plugin is now installed by default on the Jellyfin server `(Plugins > QNAP.Configuration)`, you can change the default vaapi driver used while loading a video. (from `defaultValue` to `iHD` or `i965`).

![](ScreenshotPluginConfig.png)

* Disable some unexpected enabled options `Server > Playback > Transcoding`:

   * On TS-253A, the option `Enable 10-Bit hardware decoding for HEVC` shall be disabled

## Network

### HTTP port

Is it possible to change the default http port of Jellyfin.

Go to `Administration > Dashboard > Advanced > Networking`

- Change the `Server Address Settings > Local HTTP port number`, go to QNAP App Center and do Stop and Start on the Jellyfin.

- Hopefully, if you open Jellyfin with the new port number, it shall open it.

### HTTPS

Is it possible to enable HTTPS for Jellyfin.

Go to `Administration > Dashboard > Advanced > Networking`

- Enable the `HTTPS` accordingly and change the `Server Address Settings > Local HTTPS port number` if needed. 

- Put the path towards your p12 certificate if you have some. (if not, see below how to generate one for your Jellyfin server)

- Go to QNAP App Center and do Stop and Start on the Jellyfin.

- Hopefully, if you open Jellyfin with the new HTTPS port number, it shall open it.

### Generate a HTTPS certificate

You can use directly the certificate of your NAS (download it and generate a p12 from it), or create a new one. Below are the steps to create a child certificate from the QNAP one.

Download your QNAP NAS certificate

`System > Security > SSH and certificates > Download certificate and private key`

Create a private key for the new certificate

`openssl genrsa -out newkey.key 2048`

Create a configuration `openssl-cert.conf`

```
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no

[req_distinguished_name]
C   = FR
ST  = Paris
L   = Paris
O   = pdulvp
CN  = Jellyfin QNAP

[req_ext]
subjectAltName = @alt_names

[alt_names]
IP.1 = 192.168.1.xxx
DNS.1 = nasfxxxxxx
```

Create a sign request

`openssl req -new -key newkey.key -out newcsr.csr -config openssl-cert.conf`

Create a certificate

`openssl x509 -req -in newcsr.csr -CA SSLcertificate.crt -CAkey SSLprivatekey.key -CAcreateserial -out jellyfincert.crt -days 365 -extensions req_ext -extfile openssl-cert.conf`

Package the certificate

`openssl pkcs12 -export -out jellyfincert.p12 -inkey newkey.key -in jellyfincert.crt -certfile SSLcertificate.crt`

Reference it in Jellyfin

Start and stop Jellyfin in the QNAP App Center

On your client, Install the certificate as Trusted. Whether the Jellyfin one (Right Click on CRT, Install Certificate > Local Machine (or current user) > Automatically select the certificate) or the QNAP one as Trusted Root Certificate (Right Click on CRT, Install Certificate > Local Machine (or current user) > Place all certificates on the following store > Trusted Root Certification Authorities). With this last option, all childs certificates of your NAS are trusted. (Restart your PC)

Open Jellyfin, it shall work. 

Now you shall reconnect to the server using HTTPS


### Customization

Now, you can customize the startup of Jellyfin by creating a new file `user-config.sh` in the installation folder, rather than editing provided scripts. It will not be erased after updates. (look at `user-config.sh.sample` provided aside)

## <img alt="hybriddesk icon" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/hd.png" width="24px"/> HybridDesk Station <img alt="arrow" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/downarrow.png" height="24px"/>

To add a shortcut onto the HybridDesk Station, you can use **[@pdulvp/jellyfin-qnap-hd](https://github.com/pdulvp/jellyfin-qnap-hd)**

## <img alt="updates icon" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/auto.png" width="24px"/> Automatic updates <img alt="arrow" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/downarrow.png" height="24px"/>

You can use my alternative store link on the App Center to retrieve automatic updates.
See **[pdulvp.fr/qnap-store](https://pdulvp.fr/qstore.html)**

## <img alt="build icon" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/build.png" width="24px"/> Build <img alt="arrow" src="https://raw.githubusercontent.com/pdulvp/pdulvp/main/icons/downarrow.png" height="24px"/>

### Requirements
- WSL debian bullseye with rsync and jq installed 
- QDK2 : https://github.com/qnap-dev/qdk2/releases
- Visual Studio 2022

### How to
- Launch a Release build of the `plugins/Jellyfin.Plugin.QnapConfiguration.sln` under Visual Studio. It will create two releases, for net5.0 and net6.0 that will be embedded afterwards.
- Launch `./make.sh` (note that the script will try to push it on this repository. `push.sh` can be disabled in subscripts `fetch-stable.sh` and `fetch-stable-pre.sh`)
- If there is some 'File not found' while downloading dependencies, just launch a `sudo apt-get update` on your WSL and relaunch the build
- The build is verbose and raises some logs on tar operations but shall not ring a bell

### Why this qpkg is so large

It is large as it embeds Jellyfin Server, Jellyfin FFMPEG and Jellyfin Web Client and most of their dependencies. Jellyfin and ffmpeg require some dependencies that are not available on most QNAP NAS default installation (latest releases of libc or stuff) so it embeds almost all dependencies in it to be able to be launched. Dependencies and custom installed jellyfin plugin.
