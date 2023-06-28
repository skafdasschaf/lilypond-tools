TMPDIR=$(mktemp -d)

mkdir -p $TMPDIR

for f in $(ls */full_score.pdf); do
  pdfseparate -l 1 $f $TMPDIR/$(dirname $f).pdf
done

pdfunite $TMPDIR/*.pdf all_first_pages.pdf

rm -r $TMPDIR
