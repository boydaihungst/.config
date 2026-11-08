#!/usr/bin/env bash

sudo dnf install -y \
  gcc-c++ \
  cmake \
  make \
  git \
  fcitx5-devel \
  golang \
  extra-cmake-modules \
  fcitx5 \
  fcitx5-configtool \
  fcitx5-gtk \
  fcitx5-qt \
  fcitx5-gtk4

git clone https://github.com/fcitx/fcitx5-bamboo
cd fcitx5-bamboo || exit
git submodule update --init --recursive
rm -rf ./build
mkdir ./build
cd build || exit
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make -j"$(nproc)"
sudo make install
sudo gtk-update-icon-cache -f /usr/share/icons/hicolor
