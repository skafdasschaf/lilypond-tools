#!/bin/sh

# add user with the same uid/gid as the user that runs Docker
# to prevent permission issues with generated files
if [ -n "$user_id" ] && [ -n "$group_id" ]; then
  addgroup --gid $group_id engraver
  adduser --disabled-password --gecos '' --uid $user_id --gid $group_id engraver
fi

# General utils
apt-get update
apt-get install zip

# EES Tools
git clone https://github.com/edition-esser-skala/ees-tools.git
mv ees-tools /opt/ees-tools

# Python packages
pip install GitPython numpy pandas segno strictyaml termcolor texoutparse
git config --global --add safe.directory /ees  # required by GitPython
git config --global --add safe.directory /github/workspace

# TinyTex
wget https://yihui.org/tinytex/install-bin-unix.sh
export TINYTEX_VERSION=2022.12
sh install-bin-unix.sh
mv /root/.TinyTeX /opt/tinytex
/opt/tinytex/bin/x86_64-linux/tlmgr option sys_bin /usr/local/bin
/opt/tinytex/bin/x86_64-linux/tlmgr path add
tlmgr conf auxtrees add $EES_TOOLS_PATH
tlmgr install `cat tinytex_packages.txt`
chmod -R a+rw /opt/tinytex

# LilyPond
wget https://gitlab.com/lilypond/lilypond/-/releases/v2.24.0/downloads/lilypond-2.24.0-linux-x86_64.tar.gz
tar xvfz lilypond-2.24.0-linux-x86_64.tar.gz
mv lilypond-2.24.0 /opt/lilypond

# Fonts
wget https://github.com/google/fonts/raw/main/ofl/frederickathegreat/FrederickatheGreat-Regular.ttf
mv FrederickatheGreat-Regular.ttf /usr/share/fonts

wget https://github.com/adobe-fonts/source-sans/releases/download/3.046R/OTF-source-sans-3.046R.zip
unzip OTF-source-sans-3.046R.zip
mv OTF/*.otf /usr/share/fonts

rm -rf *
