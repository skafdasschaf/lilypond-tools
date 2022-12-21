\version "2.22.0"

\paper {
  indent = 1\cm
  top-margin = 1\cm
  bottom-margin = .5\cm
  outer-margin = 1.5\cm
  inner-margin = 1.5\cm
  system-separator-markup = ##f

  oddFooterMarkup = \markup {}
  evenFooterMarkup = \markup {}
  oddHeaderMarkup = \markup {
    \fill-line {
      " " \fromproperty #'page:page-number-string
    }
  }
  evenHeaderMarkup = \markup {
    \fromproperty #'page:page-number-string
  }

  system-system-spacing =
    #'((basic-distance . 17)
       (minimum-distance . 17)
       (padding . -100)
       (stretchability . 0))

  top-system-spacing =
    #'((basic-distance . 10)
       (minimum-distance . 10)
       (padding . -100)
       (stretchability . 0))

  top-markup-spacing =
    #'((basic-distance . 0)
       (minimum-distance . 0)
       (padding . -100)
       (stretchability . 0))

  markup-system-spacing =
    #'((basic-distance . 10)
       (minimum-distance . 10)
       (padding . -100)
       (stretchability . 0))

  last-bottom-spacing =
    #'((basic-distance . 0)
       (minimum-distance . 0)
       (padding . 0)
       (stretchability . 1.0e7))

  systems-per-page = #3
}

#(define option-instrument-name
  (if (not (defined? 'option-instrument-name))
  "org"
  option-instrument-name))

\layout {
  \context {
    \Lyrics
    \override LyricText.font-size = #-.5
  }
  \context {
    \ChoirStaff
    \setGroupDistance #12 #13
  }
  \context {
    \Staff
    instrumentName = #option-instrument-name
  }
}

#(set-global-staff-size 15.87)
