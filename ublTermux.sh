#!/data/data/com.termux/files/usr/bin/bash

pkg update -y

echo "Installing termux-adb......"
apt-get update
apt-get  --assume-yes upgrade
apt-get  --assume-yes install coreutils gnupg wget
if [ ! -f "$PREFIX/etc/apt/sources.list.d/termux-adb.list" ]; then
  mkdir -p $PREFIX/etc/apt/sources.list.d
  echo -e "deb https://nohajc.github.io termux extras" > $PREFIX/etc/apt/sources.list.d/termux-adb.list
  wget -qP $PREFIX/etc/apt/trusted.gpg.d https://nohajc.github.io/nohajc.gpg
  apt update
  apt install termux-adb
else
  echo "Repo already installed"
  apt install termux-adb
fi

echo "done!"

rm motounlock.sh

curl -s https://raw.githubusercontent.com/SantoshKumarOjha/MotoG34_fogos/main/MotoBLUnlock_termux.sh > motounlock.sh

echo "Running Unlock Script..."
bash motounlock.sh
