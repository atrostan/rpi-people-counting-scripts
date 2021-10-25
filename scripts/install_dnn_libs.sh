#!/bin/bash

# ################################################################################################
# Section 1: Install Opencv 
# ################################################################################################

# (~1.5 hrs)
# TODO programmtically verify correct 64bit os installed

uname -a
gcc -v

# if needed, to update the firmware
sudo rpi-eeprom-update -a
sudo reboot

# check for updates (64-bit OS is still under development!)
sudo apt-get update
sudo apt-get upgrade

echo "Installing OpenCV 4.5.3 on your Raspberry Pi 64-bit OS"
echo "It will take minimal 1.5 hour !"
cd ~
# install the dependencies
sudo apt-get install -y build-essential cmake git unzip pkg-config
sudo apt-get install -y libjpeg-dev libtiff-dev libpng-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
sudo apt-get install -y libgtk2.0-dev libcanberra-gtk* libgtk-3-dev
sudo apt-get install -y libxvidcore-dev libx264-dev
sudo apt-get install -y python3-dev python3-numpy python3-pip
sudo apt-get install -y libtbb2 libtbb-dev libdc1394-22-dev
sudo apt-get install -y libv4l-dev v4l-utils
sudo apt-get install -y libopenblas-dev libatlas-base-dev libblas-dev
sudo apt-get install -y liblapack-dev gfortran libhdf5-dev
sudo apt-get install -y libprotobuf-dev libgoogle-glog-dev libgflags-dev
sudo apt-get install -y protobuf-compiler

# download the latest version

# TODO programmatically query the latest version of opencv(?)
# TODO OPEN_CV_VERSION=4.5.4

cd ~ 
sudo rm -rf opencv*
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.5.4.zip 
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.5.4.zip 
# unpack
unzip opencv.zip 
unzip opencv_contrib.zip 
# some administration to make live easier later on
mv opencv-4.5.4 opencv
mv opencv_contrib-4.5.4 opencv_contrib
# clean up the zip files
rm opencv.zip
rm opencv_contrib.zip

# set install dir
cd ~/opencv
mkdir build
cd build

# run cmake
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
-D ENABLE_NEON=ON \
-D WITH_OPENMP=ON \
-D WITH_OPENCL=OFF \
-D BUILD_TIFF=ON \
-D WITH_FFMPEG=ON \
-D WITH_TBB=ON \
-D BUILD_TBB=ON \
-D WITH_GSTREAMER=OFF \
-D BUILD_TESTS=OFF \
-D WITH_EIGEN=OFF \
-D WITH_V4L=ON \
-D WITH_LIBV4L=ON \
-D WITH_VTK=OFF \
-D WITH_QT=OFF \
-D OPENCV_ENABLE_NONFREE=ON \
-D INSTALL_C_EXAMPLES=OFF \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D BUILD_opencv_python3=TRUE \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D BUILD_EXAMPLES=OFF ..

# run make
make -j4
sudo make install
sudo ldconfig

# cleaning (frees 300 MB)
make clean
sudo apt-get update

echo "Congratulations!"
echo "You've successfully installed OpenCV 4.5.3 on your Raspberry Pi 64-bit OS"

# TODO Test installation of OPENCV

# ```python
# python3
# >>> import cv2
# >>> cv2.__version__
# '4.5.4'
# ```

# OpenCV will be installed to the /usr/local directory, all files will be copied to following locations:

# - /usr/local/bin - executable files
# - /usr/local/lib - libraries (.so)
# - /usr/local/cmake/opencv4 - cmake package
# - /usr/local/include/opencv4 - headers
# - /usr/local/share/opencv4 - other files (e.g. trained cascades in XML format)


# ################################################################################################
# Section 2: Install ncnn
# ################################################################################################

# (~1 hr)

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

# ################################################################################################
# Section 2: Download Models, Install inference drivers 
# ################################################################################################
cd ~
mkdir inference 
cd inference
mkdir ssd
mkdir frcnn

# Section 2.1: FRCNN Models
cd frcnn
git clone https://github.com/Qengineering/Faster_RCNN_ncnn.git

cd Faster_RCNN_ncnn

# needed to download FRCNN model bin from google drive
pip install gdown

python -c "import gdown; url = 'https://drive.google.com/uc?id=1w3F4PL03SVtvoS_ux_GfCkY0YLMGH-yA'; output = 'ZF_faster_rcnn_final.bin'; gdown.download(url, output, quiet=False)"

# TODO copy makefile from current github repo to this dir
# HERE
make

# run inference on sample image
./bin/Release/Faster_RCNN_ncnn ./Traffic.jpg

# Section 2.2: SSD Models
cd ../../ssd
# download .param and .bin files of models
wget -O mobilenet_ssd_voc_ncnn.bin https://github.com/nihui/ncnn-assets/blob/master/models/mobilenet_ssd_voc_ncnn.bin?raw=true
wget https://raw.githubusercontent.com/nihui/ncnn-assets/master/models/mobilenet_ssd_voc_ncnn.param

# download driver script 
wget https://raw.githubusercontent.com/Tencent/ncnn/master/examples/mobilenetssd.cpp

# TODO copy makefile from current github repo to this dir
# HERE
make

# run inference on sample image
./bin/Release/mobilenetssd ../frcnn/Faster_RCNN_ncnn/Traffic.jpg
