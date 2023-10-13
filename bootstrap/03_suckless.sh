#!/bin/bash

echo "[SUCKLESS] installing..."


cd ~
echo "[SUCKLESS][9base] installing..."
git clone https://git.suckless.org/9base > /dev/null 2>&1
cd 9base
make clean > /dev/null 2>&1
sudo make install > /dev/null 2>&1
echo "[SUCKLESS][9base] installed."

cd ~
echo "[SUCKLESS][grapheme] installing..."
git clone https://git.suckless.org/libgrapheme > /dev/null 2>&1
cd libgrapheme
./configure > /dev/null 2>&1
make clean > /dev/null 2>&1
sudo make install > /dev/null 2>&1
echo "[SUCKLESS][grapheme] installed."

cd ~
echo "[SUCKLESS][lchat] installing..."
git clone https://git.suckless.org/lchat > /dev/null 2>&1
cd lchat
make clean > /dev/null 2>&1
sudo make install > /dev/null 2>&1
echo "[SUCKLESS][lchat] installed."

cd ~
echo "[SUCKLESS][quark] installing..."
git clone https://git.suckless.org/quark > /dev/null 2>&1
cd quark
sudo make install > /dev/null 2>&1
echo "[SUCKLESS][quark] installed."

cd ~
echo "[SUCKLESS][dmenu] installing..."
git clone git://git.suckless.org/dmenu > /dev/null 2>&1
cd dmenu
make clean > /dev/null 2>&1
sudo make clean install > /dev/null 2>&1
echo "[SUCKLESS][dmenu] installed."

cd ~
echo "[SUCKLESS][dwm] installing..."
git clone git://git.suckless.org/dwm > /dev/null 2>&1
cd dwm
make clean > /dev/null 2>&1
sudo make clean install > /dev/null 2>&1
echo "[SUCKLESS][dwm] installed."

cd ~
echo "[SUCKLESS][sic] installing..."
git clone git://git.suckless.org/sic > /dev/null 2>&1
cd sic
make clean > /dev/null 2>&1
make > /dev/null 2>&1
sudo make install > /dev/null 2>&1
echo "[SUCKLESS][sic] installed."

cd ~
echo "[SUCKLESS][ii] installing..."
git clone git://git.suckless.org/ii > /dev/null 2>&1
cd ii
make clean > /dev/null 2>&1
make > /dev/null 2>&1
sudo cp ii /bin/ii > /dev/null 2>&1
echo "[SUCKLESS][ii] installed."

echo "[SUCKLESS] installed."
