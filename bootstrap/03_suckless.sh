ucd ~
git clone https://git.suckless.org/9base
cd 9base
sudo make install

cd ~
git clone https://git.suckless.org/libgrapheme
cd libgrapheme
./configure
sudo make install

cd ~
git clone https://git.suckless.org/lchat
cd lchat
sudo make install

cd ~
git clone https://git.suckless.org/quark
cd quark
sudo make install

cd ~
git clone git://git.suckless.org/dmenu
cd dmenu
sudo make clean install

cd ~
git clone git://git.suckless.org/dwm
cd dwm
sudo make clean install

cd ~
git clone git://git.suckless.org/sic
cd sic
make
sudo make install

cd ~
git clone git://git.suckless.org/ii
cd ii
make
sudo cp ii /bin/ii


