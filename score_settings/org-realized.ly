\version "2.22.0"

\paper {
  indent = 1\cm
  top-margin = 1\cm
  bottom-margin = .5\cm
  outer-margin = 1.5\cm
  inner-margin = 1.5\cm
  system-separator-markup = ##f

  oddHeaderMarkup = \markup {}
  evenHeaderMarkup = \markup {}
  oddFooterMarkup = \markup {
    \fill-line {
      " " \fromproperty #'page:page-number-string " "
    }
  }
  evenFooterMarkup = \markup {
    \fill-line {
      " " \fromproperty #'page:page-number-string " "
    }
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

  systems-per-page = #6
}

\layout {
  \context {
    \PianoStaff
    instrumentName = "org"
  }
}

#(set-global-staff-size 17.82)
