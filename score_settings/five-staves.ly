\version "2.22.0"

\paper {
  indent = 1\cm
  top-margin = 1.5\cm
  bottom-margin = 1.5\cm
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
    #'((basic-distance . 22)
       (minimum-distance . 22)
       (padding . -100)
       (stretchability . 0))

  top-system-spacing =
    #'((basic-distance . 12)
       (minimum-distance . 12)
       (padding . -100)
       (stretchability . 0))

  top-markup-spacing =
    #'((basic-distance . 0)
       (minimum-distance . 0)
       (padding . -100)
       (stretchability . 0))

  markup-system-spacing =
    #'((basic-distance . 12)
       (minimum-distance . 12)
       (padding . -100)
       (stretchability . 0))

  last-bottom-spacing =
    #'((basic-distance . 0)
       (minimum-distance . 0)
       (padding . 0)
       (stretchability . 1.0e7))

  systems-per-page = #2
}

#(if
  (not (defined? 'option-instrument-name-upper))
  (define option-instrument-name-upper "")
)
#(if
  (not (defined? 'option-instrument-name-lower))
  (define option-instrument-name-lower "")
)

\layout {
  \context {
    \StaffGroup
    instrumentName = #option-instrument-name-upper
    \setGroupDistance #12 #15
  }
  \context {
    \GrandStaff
    \setGroupDistance #12 #12
  }
  \context {
    \Staff
    instrumentName = #option-instrument-name-lower
  }
}

#(set-global-staff-size 17.82)
