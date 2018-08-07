#!/bin/bash

# Upgrading all installed softwares
apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoremove
apt-get clean

# Some basics tools
apt-get -y install build-essential git iperf3 meld nmap openssh-server procserv socat ttf-mscorefonts-installer unrar-free

# NTP client
apt-get -y install ntp
sed -i -e '21,24s/^/#/' -e '27s/^/#/' -e '$a\\npool pool.ntp.br' /etc/ntp.conf
systemctl restart ntp

# Epics Base
apt-get -y install libreadline-gplv2-dev
cd /opt
mkdir epics-R3.15.5
cd epics-R3.15.5
wget https://epics.anl.gov/download/base/base-3.15.5.tar.gz
tar -xvzf base-3.15.5.tar.gz
rm base-3.15.5.tar.gz
mv base-3.15.5 base
cd base
make

# asynDriver
cd /opt/epics-R3.15.5
mkdir modules
cd modules
wget https://www.aps.anl.gov/epics/download/modules/asyn4-33.tar.gz
tar -xvzf asyn4-33.tar.gz
rm asyn4-33.tar.gz
sed -i -e '3,4s/^/#/' -e '8s/^/#/' -e '11s/^/#/' -e '14cEPICS_BASE=/opt/epics-R3.15.5/base' asyn4-33/configure/RELEASE
cd asyn4-33
make

#synApps calc module
cd /opt/epics-R3.15.5/modules
mkdir synApps
cd synApps
wget https://github.com/epics-modules/calc/archive/R3-7-1.tar.gz
tar -xvzf R3-7-1.tar.gz
rm R3-7-1.tar.gz
sed -i -e '5s/^/#/' -e '7,8s/^/#/' -e '13s/^/#/' -e '20cEPICS_BASE=/opt/epics-R3.15.5/base' calc-R3-7-1/configure/RELEASE
cd calc-R3-7-1
make

# StreamDevice
apt-get -y install libpcre3-dev
cd /opt/epics-R3.15.5/modules
mkdir StreamDevice-2.7.11
cd StreamDevice-2.7.11
echo '' | makeBaseApp.pl -t support && echo ''
wget https://github.com/paulscherrerinstitute/StreamDevice/archive/stream_2_7_11.tar.gz
tar -xvzf stream_2_7_11.tar.gz
rm stream_2_7_11.tar.gz
sed -i -e '28iASYN=/opt/epics-R3.15.5/modules/asyn4-33' configure/RELEASE
sed -i -e '29iCALC=/opt/epics-R3.15.5/modules/synApps/calc-R3-7-1' configure/RELEASE
echo 'PCRE_INCLUDE=/usr/include' > configure/RELEASE.Common.linux-x86_64
echo 'PCRE_LIB=/usr/lib/x86_64-linux-gnu' >> configure/RELEASE.Common.linux-x86_64
sed -i -e '20istreamApp_DBD += system.dbd' StreamDevice-stream_2_7_11/streamApp/Makefile
rm StreamDevice-stream_2_7_11/GNUmakefile
sed -i -e '11iDIRS += StreamDevice-stream_2_7_11' Makefile
make

# Sequencer
apt-get -y install re2c
cd /opt/epics-R3.15.5/modules
wget http://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-2.2.6.tar.gz
tar -xvzf seq-2.2.6.tar.gz
rm seq-2.2.6.tar.gz
sed -i -e '6cEPICS_BASE=/opt/epics-R3.15.5/base' seq-2.2.6/configure/RELEASE
cd seq-2.2.6
make

# PV Gateway
cd /opt/epics-R3.15.5/modules
wget https://github.com/epics-extensions/ca-gateway/archive/R2-1-0-0.tar.gz
tar -xvzf R2-1-0-0.tar.gz
rm R2-1-0-0.tar.gz
echo 'EPICS_BASE=/opt/epics-R3.15.5/base' > ca-gateway-R2-1-0-0/configure/RELEASE.local
cd ca-gateway-R2-1-0-0
make

# MEDM
apt-get -y install libxpm-dev
cd /opt/epics-R3.15.5/extensions/src
wget https://github.com/epics-extensions/medm/archive/MEDM3_1_14.tar.gz
tar -xvzf MEDM3_1_14.tar.gz
rm MEDM3_1_14.tar.gz
cd medm-MEDM3_1_14
make
cd /etc/X11/fonts/misc
wget https://epics.anl.gov/EpicsDocumentation/ExtensionsManuals/MEDM/medmfonts.ali.txt
mv medmfonts.ali.txt medm.alias
update-fonts-alias misc

# Epics Base (R3.14)
cd /opt
mkdir epics-R3.14.12.7
cd epics-R3.14.12.7
wget https://epics.anl.gov/download/base/baseR3.14.12.7.tar.gz
tar -xvzf baseR3.14.12.7.tar.gz
rm baseR3.14.12.7.tar.gz
mv base-3.14.12.7 base
cd base
make

# netDev
cd /opt/epics-R3.14.12.7
mkdir modules
cd modules
wget http://www-linac.kek.jp/cont/epics/netdev/netDev-1.0.3.tar.gz
tar -xvzf netDev-1.0.3.tar.gz
rm netDev-1.0.3.tar.gz
sed -i -e '18cEPICS_BASE=/opt/epics-R3.14.12.7/base' netDev-1.0.3/configure/RELEASE
cd netDev-1.0.3
make

# EtherIp
cd /opt/epics-R3.14.12.7/modules
wget https://github.com/EPICSTools/ether_ip/archive/ether_ip-2-27.tar.gz
tar -xvzf ether_ip-2-27.tar.gz
rm ether_ip-2-27.tar.gz
sed -i -e '11s/^/#/' -e '12iEPICS_BASE=/opt/epics-R3.14.12.7/base' ether_ip-ether_ip-2-27/configure/RELEASE
cd ether_ip-ether_ip-2-27
make

# Python Environment
apt-get -y install python3-pip
pip3 install matplotlib numpy
apt-get -y install swig
pip3 install pcaspy
NOLIBCA=1 pip3 install pyepics
pip3 install pyqtgraph pyserial scipy

# PyDM and PyQT
apt-get -y install pyqt5-dev-tools python3-pyqt5 python3-pyqt5.qtsvg python3-pyqt5.qtwebkit qttools5-dev-tools
cd /opt
wget https://github.com/slaclab/pydm/archive/v1.3.0.tar.gz
tar -xvzf v1.3.0.tar.gz
rm v1.3.0.tar.gz
sed -i -e '27s/extras/#extras/' -e '28i\ \ \ \ pass' pydm-1.3.0/setup.py
cd pydm-1.3.0
pip3 install .[all]
sed -i -e '$a\PYQTDESIGNERPATH=/opt/pydm-1.3.0' /etc/environment

# Oracle VM VirtualBox
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian bionic contrib"
apt-get -y install virtualbox-5.2

# Docker
apt-get -y install apt-transport-https curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic edge"
apt-get install -y docker-ce

# Wireshark
apt-get -y install tshark wireshark
chmod 755 /usr/bin/dumpcap
cd /opt
git clone https://github.com/mdavidsaver/cashark.git
sed -i -e '$a\\ndofile("/opt/cashark/ca.lua")' /etc/wireshark/init.lua

# KiCad Suite
add-apt-repository --yes ppa:js-reynaud/kicad-4
apt-get update
apt-get -y install kicad

# Atom
curl -sL https://packagecloud.io/AtomEditor/atom/gpgkey | apt-key add -
add-apt-repository "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main"
apt-get -y install atom

# Tilix
apt-get -y install tilix
update-alternatives --config x-terminal-emulator
