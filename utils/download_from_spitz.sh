#!/bin/bash

if [ $# -eq 0 ]; then
  echo "usage:"
  echo "\$1 = Mirador ID (evident, e.g., from IIIF manifest)"
  echo "\$2 = last page"
  echo ""
  echo "example:"
  echo "download_from_spitz.sh D-NATk_H71 31"
  exit 0
fi

img_url_left="https://iiif.acdh-dev.oeaw.ac.at/iiif/images/musikarchivspitz/$1/$1-"
img_url_right=".jp2/full/full/0/default.jpg"

for page in $(seq 1 $2); do
  img_url_page=`printf %3s $page | tr " " 0`
  wget --output-document $img_url_page.jpg "$img_url_left$img_url_page$img_url_right"
done

