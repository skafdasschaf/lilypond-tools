\version "2.22.0"

\paper {
  indent = 1\cm
  top-margin = 1.5\cm
  system-separator-markup = ##f
  system-system-spacing =
    #'((basic-distance . 17)
       (minimum-distance . 17)
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

  systems-per-page = #4
}

#(if
  (not (defined? 'ees-instrument-abbreviation-upper))
  (define ees-instrument-abbreviation-upper "")
)
#(if
  (not (defined? 'ees-instrument-abbreviation-lower))
  (define ees-instrument-abbreviation-lower "")
)

\layout {
  \context {
    \GrandStaff
    instrumentName = #ees-instrument-abbreviation-upper
    \override StaffGrouper.staffgroup-staff-spacing =
      #'((basic-distance . 12)
         (minimum-distance . 12)
         (padding . -100)
         (stretchability . 0))
    \override StaffGrouper.staff-staff-spacing =
      #'((basic-distance . 12)
         (minimum-distance . 12)
         (padding . -100)
         (stretchability . 0))
  }
  \context {
    \Staff
    instrumentName = #ees-instrument-abbreviation-lower
  }
}

#(set-global-staff-size 17.82)
