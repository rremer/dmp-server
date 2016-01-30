#!/bin/bash
# build just DMPServer.exe

FROM ubuntu
ENV dmp_version=0.2.2.2

RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN echo "deb http://download.mono-project.com/repo/debian nightly main" | sudo tee /etc/apt/sources.list.d/mono.list
RUN sudo apt-get update
RUN sudo apt-get install -y curl
RUN sudo apt-get install -y unzip
RUN sudo apt-get install -y mono-complete
RUN sudo apt-get install -y mono-mcs
RUN sudo apt-get install -y mono-xbuild

# lib dependencies
RUN sudo apt-get install -y libmono-system-runtime-serialization4.0-cil
# sketch, but network isolation of the server makes these libraries safe enough
RUN curl http://www.dll-found.com/zip/u/UnityEngine.dll.zip -o /tmp/unity-engine.zip
RUN sudo unzip /tmp/unity-engine.zip -d /usr/lib/mono/4.5/
RUN sudo chmod 0755 /usr/lib/mono/4.5/UnityEngine.dll
RUN curl http://www.dll-found.com/zip/a/Assembly-CSharp.dll.zip -o /tmp/assembly-csharp.zip
RUN sudo unzip /tmp/assembly-csharp.zip -d /usr/lib/mono/4.5/
RUN sudo chmod 0755 /usr/lib/mono/4.5/Assembly-CSharp.dll

# build
RUN curl -L https://github.com/godarklight/DarkMultiPlayer/archive/v"$dmp_version".zip -o /tmp/dmp.zip
RUN unzip /tmp/dmp.zip -d /tmp
RUN xbuild /p:TargetFrameworkVersion="v4.5" /p:DebugSymbols=False /tmp/DarkMultiPlayer-$dmp_version/Common/DarkMultiPlayerCommon.csproj
RUN xbuild /p:TargetFrameworkVersion="v4.5" /p:DebugSymbols=False /tmp/DarkMultiPlayer-$dmp_version/Server/Server.csproj
