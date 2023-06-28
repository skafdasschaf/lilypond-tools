#!/bin/bash

if [ $# -eq 0 ]; then
  echo "usage:"
  echo "\$1 = pdf file with images"
  echo "\$2 = [width]x[height] of half page in pixels"
  echo ""
  echo "example:"
  echo "split_image score.pdf 768x690"
  exit 0
fi

mkdir left
mkdir right
pdfimages -j $1 img
mogrify -gravity west -crop $2+0+0 -path left *.jpg
mogrify -gravity east -crop $2+0+0 -path right *.jpg
rm *.jpg
perl-rename 's/(.*).jpg/$1-left.jpg/' left/*
perl-rename 's/(.*).jpg/$1-right.jpg/' right/*
mv left/* .
mv right/* .
rmdir left
rmdir right
