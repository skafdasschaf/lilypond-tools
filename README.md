# EES Tools

*EES Tools* is a collection of scripts that are required for engraving scores for the Edition Esser-Skala. In addition, this repository includes instructions to build the *EES Engraver*, a Docker container with these tools and all dependencies.



## Contents

- [Installation](#installation)
- [How to build the EES Engraver](#how-to-build-the-ees-engraver)
- [add_variables.py](#add_variablespy)
- [ees.ly](#eesly)
  - [Options](#options)
  - [Document structure](#document-structure)
  - [Table of contents](#table-of-contents)
  - [Markup](#markup)
  - [Inside the staff](#inside-the-staff)
  - [Polyphony](#polyphony)
  - [Bass figures](#bass-figures)
- [ees.mk](#eesmk)
- [make_works_table.py](#make_works_tablepy)
- [read_metadata.py](#read_metadatapy)
  - [metadata.yaml](#metadatayaml)
- [tex/latex/ees.cls](#texlatexeescls)
  - [Class options](#class-options)
  - [Formatting](#formatting)
  - [Metadata](#metadata)
  - [Document structure](#document-structure-1)
  - [Manual TOC formatting](#manual-toc-formatting)



## Installation

Install the following dependencies:
- [Python](https://python.org/) v3.9 with packages [numpy](https://numpy.org/), [pandas](https://pandas.pydata.org/), [GitPython](https://github.com/gitpython-developers/GitPython), and [PyYAML](https://pyyaml.org/)
- [Source Sans](https://github.com/adobe-fonts/source-sans) v3.046 and [Fredericka the Great](https://github.com/google/fonts) v1.001
- [TinyTex](https://yihui.org/tinytex/) v2021.11 with LaTeX packages in [docker/tinytex_packages.txt](docker/tinytex_packages.txt)
- [LilyPond](https://lilypond.org/) v2.22.1

Clone the repository and make sure that the files can be found by the respective programs:
- Define the shell variable `EES_TOOLS_PATH` to point to this directory.
- Run `tlmgr conf auxtrees add $EES_TOOLS_PATH`.
- Always run LilyPond with the flag `--include=$EES_TOOLS_PATH`.



## How to build the EES Engraver

This Docker image is based on [python:3.9](https://hub.docker.com/_/python), with all dependencies installed by [docker/setup.sh](docker/setup.sh). GitHub Actions uses this image to automatically engrave and release scores of the Edition Esser-Skala whenever a tag is pushed.

Build the image via

```bash
sudo docker build --tag ees-engraver .
```

From the root directory of an edition, run

```bash
sudo docker run --rm -it -v $PWD:/ees ees-engraver
```

to engrave all final scores (i.e., `make final/scores`). To call `make` with a different `<target>`, run

```bash
sudo docker run --rm -it -v $PWD:/ees ees-engraver make <target>
```

## add_variables.py

This script extends LY files in subfolder `notes/` with variables for a new movement:

- `-h`, `--help`:
  show this help message and exit
- `-m`, `--movement MOVEMENT`:
  add this movement
- `-n`, `--notes [NOTES ...]`:
  add the movement to these instruments (default: all instruments in notes subfolder)
- `-k`, `--key KEY`:
  key signature (default: C major). Examples:
  - `C` is C major
  - `d` is D minor
  - `d_dorian` is D dorian
- `-t`, `--time TIME`:
  time signature (default: 4/4)
- `-p`, `--partial PARTIAL`:
  duration of upbeat (default: no upbeat)
- `-b`, `--current-bar CURRENT_BAR`:
  start movement with this bar number (default: 1)
- `-f`, `--force-file-creation`:
  create missing files, add version and incipits if required (default: false)
- `-v`, `--version`:
  show program's version number and exit


## ees.ly

General LilyPond settings and macros. This file is included by `definitions.ly` in the repository of each work.

### Options

Set these Scheme variables before including the file, like

```lilypond
#(define ees-booktitle-markup "title")
\include "ees.ly"
```

- `ees-booktitle-markup`: Choose the components of each movement title (genre, number, title). Allowed values: `"genre-number-title"`, `"number-title"`, and `"title"`.


### Document structure

- `\partTitle "<number>" "<title>"`
- `\partMark`

These commands allow to add a page with a part title, plus an empty page:

```lilypond
\bookpart {
  \paper { evenHeaderMarkup = {} oddHeaderMarkup = {} }
  \partTitle "1" "F I R S T   P A R T"
  \tocPart "1" "First Part"
  \partMark
  \pageBreak
  \markup \null
}
```

- `\smallGroupDistance`
- `\normalGroupDistance`
- `\smallStaffDistance`

These commands modify the vertical spacing of staff groups and single staves:

```lilypond
\new Staff \with { \smallStaffDistance } {
  \set Staff.instrumentName = "clno"
  \Clarino
}
```

- `\twofourtime`
- `\twotwotime`

These commands adjust automatic beaming in 2/4 and 2/2 time, respectively.

```lilypond
KyrieViolinoI = {
  \relative c' {
    \clef treble
    \twotwotime \key c \major \time 2/2 \tempoKyrie
    ...
  }
}
```


### Table of contents

- `ly:create-toc-file`
- `\tocPart "<number>" "<text>"`
- `\tocSection "<number>" "<text>"`
- `\tocSubsection "<number>" "<text>"`

These commands create a table of contents that can be interpreted by LaTeX. The TOC is stored in `lilypond.toc`.

```lilypond
\paper {
  #(define (page-post-process layout pages) (ly:create-toc-file layout pages))
}

\book {
  \bookpart {
    \header {
      number = "1"
      title = "K Y R I E"
    }
    \tocSection "1" "Kyrie"
    ...
  }
  \bookpart {
    \header {
      subtitle = "C H R I S T E"
    }
    \tocSubsection "1.2" "Christe"
    ...
  }
}
```

- `ly:create-ref-file`
- `\tocLabel "<label>" "<number>" "<text>"`
- `\tocLabelLong "<label>" "<number>" "<genre>" "<text>"`

These commands create a table of contents by defining LaTeX labels. The TOC is stored in `lilypond.ref`.

```lilypond
\paper {
  #(define (page-post-process layout pages) (ly:create-ref-file layout pages))
}

\book {
  \bookpart {
    \header {
      genre = "C O R O"
      number = "1.1"
      title = "Lobt den Herrn!"
    }
    \tocLabelLong "lobtden" "1.1" "Coro" "Lobt den Herrn!"
    ...
  }
}
```


### Markup

- `\remark{<text>}` and `\remarkE{<text>}`: Format source directives (upright) and editorial directives (italic), respectively. In addition, several directives are predefined with source and editorial variants (e.g., `\solo` and `\soloE`):

  Command|Printed text  
  --|--
  `\arco`|arco
  `\bassi`|Bassi
  `\colOrg`|col’Org.
  `\dolce`|dolce
  `\org`|Org.
  `\pizz`|pizz.
  `\senzaOrg`|senza Org.
  `\solo`|Solo
  `\tasto`|tasto solo
  `\tenuto`|ten.
  `\tutti`|Tutti
  `\unisono`|unisono
  `\vlc`|Vlc.

- `\critnote`: print asterisk denoting an editorial emendation
- `\mvTr`: move text 2 staff spaces to the right
- `\mvTrh`: move text 2.5 staff spaces to the right
- `\mvTrr`: move text 3 staff spaces to the right
- `\tempoMarkup "<tempo>"`: format the tempo indication


### Inside the staff

- The following dynamics commands are redefined and supplemented by an editorial variant: `\ff` (plus `\ffE` etc), `\f`, `\mf`, `\mp`, `\p`, `\pp`, `\sf`, `\sfp`, `\sfz`, `\fp`, `\fz`, `\rf`, `\rfz`, `\piuF`, `\piuP`, `\pocoF`, `\pocoP`, `\cresc`, and `\decresc`.
- `\bp`: override beam positions
- `\extraNat`: force accidental
- `\hairpinDashed` and `\hairpinSolid`: turn on/off dashed hairpins
- `\hideTn`: hide a single tuplet number
- `\kneeBeam` and `\noKneeBeam`: force/suppress kneed beams
- `\markDaCapo`: print “da capo” right aligned above a bar line
- `\mvDll`: move dynamic mark 3 staff spaces to the left
- `\parOn` and `\parOff`: only print the left/right parenthesis in `\parenthesize`
- `\sbOn` and `\sbOff`: turn on/off subdivided beams
- `\scriptOut`: force script (like `-|`) to be printed outside of slur
- `\trillE`: editorial (parenthesized) trill
- `\xE` and `\x`: turn on/off editorial (italic) lyrics


### Polyphony

- `\pa`: short for `\partCombineApart`
- `\pao`: short for `\once \partCombineApart`
- `\pd`: short for `\partCombineAutomatic`
- `\rh` and `\lh`: change staff in keyboard music


### Bass figures

- `\bo` and `\bc`: only print the left/right bass figure bracket
- `\l`: empty space instead of figure
- `\t`: horizontal dash instead of figure
- `\tllur`: dash from lower left to upper right instead of figure



## ees.mk

Makefile that defines rules for engraving scores. This file is included by the `Makefile` in the repository of each work. Available targets:
- `full_score`, `b`, `vl1` etc: individual scores (LilyPond output only)
- `scores`: all scores
- `final/full_score`, `final/b`, `final/vl1` etc: individual final scores (LilyPond output + front matter)
- `final/scores`: all final scores
- `info`: usage details


## make_works_table.py

This script collects metadata from the `metadata.yaml` file in each repository and saves this data to a table (`works.csv`). `instrument_data.csv` contains metadata for this script.


## read_metadata.py

This script converts information in `metadata.yaml` to a set of LaTeX macros and stores them in `front_matter/critical_report.macros`, which is subsequently imported by `front_matter/critical_report.tex`. Each of these LaTeX macros starts with `\Metadata...`. The mapping between YAML keys and macros is described below.

`read_metadata.py` has a single optional argument `-t`, which sets the score type:
- `draft` (default):
  - set `\MetadataScoretype` to `Draft`
  - include critical report, changelog and TOC
  - do *not* print any scores
- `full_score`:
  - set `\MetadataScoretype` to `Full Score`
  - include critical report, changelog and TOC
  - print the full score
- any other value:
  - set `\MetadataScoretype` to the value of the respective subkey of `parts` in `metadata.yaml`
  - do *not* print critical report, changelog and TOC
  - print the respective score

The script also obtains the following information from the git metadata:
- name of the remote repository `origin` (-> `\MetadataRepository`)
- version of the most recent tag (-> `\MetadataVersion`)
- date of the most recent tag (-> `\MetadataDate`)

Furthermore, the script reads the LilyPond version from the output of `lilypond --version` (-> `\MetadataLilypondVersion`).


### metadata.yaml

This file describes metadata for each work and comprises the following keys:
- `composer` (required): The composer's name. The value should either be a single string with format `last name, first name`, or contain the following subkeys:
  - `first` (required): first name (-> `\MetadataFirstname`)
  - `last` (required): last name (-> `\MetadataLastname`)
  - `suffix` (optional): name suffix (-> `\MetadataNamesuffix`)
- `title` (required): Work title (-> `\MetadataTitle`).
- `subtitle` (optional): Work subtitle. The subtitle is combined with the catalogue of works number of the primary source and stored in `\MetadataSubtitle`. If this key is missing, the work identifier is used alone. If the primary source has no catalogue of works number, its RISM library siglum and shelfmark are used.
- `genre` (required): Work genre (only used on the webpage).
- `scoring` (required): Scoring of the work (-> `\MetadataScoring`). The value should be either a single string or an array. In the latter case, array elements will be joined by newlines. See the editorial guidelines for the scoring syntax. The list of abbreviations in the critical report is also assembled from the scoring information (-> `\MetadataAbbreviations`)
- `sources` (required): Manuscript and print sources used for the edition (-> `\MetadataSources`). The name of each subkey will be used as source identifier (e.g., A1, B2). Each source is described by the following keys:
  - `siglum` (required): RISM library siglum
  - `shelfmark` (required): shelfmark
  - `date` (optional): date
  - `rism` (optional): RISM identifier
  - `url` (optional): link to digital version
  - `notes` (optional): miscellaneous notes
  - `primary` (optional): Boolean that denotes whether this source is the primary source. Exactly one source *must* contain this key with a true value.
- `imslp` (optional): IMSLP identifier (only used on the webpage).
- `notes` (optional): Miscellaneous notes (only used on the webpage).
- `parts` (required): For each file in the `scores/` subdirectory, this key must contain a subkey-value pair. The subkey corresponds to the file name (without extension), and the value will be used as score type on the title page (-> `\MetadataScoretype`).





## tex/latex/ees.cls

LaTeX class for printing scores with prefatory material.

### Class options

Type and default value in parentheses.
- `parts` (Boolean, false): indicates whether the TOC contains parts
- `tocgenre` (Boolean, false): indicates whether the TOC contains a genre for each movement
- `toe` (Boolean, true): indicates whether the commentary contains a table of emendations
- `movcol` (Boolean, true): indicates whether the table of emendations contains a "Mov[ement]" column
- `shortnamesize` (number, 80): font size for the composer name in the title page head
- `shorttitlesize` (number, 60): font size for the work title in the title page head
- `abbrwidth` (length, 3em): width of the first column in the list of abbreviations and the list of sources


### Formatting

- `\textlt{<text>}` and `\ltseries`: Select light text weight.
- `\textsb{<text>}` and `\sbseries`: Select semibold text weight.
- `\A{<number>}` to `\E{<number>}`: Typeset a source identifier (uppercase letter plus index `<number>`).


### Metadata

By default, these macros use the respective values in `metadata.yaml`.
- `\firstname{}`: first name of the composer (default: `\MetadataFirstname`)
- `\lastname{}`: last name of the composer (default: `\MetadataLastname`)
- `\namesuffix{}`: name suffix of the composer (default: `\MetadataNamesuffix`)
- `\shortname{}`: composer name for the title page head (default: `\MetadataLastname`)
- `\title{}`: work title (default: `\MetadataTitle`)
- `\shorttitle{}`: work title for the title page head (default: `\MetadataTitle`)
- `\subtitle{}`: work subtitle (default: `\MetadataSubtitle`)
- `\scoring{}`: scoring information (default: `\MetadataScoring`)
- `\scoretype{}`: score type printed on the title page (default: `\MetadataScoretype`)
- `\repository{}`: name with owner of the GitHub repository (default: `\MetadataRepository`)
- `\version{}`: version of the most recent git tag (default: `\MetadataVersion`)
- `\date{}`: date of the most recent git tag (default: `\MetadataDate`)


### Document structure

- `\eesTitlePage`: Print the default title and copyright page.
- `\eesCriticalReport{<table rows>}`: Print the critical report (abbreviations, sources, and commentary) and the changelog. The single argument may contain rows for the table of emendations (four columns if `movcol` is true, otherwise three columns). If `toe` is false, the argument is ignored.
- `\eesCommentaryIntro`: Print the default introduction of the commentary section (automatically invoked by `\eesCriticalReport`).
- `\eesToc{<contents>}`: Print the table of contents. The value of the argument is printed under the headline *Contents* and allows to format the TOC manually (see below).
- `\eesScore`: Print the included score.
- `\ifPrintFrontMatter` … `\fi`: Additional content in the prefatory material should be surrounded by this conditional, which ensures that it is only printed in the full score and draft.


### Manual TOC formatting

- `\part{<label>}`: Print a TOC entry for the part with `<label>` as defined in the LY file via `\tocPart`.
- `\section{<label>}`: Print a TOC entry for the section with `<label>` as defined in the LY file via `\tocSection`.
- `\begin{movement}{<label>} <lyrics> \end{movement}`: Print the TOC entry for the movement (section) with `<label>`. The `<lyrics>` may comprise
  - continuous text, which represents all lyrics of the respective movement (as seen, for instance, in Michael Haydn's [Litaniae MH 532](https://github.com/edition-esser-skala/haydn-m-litaniae-mh-532)); or
  - text blocks labeled with the associated voice (as seen, for instance, in Stölzel's [Jeſu, Deine Paßion](https://github.com/edition-esser-skala/stoelzel-jesu-deine-passion)). `\voice[<label>]` sets the `<label>` of each text block.
