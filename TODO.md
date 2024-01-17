# TODOs and ideas

- keep subtitle and id separated
- add `\once \override Score.RehearsalMark.break-visibility = ##(#t #t #f)` to \markDaCapo
- use biblatex/biber to print an optional bibliography
- maybe directives such as “poco f” and “p assai” should be centered on the dynamics letter
- generate cover for KDP automatically
- add macro for `\set Staff.soloText = \markup \remark \medium "cl 1"` and similar commands
- add information on contents of the print folder (printer.yaml etc)
- add instructions for spacing in accompagnatos (like 8 staves per system, but 3 systems per page)
- add macro `hA = \once \override Accidental.stencil = ##f`
- ees-template: change .gitignore so that links to a manuscript folder are also ignored 
- ad macro \marcCritnote:
  ```
  markCritnote = {
    \once \override Score.RehearsalMark.break-visibility = #begin-of-line-invisible
    \mark \markup \normalsize \critnote
  }
  ```
- add macro `\fivehatflat` (see Eybler's PM)
