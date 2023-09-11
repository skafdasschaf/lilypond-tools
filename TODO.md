# TODO

- `l = \markup { \hspace #-0.9 \transparent \figured-bass 0 }`
- piano assai (see Kolberer, Miserere in D minor); or implement general scheme function dynScriptSuffix
- implement bibliography in front matter
- maybe we can align poco f etc on the f ?
- table with incipit distances, also including
  \incipit \markup \center-column { "Soprano" "[Violino I]" } "soprano" #-21.3 #-0.3
  \incipit \markup \center-column { "Alto" "[Violino II]" } "alto" #-21.8 #-0.3
  \incipit \markup \center-column { "Tenore" "[Viola]" } "tenor" #-19.6 #-0.3
- see MH 628, 98 for gregorian notation
- update \vlc and \bassi
- include sacral-lyrics, add metadata to this repo
- \fivehat = \markup {
  \combine
  \figured-bass 5
  \path #.15 #'(
    (rmoveto 0 1.2)
    (rlineto .5 .5)
    (rlineto .5 -.5))
}
