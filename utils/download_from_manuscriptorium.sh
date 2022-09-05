# usage:
# $1 = Manuscriptorium ID
# $2 = last page
#
# example:
# download_from_manuscriptorium.sh AIPDIG-NKCR__59_R_3525___0O7CCJ7-cs 35

img_url_left="https://imagines.manuscriptorium.com/loris/$1/ID"
img_url_right="/full/full/0/default.jpg"

for page in $(seq 1 $2); do
  for side in r v; do  
    img_url_page=`printf %4s $page | tr " " 0`
    wget --output-document $img_url_page$side.jpg "$img_url_left$img_url_page$side$img_url_right"
  done
done

