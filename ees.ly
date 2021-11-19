\version "2.22.0"
\language "deutsch"

#(if
  (not (defined? 'option-movement-title-format))
  (define option-movement-title-format "title")
)

#(if
  (not (defined? 'option-init-toc))
  (define option-init-toc #f)
)

#(define-markup-command
  (printBookTitle layout props)
  ()
  (cond ((string= option-movement-title-format "genre-number-title")
         (interpret-markup layout props #{
           \markup {
             \fill-line {
               \line {
                 \fontsize #4 {
                   \with-color #(rgb-color .8313 0 0) { \fromproperty #'header:number }
                   \hspace #2
                   \italic { \fromproperty #'header:genre }
                   \hspace #2
                   \fromproperty #'header:title
                 }
               }
             }
           }
         #}))
        ((string= option-movement-title-format "number-title")
         (interpret-markup layout props #{
           \markup {
             \fill-line {
               \line {
                 \fontsize #4 {
                   \with-color #(rgb-color .8313 0 0) { \fromproperty #'header:number }
                   \hspace #2
                   \fromproperty #'header:title
                 }
                 \fontsize #3 \fromproperty #'header:subtitle
               }
             }
           }
         #}))
        ((string= option-movement-title-format "title")
         (interpret-markup layout props #{
           \markup {
             \fill-line {
               \line {
                 \fontsize #4 {
                   \fromproperty #'header:title
                 }
                 \fontsize #3 \fromproperty #'header:subtitle
               }
             }
           }
         #}))))


\paper {
  #(set-paper-size "a4")
  two-sided = ##t
  top-margin = 1\cm
  bottom-margin = .5\cm
  outer-margin = 2\cm
  inner-margin = 1.5\cm
  indent = 1\cm

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
    #'((basic-distance . 20)
       (minimum-distance . 20)
       (padding . -100)
       (stretchability . 0))

  top-system-spacing =
    #'((basic-distance . 20)
       (minimum-distance . 20)
       (padding . -100)
       (stretchability . 0))

  top-markup-spacing =
    #'((basic-distance . 5)
       (minimum-distance . 5)
       (padding . -100)
       (stretchability . 0))

  markup-system-spacing =
    #'((basic-distance . 15)
       (minimum-distance . 15)
       (padding . -100)
       (stretchability . 0))

  last-bottom-spacing =
    #'((basic-distance . 0)
       (minimum-distance . 0)
       (padding . 0)
       (stretchability . 1.0e7))

  score-system-spacing =
    #'((basic-distance . 0)
       (minimum-distance . 0)
       (padding . 0)
       (stretchability . 0))

  score-markup-spacing =
    #'((basic-distance . 0)
       (minimum-distance . 0)
       (padding . 0)
       (stretchability . 0))

  markup-markup-spacing =
    #'((basic-distance . 0)
       (minimum-distance . 0)
       (padding . 0)
       (stretchability . 0))

  system-separator-markup = \markup {
    \center-align
    \vcenter \combine
    \beam #2.0 #0.5 #0.48
    \raise #1.0 \beam #2.0 #0.5 #0.48
  }

  bookTitleMarkup = \markup \printBookTitle

  #(if option-init-toc
       (define (page-post-process layout pages)
               (ly:create-toc-file layout pages)))
}


tempoMarkup = #(define-music-function
  (parser location arg)
  (markup?)
  #{ \tempo \markup \medium { \larger \larger #arg } #})

