#!/bin/sh

# EES Tools
git clone https://github.com/edition-esser-skala/ees-tools.git
mv ees-tools /ees-tools

# Python packages
pip install numpy pandas GitPython PyYAML

# TinyTex
wget https://yihui.org/tinytex/install-bin-unix.sh
TINYTEX_VERSION=2021.11
sh install-bin-unix.sh
tlmgr conf auxtrees add $EES_TOOLS_PATH
tlmgr install `cat tinytex_packages.txt`

# LilyPond
apt-get update
apt-get install -y --no-install-recommends lilypond

# Fonts
wget https://github.com/google/fonts/raw/main/ofl/frederickathegreat/FrederickatheGreat-Regular.ttf
mv FrederickatheGreat-Regular.ttf /usr/share/fonts

wget https://github.com/adobe-fonts/source-sans/releases/download/3.046R/OTF-source-sans-3.046R.zip
unzip OTF-source-sans-3.046R.zip
mv OTF/*.otf /usr/share/fonts

rm -rf *
