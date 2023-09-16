#!/bin/bash

set -e
clear

# Check if Docker is installed and active
if ! command -v docker &>/dev/null || ! docker info &>/dev/null; then
  echo "Docker is not installed or not active!"
  exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &>/dev/null; then
  echo "Docker Compose is not installed!"
  exit 1
fi

git clone --recursive -j8 https://github.com/mavlink/qgroundcontrol.git
cd qgroundcontrol
git submodule update --recursive

## Modified files
cp ../MainToolBar.qml src/ui/toolbar/MainToolBar.qml
cp ../MainRootWindow.qml src/ui/MainRootWindow.qml
cp ../GuidedActionsController.qml src/FlightDisplay/GuidedActionsController.qml
cp ../FlyView.qml src/FlightDisplay/FlyView.qml

sudo apt-get update && sudo apt-get -y --quiet --no-install-recommends install \
		apt-utils \
		binutils \
		build-essential \
		ca-certificates \
		ccache \
		checkinstall \
		cmake \
		curl \
		espeak \
		fuse \
		g++ \
		gcc \
		git \
		gosu \
		kmod \
		libespeak-dev \
		libfontconfig1 \
		libfuse2 \
		libsdl2-dev \
		libssl-dev \
		libudev-dev \
		locales \
		make \
		ninja-build \
		openssh-client \
		openssl \
		patchelf \
		pkg-config \
		rsync \
		speech-dispatcher \
		wget \
		xvfb \
		zlib1g-dev \
		python3 \
		python3-pip \
	&& sudo apt-get -y autoremove \
	&& sudo apt-get clean autoclean \
	&& sudo rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*


echo "Installing Gstreamer"
PROC=$(lscpu 2>/dev/null | awk '/Architecture/ {if($2 == "x86_64") {print "amd64"; exit} else if($2 ~ /arm/) {print "arm"; exit} else if($2 ~ /aarch64/) {print "arm64"; exit} else {print "386"; exit}}')
if [ "${PROC}" == "arm64" ]; then
  sudo apt-get install -y libgstreamer-plugins-base1.0-dev libgstreamer1.0-0:arm64 libgstreamer1.0-dev
  docker build --file ./deploy/docker/Dockerfile-build-linux -t qgc-linux-docker .
else
  sudo apt-get install -y libgstreamer-plugins-base1.0-dev libgstreamer1.0-0:amd64 libgstreamer1.0-dev
  docker build --platform linux/x86_64 --file ./deploy/docker/Dockerfile-build-linux -t qgc-linux-docker .
fi

git config --global core.autocrlf false
sudo -E sh -c 'apt-get remove -y modemmanager; apt-get install -y gstreamer1.0-plugins-bad gstreamer1.0-libav'

mkdir -p build
docker run --rm -v ${PWD}:/project/source -v ${PWD}/build:/project/build qgc-linux-docker
# On Windows the docker command is:
# docker run --rm -v %cd%:/project/source -v %cd%/build:/project/build qgc-linux-docker
cd build
cp QGroundControl.AppImage -o ${HOME}/QGroundControl.AppImage
chmod a+x ${HOME}/QGroundControl.AppImage