#(define-markup-command
  (remark layout props text)
  (markup?)
  (interpret-markup layout props
    #{ \markup \small \upright #text #}))

#(define-markup-command
  (remarkE layout props text)
  (markup?)
  (interpret-markup layout props
    #{ \markup \small \italic #text #}))

solo =      \markup \remark  "Solo"
soloE =     \markup \remarkE "Solo"
tutti =     \markup \remark  "Tutti"
tuttiE =    \markup \remarkE "Tutti"
tasto =     \markup \remark  "tasto solo"
tastoE =    \markup \remarkE "tasto solo"
org =       \markup \remark  "Org."
orgE =      \markup \remarkE "Org."
vlc =       \markup \remark  "Vlc."
vlcE =      \markup \remarkE "Vlc."
bassi =     \markup \remark  "Bassi"
bassiE =    \markup \remarkE "Bassi"
tenuto =    \markup \remark  "ten."
tenutoE =   \markup \remarkE "ten."
unisono =   \markup \remark  "unisono"
unisonoE =  \markup \remarkE "unisono"
pizz =      \markup \remark  "pizz."
pizzE =     \markup \remarkE "pizz."
arco =      \markup \remark  "arco"
arcoE =     \markup \remarkE "arco"
senzaOrg =  \markup \remark  "senza Org."
senzaOrgE = \markup \remarkE "senza Org."
colOrg =    \markup \remark  "col’Org."
colOrgE =   \markup \remarkE "col’Org."
dolce =     \markup \remark  "dolce"
dolceE =    \markup \remarkE "dolce"


t = \markup { \combine \fontsize #-2 \transparent \number 5 \raise #.6 \draw-line #'(1 . 0) }
tllur = \markup { \combine \fontsize #-2 \transparent \number 5 \raise #.6 \draw-line #'(1 . 1) }
l = \markup { \fontsize #-2 \transparent \number 5 }
critnote = \markup { \musicglyph #'"pedal.*" }
trillE = \tweak self-alignment-X #CENTER ^\markup { \hspace #1.5 [ \musicglyph #'"scripts.trill" ] }
extraNat = \once \override Accidental.restore-first = ##t
kneeBeam = \once \override Beam.auto-knee-gap = #0
noKneeBeam = \once \override Beam.auto-knee-gap = #5.5
rh = \change Staff = "RH"
lh = \change Staff = "LH"
xE = \override LyricText.font-shape = #'italic
x = \revert LyricText.font-shape

bp = #(define-music-function
  (parser location beg end)
  (number? number?)
  #{ \once \override Beam.positions = #(cons beg end) #})


dynScript = #(define-scheme-function
  (parser location sym extra?)
  (string? boolean?)
  (make-dynamic-script
    (if extra?
      (markup #:line (#:normal-text #:italic #:large #:bold sym))
      (markup #:line (#:normal-text #:large #:bold sym)))))

dynScriptPrefix = #(define-scheme-function
  (parser location prefix sym extra?)
  (string? string? boolean?)
  (make-dynamic-script
    (if extra?
      (markup #:line (
        #:normal-text #:small #:italic prefix
        #:normal-text #:italic #:large #:bold sym))
      (markup #:line (
        #:normal-text #:small prefix
        #:normal-text #:large #:bold sym)))))

ff   = \dynScript "ff"  ##f
ffE  = \dynScript "ff"  ##t
"f"  = \dynScript "f"   ##f
fE   = \dynScript "f"   ##t
mf   = \dynScript "mf"  ##f
mfE  = \dynScript "mf"  ##t
mp   = \dynScript "mp"  ##f
mpE  = \dynScript "mp"  ##t
p    = \dynScript "p"   ##f
pE   = \dynScript "p"   ##t
pp   = \dynScript "pp"  ##f
ppE  = \dynScript "pp"  ##t

sf   = \dynScript "sf"  ##f
sfE  = \dynScript "sf"  ##t
sfp  = \dynScript "sfp" ##f
sfpE = \dynScript "sfp" ##t
sfz  = \dynScript "sfz" ##f
sfzE = \dynScript "sfz" ##t
fp   = \dynScript "fp"  ##f
fpE  = \dynScript "fp"  ##t
fz   = \dynScript "fz"  ##f
fzE  = \dynScript "fz"  ##t
rf   = \dynScript "rf"  ##f
rfE  = \dynScript "rf"  ##t
rfz  = \dynScript "rfz" ##f
rfzE = \dynScript "rfz" ##t

piuF   = \dynScriptPrefix "più"  "f" ##f
piuFE  = \dynScriptPrefix "più"  "f" ##t
piuP   = \dynScriptPrefix "più"  "p" ##f
piuPE  = \dynScriptPrefix "più"  "p" ##t
pocoF  = \dynScriptPrefix "poco" "f" ##f
pocoFE = \dynScriptPrefix "poco" "f" ##t
pocoP  = \dynScriptPrefix "poco" "p" ##f
pocoPE = \dynScriptPrefix "poco" "p" ##t

cresc = #(make-music
  'CrescendoEvent
  'span-direction START
  'span-type 'text
  'span-text (markup (#:normal-text #:small "cresc.")))

crescE = #(make-music
  'CrescendoEvent
  'span-direction START
  'span-type 'text
  'span-text (markup (#:normal-text #:small #:italic "cresc.")))

decresc = #(make-music
  'DecrescendoEvent
  'span-direction START
  'span-type 'text
  'span-text (markup (#:normal-text #:small "decresc.")))

decrescE = #(make-music
  'DecrescendoEvent
  'span-direction START
  'span-type 'text
  'span-text (markup (#:normal-text #:small #:italic "decresc.")))


smallGroupDistance = {
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

normalGroupDistance = {
  \override StaffGrouper.staffgroup-staff-spacing =
    #'((basic-distance . 15)
       (minimum-distance . 15)
       (padding . -100)
       (stretchability . 0))
  \override StaffGrouper.staff-staff-spacing =
    #'((basic-distance . 12)
       (minimum-distance . 12)
       (padding . -100)
       (stretchability . 0))
}

smallStaffDistance = {
  \override VerticalAxisGroup.staff-staff-spacing =
    #'((basic-distance . 12)
       (minimum-distance . 12)
       (padding . -100)
       (stretchability . 0))
}

twofourtime = {
  \overrideTimeSignatureSettings
    2/4
    1/8
    #'(4)
    #'((end . (((1 . 16) . (4 4)))))
}

twotwotime = {
  \overrideTimeSignatureSettings
    2/2
    1/4
    #'(4)
    #'((end . (((1 . 16) . (4 4 4 4)) ((1 . 8) . (4 4)))))
}

mvTr = \once \override TextScript.X-offset = #2
mvTrh = \once \override TextScript.X-offset = #2.5
mvTrr = \once \override TextScript.X-offset = #3
hideTn = \once \override TupletNumber.stencil = ##f
mvDll = \once \override DynamicText.X-offset = #-3
scriptOut = \once \override Script.avoid-slur = #'outside
pao = \once \partCombineApart
pa = \partCombineApart
pd = \partCombineAutomatic
hairpinDashed = \override Hairpin.style = #'dashed-line
hairpinSolid = \override Hairpin.style = #'solid

sbOn = {
  \set subdivideBeams = ##t
  \set baseMoment = #(ly:make-moment 1/8)
  \set beatStructure = #'(2 2 2 2)
}
sbOff = {
  \unset subdivideBeams
  \unset baseMoment
  \unset beatStructure
}

parOn = {
  \once \override ParenthesesItem.font-size = #-3
  \once \override ParenthesesItem.stencils = #(lambda (grob)
    (let ((par-list (parentheses-item::calc-parenthesis-stencils grob))
          (right-par (grob-interpret-markup grob (markup #:null))))
      (list (car par-list) right-par )))
}
parOff = {
  \once \override ParenthesesItem.font-size = #-3
  \once \override ParenthesesItem.stencils = #(lambda (grob)
    (let ((par-list (parentheses-item::calc-parenthesis-stencils grob))
          (left-par (grob-interpret-markup grob (markup #:null))))
      (list left-par (cadr par-list))))
}

markDaCapo = {
  \once \override Score.RehearsalMark.self-alignment-X = #RIGHT
  \mark \markup { \remark "da capo" }
}



% modify the Scheme function 'format-bass-figure'
% in usr/share/lilypond/current/scm/translation-functions.scm
% to increase the size of figured bass accidentals
#(define-public (new-format-bass-figure figure event context)
  (let* ((fig (ly:event-property event 'figure))
         (fig-markup (if (number? figure)
             ((if (<= 10 figure)
                  (lambda (y) (make-translate-scaled-markup
                               (cons -0.7 0) y))
                  identity)

              (cond
               ((eq? #t (ly:event-property event 'diminished))
                (markup #:slashed-digit figure))
               ((eq? #t (ly:event-property event 'augmented-slash))
                (markup #:backslashed-digit figure))
               (else (markup #:number (number->string figure 10)))))
             #f))

         (alt (ly:event-property event 'alteration))
         (alt-markup
          (if (number? alt)
              (markup
               #:general-align Y DOWN #:fontsize
               (if (not (= alt DOUBLE-SHARP))
                  0 2) ;; originally: -2 2
               (alteration->text-accidental-markup alt))
              #f))

         (plus-markup (if (eq? #t (ly:event-property event 'augmented))
                          (markup #:number "+")
                          #f))

         (alt-dir (ly:context-property context 'figuredBassAlterationDirection))
         (plus-dir (ly:context-property context 'figuredBassPlusDirection)))

    (if (and (not fig-markup) alt-markup)
        (begin
          (set! fig-markup
            (markup #:left-align #:pad-x 0.3 alt-markup)) ;; originally pad-around
          (set! alt-markup #f)))

    (if alt-markup
        (set! fig-markup
              (markup #:put-adjacent
                      X (if (number? alt-dir)
                            alt-dir
                            LEFT)
                      fig-markup
                      #:pad-x 0.2 alt-markup)))

    (if plus-markup
        (set! fig-markup
              (if fig-markup
                  (markup #:put-adjacent
                          X (if (number? plus-dir)
                                plus-dir
                                LEFT)
                          fig-markup
                          #:pad-x 0.2 plus-markup)
                  plus-markup)))

    (if (markup? fig-markup)
        (markup #:fontsize -2 fig-markup)
        empty-markup)))


#(define (ly:half-bass-figure-bracket which-side) (lambda (grob)
  (let* (
    (dir-h (if (negative? which-side) -1 +1))
    (layout (ly:grob-layout grob))
    (line-thickness (ly:output-def-lookup layout 'line-thickness))
    (thickness (ly:grob-property grob 'thickness 1))
    (th (* line-thickness thickness))
    (hth (/ th 2))
    (tip-lo-h (car (ly:grob-property grob 'edge-height)))
    (tip-hi-h (cdr (ly:grob-property grob 'edge-height)))
    (bfb (ly:enclosing-bracket::print grob))
    (bfb-x (ly:stencil-extent bfb X))
    (bfb-y (ly:stencil-extent bfb Y))
    (stem-v (interval-widen bfb-y (- hth)))
    (stems-h (interval-widen bfb-x (- hth)))
    (single-bracket (lambda (grob)
      (grob-interpret-markup grob (markup
        #:translate (cons ((if (negative? dir-h) car cdr) stems-h) (cdr stem-v))
        #:scale (cons (- dir-h) -1)
        #:combine #:draw-line (cons tip-hi-h 0) #:combine
        #:draw-line (cons 0 (interval-length stem-v))
        #:translate (cons 0 (interval-length stem-v))
        #:draw-line (cons tip-lo-h 0))))))
    (single-bracket grob))))


bo = \once \override BassFigureBracket.stencil = #(ly:half-bass-figure-bracket LEFT)
bc = \once \override BassFigureBracket.stencil = #(ly:half-bass-figure-bracket RIGHT)


\layout {
  \context {
    \Score
    \compressEmptyMeasures
  }
  \context {
    \StaffGroup
    \override SystemStartBracket.collapse-height = #1
    \override InstrumentName.font-shape = #'italic
    \override StaffGrouper.staffgroup-staff-spacing =
      #'((basic-distance . 15)
         (minimum-distance . 15)
         (padding . -100)
         (stretchability . 0))
    \override StaffGrouper.staff-staff-spacing =
      #'((basic-distance . 12)
         (minimum-distance . 12)
         (padding . -100)
         (stretchability . 0))
  }
  \context {
    \ChoirStaff
    \override StaffGrouper.staffgroup-staff-spacing =
      #'((basic-distance . 15)
         (minimum-distance . 15)
         (padding . -100)
         (stretchability . 0))
    \override StaffGrouper.staff-staff-spacing =
      #'((basic-distance . 13)
         (minimum-distance . 13)
         (padding . -100)
         (stretchability . 0))
    \override StaffGrouper.nonstaff-nonstaff-spacing =
      #'((basic-distance . 2)
         (minimum-distance . 2)
         (padding . -100)
         (stretchability . 0))
  }
  \context {
    \GrandStaff
    \override InstrumentName.font-shape = #'italic
    \override StaffGrouper.staffgroup-staff-spacing =
      #'((basic-distance . 15)
         (minimum-distance . 15)
         (padding . -100)
         (stretchability . 0))
    \override StaffGrouper.staff-staff-spacing =
      #'((basic-distance . 12)
         (minimum-distance . 12)
         (padding . -100)
         (stretchability . 0))
  }
  \context {
    \PianoStaff
    \override InstrumentName.font-shape = #'italic
    \override StaffGrouper.staffgroup-staff-spacing =
      #'((basic-distance . 15)
         (minimum-distance . 15)
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
    \override InstrumentName.font-shape = #'italic
    \override VerticalAxisGroup.default-staff-staff-spacing =
      #'((basic-distance . 15)
         (minimum-distance . 15)
         (padding . -100)
         (stretchability . 0))
    \accidentalStyle neo-modern-voice
    extraNatural = ##t
    \override NoteHead.style = #'baroque
    aDueText = \markup { \medium \remark "a 2" }
    \override DynamicTextSpanner.style = #'none
  }
  \context {
    \Voice
    \override TupletBracket.bracket-visibility = ##f
    \override TupletBracket.avoid-scripts = ##f
  }
  \context {
    \Lyrics
    \override LyricText.font-size = #-1
    \override VerticalAxisGroup.nonstaff-unrelatedstaff-spacing.padding = #-100
  }
  \context {
    \FiguredBass
    figuredBassPlusDirection = #1
    \override BassFigure.font-size = #-2
    \override BassFigure.baseline-skip = #-3
    \override VerticalAxisGroup.nonstaff-nonstaff-spacing.padding = #-100
  }
  \set figuredBassFormatter = #new-format-bass-figure
}


#(define (ly:create-toc-file layout pages)
  (let* ((label-table (ly:output-def-lookup layout 'label-page-table)))
    (if (not (null? label-table))
      (let* ((format-line
              (lambda (toc-item)
                (let* ((label (car toc-item))
                       (text (cdaddr toc-item))
                       (label-page (and (list? label-table)
                                        (assoc label label-table)))
                       (page (and label-page (cdr label-page))))
                 (format #f "~a{~a}" text page))))
             (formatted-toc-items (map format-line (toc-items)))
             (whole-string (string-join formatted-toc-items "\n"))
             (outfilename "lilypond.toc")
             (outfile (open-output-file outfilename)))
       (if (output-port? outfile)
           (display whole-string outfile)
           (ly:warning
             (_ "Unable to open output file ~a for the TOC information")
             outfilename))
       (close-output-port outfile)))))

#(define ees-toclevel "")
#(define ees-tocnumber "")
#(define ees-tocgenre "")
#(define ees-toctitle "")

insertEmptyPage = #(define-void-function
  ()
  ()
  (ly:book-add-bookpart!
    (ly:parser-lookup '$current-book)
    #{
      \bookpart {
        \paper { evenHeaderMarkup = {} oddHeaderMarkup = {} }
        \new Staff \with {
          \remove "Clef_engraver"
          \remove "Time_signature_engraver"
        } { \stopStaff s }
      }
    #}))

part = #(define-void-function
  (number title)
  (string? string?)
  (ly:book-add-bookpart!
    (ly:parser-lookup '$current-book)
    #{
      \bookpart {
        \paper { evenHeaderMarkup = {} oddHeaderMarkup = {} }
        \markup {
          \column {
            \vspace #25
            \fill-line { \fontsize #12 \with-color #(rgb-color .8313 0 0) #number }
            \vspace #3
            \fill-line { \fontsize #5 #title }
          }
        }
        #(set! ees-toclevel "part")
        #(set! ees-tocnumber number)
        #(set! ees-tocgenre "")
        #(set! ees-toctitle title)
        \addTocEntry
        \new Staff \with {
          \remove "Clef_engraver"
          \remove "Time_signature_engraver"
        } { \stopStaff s }
        \pageBreak
        \markup \null
      }
    #}))


section =
  #(cond ((string= option-movement-title-format "title")
          (define-scheme-function
            (parser location title)
            (string?)
            #{ \header { title = #title } #}))
         ((string= option-movement-title-format "number-title")
          (define-scheme-function
            (parser location number title)
            (string? string?)
            (begin
              (set! ees-toclevel "section")
              (set! ees-tocnumber number)
              (set! ees-tocgenre "")
              (set! ees-toctitle title)
              #{ \header { number = #number title = #title } #})))
         ((string= option-movement-title-format "genre-number-title")
          (define-scheme-function
            (parser location number genre title)
            (string? string? string?)
            (begin
              (set! ees-toclevel "section")
              (set! ees-tocnumber number)
              (set! ees-tocgenre genre)
              (set! ees-toctitle title)
              #{ \header { number = #number genre = #genre title = #title } #}))))

subsection = #(define-scheme-function
  (parser location title)
  (string?)
  (begin
    (set! ees-toclevel "subsection")
    (set! ees-tocnumber "")
    (set! ees-tocgenre "")
    (set! ees-toctitle title)
    #{ \header { subtitle = #title } #}))

addTocLabel = #(define-music-function
  (parser location label)
  (string?)
  (add-toc-item!
    'tocItemMarkup
    (format
      #f
      "\\newtocentry{~a}{~a}{~a}{~a}{~a}"
      label
      ees-toclevel
      ees-tocnumber
      ees-tocgenre
      ees-toctitle)))

addTocEntry = #(define-music-function
  (parser location)
  ()
  (addTocLabel ""))
