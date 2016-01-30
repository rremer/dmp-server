#!/bin/bash
# setup a ksp dmp server

set -o xtrace
env

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/debian nightly main" | sudo tee /etc/apt/sources.list.d/mono.list
sudo apt-get update
sudo apt-get install -y curl
sudo apt-get install -y unzip
sudo apt-get install -y s3cmd
sudo apt-get install -y mono-complete
sudo apt-get install -y mono-mcs
sudo apt-get install -y mono-xbuild
sudo apt-get install -y libmono-system-runtime-serialization4.0-cil

s3cmd --version || exit 1
mcs --version || exit 1
xbuild --version
which xbuild || exit 1
mono --version || exit 1

sudo mkdir -p /var/lib/ksp
sudo chmod 0755 /var/lib/ksp
sudo useradd -r -M -d /var/lib/ksp ksp

echo -e "$s3_key\n$s3_secret\n\n\nNo\n\nY\nY\n" | s3cmd --configure
sudo cp /home/ubuntu/.s3cfg /var/lib/ksp
sudo cp /tmp/etc/cron.d/ksp-backup.sh /var/lib/ksp/
sudo sed -i "s/s3_bucket/$s3_bucket/g" /var/lib/ksp/ksp-backup.sh
sudo cp /tmp/etc/cron.d/ksp-backup /etc/cron.d/
sudo chown root:root /etc/cron.d/ksp-backup
sudo chmod 0644 /etc/cron.d/ksp-backup

sudo cp /tmp/etc/logrotate.d/ksp /etc/logrotate.d/
sudo chown root:root /etc/logrotate.d/ksp
sudo chmod 0644 /etc/logrotate.d/ksp

sudo cp /tmp/etc/rsyslog.d/30-ksp.conf /etc/rsyslog.d/
sudo chown root:root /etc/rsyslog.d/30-ksp.conf
sudo chmod 0644 /etc/rsyslog.d/30-ksp.conf

sudo cp /tmp/etc/init/ksp.conf /etc/init/
sudo chown root:root /etc/init/ksp.conf
sudo chmod 0644 /etc/init/ksp.conf

sudo initctl reload-configuration
sudo initctl check-config ksp

### build DarkMultiplayer ###
curl -L https://github.com/godarklight/DarkMultiPlayer/archive/v"$dmp_version".zip -o /tmp/dmp.zip
unzip /tmp/dmp.zip -d /tmp

# sketch, but network isolation of the server makes these libraries safe enough
curl http://www.dll-found.com/zip/u/UnityEngine.dll.zip -o /tmp/unity-engine.zip
sudo unzip /tmp/unity-engine.zip -d /usr/lib/mono/4.5/
sudo chmod 0755 /usr/lib/mono/4.5/UnityEngine.dll
curl http://www.dll-found.com/zip/a/Assembly-CSharp.dll.zip -o /tmp/assembly-csharp.zip
sudo unzip /tmp/assembly-csharp.zip -d /usr/lib/mono/4.5/
sudo chmod 0755 /usr/lib/mono/4.5/Assembly-CSharp.dll
#xbuild /p:Configuration=Release /p:TargetFrameworkVersion="v4.5" /p:DebugSymbols=False /tmp/DarkMultiPlayer-$dmp_version/DarkMultiPlayer.sln
xbuild /p:TargetFrameworkVersion="v4.5" /p:DebugSymbols=False /tmp/DarkMultiPlayer-$dmp_version/Common/DarkMultiPlayerCommon.csproj
xbuild /p:TargetFrameworkVersion="v4.5" /p:DebugSymbols=False /tmp/DarkMultiPlayer-$dmp_version/Server/Server.csproj
sudo cp /tmp/DarkMultiPlayer-$dmp_version/Server/bin/Debug/* /var/lib/ksp/
sudo chown -R ksp:ksp /var/lib/ksp
