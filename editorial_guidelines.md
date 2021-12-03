# Editorial guidelines

This document describes v2021.12.0 of the editorial guidelines for the Edition Esser-Skala. These guidelines mainly follow the guidelines of the [CPEB:CW project](https://cpebach.org/description.html).



## Contents

- [Prefatory material](#prefatory-material)
  - [Title page](#title-page)
  - [Critical report](#critical-report)
    - [Abbreviations](#abbreviations)
    - [Sources](#sources)
    - [Commentary](#commentary)
  - [Changelog](#changelog)
  - [Table of contents](#table-of-contents)
- [Conventions of notation](#conventions-of-notation)
  - [Score design](#score-design)
  - [Clefs](#clefs)
  - [Key signatures](#key-signatures)
  - [Tempo indications and movement designations](#tempo-indications-and-movement-designations)
  - [Bar numbering](#bar-numbering)
  - [Accidentals](#accidentals)
  - [Slurs and ties](#slurs-and-ties)
  - [Bass figures](#bass-figures)
  - [Embellishments](#embellishments)
  - [Articulation](#articulation)
  - [Dynamics and directives](#dynamics-and-directives)
  - [Notational shorthand](#notational-shorthand)
  - [Vocal texts](#vocal-texts)



## Prefatory material

Prefatory material comprises the [title and copyright page](#title-page). In addition, the full score also contains a [critical report](#critical-report), [changelog](#changelog), and [table of contents](#table-of-contents).


### Title page

The *title page* (p. i) includes the following information:
- a header with the composer's last name and the (possibly abbreviated) work title
- the composer's full name (last name printed red)
- the title of the work (bold)
- a subtitle (if applicable)
- the catalog of works number; if unavailable, the RISM library siglum and shelfmark of the principal source
- the scoring
- the score type (e.g., “Full Score”, “Violino I”; use modern Italian names).
- the full logo of the Edition Esser-Skala

The *scoring* lists all vocal parts and instruments:
- Individual instruments are separated by commas (e.g., “S, vla, org”).
- An Arabic numeral indicates the number of each instrument (e.g., “2 vl”).
- The pitch of transposing instruments is given in parentheses (e.g., “timp (C–G)”).
- Solo and chorus vocal parts are distinguished (e.g., “S, A (solo), S, A, T, B (coro)”).
- Instruments that are not available in all sources or have been added by the editor are surrounded by brackets (e.g., “[2 fl]”).

The *copyright page* (p. ii) includes:
- the copyright statement (typically, the CC BY-SA 4.0 or CC BY-NC-SA 4.0 license)
- an indication of used software and fonts
- contact details (email address)
- a link to the GitHub repository
- the current version, date, and SHA1 of the git repository

If possible, editions are released under a Creative Commons Attribution-ShareAlike 4.0 International license (CC BY-SA 4.0) to foster the free and open source notion of the Edition Esser-Skala. However, a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license (CC BY-NC-SA 4.0) may be chosen to warrant [compatibility](https://creativecommons.org/share-your-work/licensing-considerations/compatible-licenses/) with a non-commercial license of the principal source.


### Critical report

The critical report (p. iii et sqq.) consists of three secions [Abbreviations](#abbreviations), [Sources](#sources), and [Commentary](#commentary).


#### Abbreviations

This section contains a table of used abbreviations. Instruments are abbreviated according to [RISM](https://opac.rism.info/scoring-abbreviations).


#### Sources

This section describes the used sources of a given work. Each source is labeled with a bold capital letter (indicating the source category) followed by an index number:
- **A**: autograph manuscripts
- **B**: other manuscripts used for the edition
- **C**: prints used for the edition
- **D**: manuscripts not used for the edition
- **E**: prints not used for the edition

Within each category, sources are labeled in order of importance. Notably, categories D and E are applied if the sources are only available under incompatible licenses (e.g., CC BY-SA 4.0 and CC BY-NC-SA 4.0).

For each source, the following information is included:
- RISM library siglum and shelfmark
- source category
- indication whether this source represents the principal source
- date
- RISM identifier
- link to digital version
- license
- notes (optional)


#### Commentary

Each edition is based upon a single principal source, which is explicitly identified in section [Sources](#sources). Any substantial difference between the edition and the principal source is

1. indicated with an asterisk in the score and
2. reported in this section as an editorial *emendation*.

However, the following elements are *tacitly* modernized or standardized (see section [Conventions of notation](#conventions-of-notation) for details): Tempo indications, instrument names, clefs, accidentals, beaming and stem directions, rests, placement of dynamics/slurs/ties, treatment of shorthand notations, bar numbering, bar lines, and repeats.

The table of emendations comprises the following columns:
- movement (only if there are several movements in the work)
- bar number
- staff
- description

The following conventions apply to the commentary:
- Keys are given with a capital letter for major or minor keys (e.g., “C minor”). Sharp and flat are spelled out with a hyphen (e.g., “B-flat major”).
- Notes are counted by ordinal numbers and written as symbol (e.g., “1st ♩”).
- Helmholtz pitch notation is applied, with symbols for sharp, flat, and natural signs, and order name–accidental–octave (e.g., “c#′”).
- Rests are written as symbol.
- A sequence of pitches is separated by en dashes (e.g., “c′4–d′8–e′8”)
- Chords are spelled with a plus sign between pitches from lowest to highest pitch (e.g., “c′+e′+g′”).
- Modern English instrument names are used.
- Foreign words are typeset italic.



### Changelog

The changelog contains a curated, chronologically ordered list of notable changes for each version of the edition. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and the edition adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).  



### Table of contents

The table of contents list all individual movements with their number, title, and page number. For each movement, its genre as well as lyrics may be included. If a work has a single movement, the table of contents will be omitted.



## Conventions of notation

### Score design

The *score order* from top to bottom is:
- woodwind instruments
  - flutes
  - cornetts
  - oboes
  - chalumeaux
  - clarinets
  - bassoons
- brass instruments
  - horns
  - trumpets
  - trombones
- timpani
- strings
  - violins
  - violas
  - violoncellos
  - violones
- voice parts
  - soprano
  - alto
  - tenor
  - bass
- continuo

Families of instruments are barred and bracketed together. Voice parts are bracketed but barred separately. The continuo is bracketed. Pairs of instruments are either set in braces (e.g., violin I and II) or share one staff
with automatic part combining. In the latter case,
- polyphony may be indicated by opposing stems;
- the first and second parts get marked with their instrument abbreviations in solo situations; and
- the unison (a due) parts are marked with the text “a 2”.

Each part is spelled out in full on the first system of the first movement (singular form of modern Italian names), and abbreviated on the first system of each subsequent movement. Divided parts are indicated by Roman numerals in the first movement and by Arabic numbers in each subsequent movement. Transposing instruments include their pitch (e.g., “Clarino I, II in C” in the first movement and “clno (C) 1, 2” in subsequent movements). The part with figured bass is typically labeled “Organo e Bassi” or “Fondamento”.

In recitatives, instrumental parts also contain the solo vocal part. This convention typically applies to continuo parts in seccos and continuo plus string parts in accompagnatos.


### Clefs

Keyboard music in soprano clef is notated in treble clef. Vocal music in soprano or alto clef is changed to
treble clef; the tenor clef is changed to treble ottavo. Other clefs (e.g., alto for viola parts) are generally not altered. In the first movement, the original clef is given as incipit.


### Key signatures

The original key signature is retained, while the order and position of sharps and flats is modernized.


### Tempo indications and movement designations

Tempo indications appear in the original language; inconsistent spelling is regularized. Only the first word of Italian terms is capitalized (e.g., “Poco andante”). Movement designations may be retained in the original language (“Chor”) or translated to Italian (“Coro”),

Individual movements are numbered by the editor if numbers are absent in the source.


### Bar numbering

Each new system except the first includes a bar number (bar 1 is the first full measure). Changes of tempo and meter within a movement are through-numbered. Bar numbering begins at 1 in each new movement, even where the movements are continuous (as indicated by thin-thin bar lines).


### Accidentals

An accidental remains in force throughout a measure unless canceled by another accidental. Cautionary accidentals are tacitly added, redundant accidentals are tacitly deleted.


### Slurs and ties

Slurs are carefully regularized. In vocal music, melismatic slurring in vocal music is shown even when beaming reflects syllabification. However, such slurs are usually not longer than one measure. Source slurring that shows phrasing is retained.

If two notes of the same pitch are tied, the note value is changed as appropriate.

Editorial slurs and ties are dashed.


### Bass figures

Figures are set below the continuo line. Accidentals are placed before the figures to which they apply. Editorial figures are parenthesized.


### Embellishments

Ornaments are generally reproduced exactly as they appear in the principal source. Slurs are added from appoggiaturas to the main note, except if they appear under a longer slur. The rhythmic value of grace notes is tacitly emended to half the length of the main note. Editorial expressive marks are parenthesized.


### Articulation

Generally, both dots and strokes in the source are rendered as strokes in the edition. Dots are only retained if they are required in a particular context such as portato (i.e., notes that are both slurred and dotted). Editorial articulation signs are parenthesized.


### Dynamics and directives

Dynamics and other directives are usually standardized to modern Italian and placed below the staff, but above the staff in vocal music. Source dynamics are typeset upright, editorial additions or changes are typeset in italics.


### Notational shorthand

Generally, notational shorthand is realized in full. Slashed stems may be used to indicate repeated notes if this improves readability.


### Vocal texts

Latin texts are standardized and modernized. Archaic German spelling is retained (notably, lyrics distinguish between long ſ and round s). Editorial changes are indicated by italic type. When text is repeated in vocal music, a period is only used if a complete sentence is repeated; otherwise, a comma is used. Syllabification of German text is standardized according to the Duden. Groups of notes sung to a single syllable are beamed together, notes sung to separate syllables are stemmed separately.
