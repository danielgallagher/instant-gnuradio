#!/bin/bash

set -eux

export LANG=en_US.UTF-8
export PATH="$HOME/.local/bin:${PATH}"

cd
sudo mv 90-usrp.conf /etc/sysctl.d/

sudo apt update

### PYBOMBS
sudo pip3 install pybombs
pybombs auto-config
pybombs recipes add-defaults


### PlutoSDR Support
sudo apt -y install build-essential libxml2 libxml2-dev bison flex libcdk5-dev cmake git libaio-dev libboost-all-dev libgmp-dev
sudo apt -y install doxygen graphviz
sudo apt -y install libusb-1.0-0-dev libserialport-dev libavahi-client-dev 
sudo apt -y install libavahi-common-dev libavahi-client-dev
sudo apt -y install swig
sudo apt -y install liborc-dev 
sudo apt-get -y install python3 python3-pip python3-setuptools

### LIBIIO
cd /home/gnuradio/src
git clone https://github.com/pcercuei/libini.git
cd libini
mkdir build && cd build && cmake ../ && make && sudo make install
cd ~

cd /home/gnuradio/src
git clone https://github.com/analogdevicesinc/libiio.git
cd libiio
mkdir build
cd build
cmake ../ -DPYTHON_BINDINGS=ON
make all
sudo make install
sudo ldconfig
cd bindings/python/
#sudo python3 setup.py.cmakein install
cd ~
sudo mv 53-adi-plutosdr-usb.rules /etc/udev/rules.d/

## LIBAD9361
cd /home/gnuradio/src
git clone https://github.com/analogdevicesinc/libad9361-iio.git
cd libad9361-iio
cmake .
make 
sudo make install
cd ~

### IIO OSCILLOSCOPE
sudo apt-get -y install libglib2.0-dev libgtk2.0-dev libgtkdatabox-dev libmatio-dev libfftw3-dev libxml2 libxml2-dev bison flex libavahi-common-dev libavahi-client-dev libcurl4-openssl-dev libjansson-dev cmake libaio-dev

cd /home/gnuradio/src

git clone https://github.com/analogdevicesinc/iio-oscilloscope.git
cd iio-oscilloscope
git checkout origin/master
mkdir build && cd build
cmake ../ && make -j $(nproc)
sudo make install
cd ~

### ADI TOOLS
git clone https://github.com/analogdevicesinc/plutosdr_scripts.git ~/.adi/plutosdr_scripts
git clone https://github.com/analogdevicesinc/linux_image_ADI-scripts.git ~/.adi/linux_scripts

#sudo ~/.adi/linux_scripts/adi_update_tools.sh

echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib' >> .profile
echo 'export PYTHONPATH=${PYTHONPATH}:/usr/local/lib/python3/dist-packages' >> .profile
echo 'export PYTHONPATH=${PYTHONPATH}:/usr/local/lib/python3/site-packages' >> .profile
echo 'export PYTHONPATH=${PYTHONPATH}:/usr/local/lib/python3.8/dist-packages' >> .profile
echo 'export PYTHONPATH=${PYTHONPATH}:/usr/local/lib/python3.8/site-packages' >> .profile

cd /tmp
sudo mkdir /tmp/isomount
sudo mount -t iso9660 -o loop /home/gnuradio/VBoxGuestAdditions.iso /tmp/isomount

# Install the drivers
yes | sudo /tmp/isomount/VBoxLinuxAdditions.run || echo

# Cleanup
sudo umount isomount
sudo rm -rf isomount /home/gnuradio/VBoxGuestAdditions.iso

echo "gnuradio - rtprio 99" | sudo tee -a /etc/security/limits.conf
sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get -y install jupyter jupyter-qtconsole jupyter-notebook python3-matplotlib python3-ipython python3-scipy python3-numpy python3-pip multimon-ng sox liborc-dev swig3.0

#sudo add-apt-repository -y ppa:gnuradio/gnuradio-releases # Disable until gr-iio supports gr3.9
sudo add-apt-repository -y ppa:gnuradio/gnuradio-releases-3.8
sudo add-apt-repository -y ppa:mormj/gnuradio-oot3
sudo apt-get update

sudo apt-get -y install gnuradio
sudo apt-get -y install gr-fcdproplus gr-fosphor gr-iqbal gr-limesdr gr-osmosdr

sudo apt-get -y install gqrx-sdr inspectrum

## SoapyPlutoSDR
sudo apt-get -y install libsoapysdr-dev
cd /home/gnuradio/src
git clone https://github.com/pothosware/SoapyPlutoSDR
cd SoapyPlutoSDR
mkdir build
cd build
cmake ..
make
sudo make install
cd ~

sudo apt-get -y install soapysdr-tools soapysdr-module-all

### GR IIO
cd /home/gnuradio/src
git clone -b upgrade-3.8 https://github.com/danielgallagher/gr-iio.git
cd gr-iio
cmake .
make 
sudo make install
cd ..
sudo ldconfig
cd ~


### PyADI
#cd /home/gnuradio/src
#git clone https://github.com/analogdevicesinc/pyadi-iio.git
#cd pyadi-iio
#sudo python3 setup.py install
pip3 install pyadi-iio
pip3 install pylibiio
#cd ~

# Interim Error Workarounds
echo "alias python='python3'" >> ~/.bashrc
echo "alias python='python3'" >> ~/.zshrc

# Get Pluto GR-IIO Test File
cd /home/gnuradio/Documents
wget "https://raw.githubusercontent.com/sdrforengineers/LabGuides/master/grcon2020/PlutoTestSine_38.grc"
cd ~

sudo snap install urh

sudo usermod -aG usrp gnuradio
sudo apt-get -y install clinfo mesa-utils
sudo usermod -aG video gnuradio
sudo usermod -aG dialout gnuradio
sudo usermod -aG lpadmin gnuradio

sudo apt-get -y install intel-opencl-icd lsb-core

sudo /usr/lib/uhd/utils/uhd_images_downloader.py

cd ~/Downloads
tar xvf l_opencl_p_18.1.0.015.tgz
sudo l_opencl_p_18.1.0.015/install.sh -s opencl-silent.cfg

cd
xdg-icon-resource install --context apps --novendor --size 96 Pictures/gqrx-icon.png
xdg-icon-resource install --context apps --novendor --size 96 Pictures/inspectrum-icon.png
xdg-icon-resource install --context apps --novendor --size 96 Pictures/fosphor-icon.png
xdg-icon-resource install --context apps --novendor --size 96 Pictures/urhpng.png

### CLEAN UP OUR STUFF
sudo apt-get update
sudo apt-get -y upgrade
sudo apt autoremove
rm -rf Downloads/*
sudo rm -rf /home/gnuradio/src

### FAVORITE APPLICATIONS
xvfb-run dconf write /org/gnome/shell/favorite-apps "['gnuradio-grc.desktop', 'gqrx.desktop', 'fosphor.desktop', 'inspectrum.desktop', 'urh.desktop', 'terminator.desktop', 'code_code.desktop', 'gnuradio-web.desktop', 'firefox.desktop', 'org.gnome.Nautilus.desktop']"

### The German Code
# xvfb-run dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'de')]"
