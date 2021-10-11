#!/bin/bash

# check for updates (64-bit OS is still under development!)
sudo apt-get update
sudo apt-get upgrade
# install dependencies
sudo apt-get install cmake wget
sudo apt-get install libprotobuf-dev protobuf-compiler
# download ncnn
git clone --depth=1 https://github.com/Tencent/ncnn.git
# install ncnn
cd ncnn
mkdir build
cd build
# build 64-bit ncnn
cmake -D CMAKE_TOOLCHAIN_FILE=../toolchains/aarch64-linux-gnu.toolchain.cmake \
        -D NCNN_DISABLE_RTTI=OFF ..
make -j4
make install
# copy output to dirs
sudo mkdir /usr/local/lib/ncnn
sudo cp -r install/include/ncnn /usr/local/include/ncnn
sudo cp -r install/lib/libncnn.a /usr/local/lib/ncnn/libncnn.a
# once you've placed the output in your /usr/local directory,
# you may delete the ncnn directory if you have no tools or examples compiled
cd ~
sudo rm -rf ncnn

# TODO test libncnn.a in /usr/local/lib/ncnn