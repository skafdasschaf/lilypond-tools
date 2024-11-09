# TODOs and ideas

- keep subtitle and id separated
- add `\once \override Score.RehearsalMark.break-visibility = ##(#t #t #f)` to \markDaCapo
- use biblatex/biber to print an optional bibliography
- maybe directives such as “poco f” and “p assai” should be centered on the dynamics letter (see WerW I.4.54)
- generate cover for KDP automatically
- add macro for `\set Staff.soloText = \markup \remark \medium "cl 1"` and similar commands
- add information on contents of the print folder (printer.yaml etc)
- add instructions for spacing in accompagnatos (like 8 staves per system, but 3 systems per page)
- add macro `hA = \once \override Accidental.stencil = ##f`
- ees-template: change .gitignore so that links to a manuscript folder are also ignored 
- add macro \marcCritnote:
  ```
  markCritnote = {
    \once \override Score.RehearsalMark.break-visibility = #begin-of-line-invisible
    \mark \markup \normalsize \critnote
  }
  ```
- add macros `\fivehatflat` (see Eybler's PM) and `\fivehatnatural` (HerEy 11)
- add macros `\ignoreMelismas` and `\obeyMelismas` (see Werner PM)
- describe how to use snippets in critical report (see Eybler, Missa S. Wolfgangi); think about custom macros
- add macro `trillFlat = \tweak self-alignment-X #CENTER ^\markup { { \teeny \raise #.5 \flat } \musicglyph #'"scripts.trill" }` and maybe also `trillSharp, trillNatural`
- improve \critnote (use a more decent star)
- create PDF document of editorial guidelines
- add documentation for proprium missae projects (keys in yaml, files ...)
- remove part of makescript that is not required for edition
- updates clef for trombones in template
- alternative \startDeleted and \stopDeleted (see Eybler SM)
- guiedlines: clarify that alto clef in fugues is transcribed as treble ottavo
