#!/bin/bash

cp -r /plugins/* /output/
dotnet build /output/Jellyfin.Plugin.QnapConfiguration.sln --configuration Release
