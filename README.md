# EES Tools

*EES Tools* is a collection of scripts that are required for engraving scores for the Edition Esser-Skala. In addition, this repository includes instructions to build a Docker container *ees-tools* with these tools and all dependencies.



## Contents

- [TL;DR: Engraving scores](#tldr-engraving-scores)
  - [… using the Docker image](#-using-the-docker-image)
  - [… using a manual installation](#-using-a-manual-installation)
- [Structure of a score repository](#structure-of-a-score-repository)
- [add_variables.py](#add_variablespy)
- [ees.ly](#eesly)
  - [Options](#options)
  - [Score settings](#score-settings)
  - [System configuration](#system-configuration)
  - [Sectioning and TOC](#sectioning-and-toc)
  - [Markup](#markup)
  - [Inside the staff](#inside-the-staff)
  - [Polyphony](#polyphony)
  - [Bass figures](#bass-figures)
- [ees.mk](#eesmk)
  - [parse_logs.py](#parse_logspy)
- [instrument_data.csv](#instrument_datacsv)
- [read_metadata.py](#read_metadatapy)
  - [Subcommand `edition`](#subcommand-edition)
  - [Subcommand `table`](#subcommand-table)
  - [metadata.yaml](#metadatayaml)
- [tex/latex/ees.cls](#texlatexeescls)
  - [Class options](#class-options)
  - [Formatting](#formatting)
  - [Metadata](#metadata)
  - [Document structure](#document-structure)
  - [Manual TOC](#manual-toc)
- [.github/workflows/engrave-and-release.yaml](#githubworkflowsengrave-and-releaseyaml)
- [Appendix](#appendix)
  - [Useful LilyPond snippets](#useful-lilypond-snippets)
  - [Spacing recommendations](#spacing-recommendations)



## TL;DR: Engraving scores

### … using the Docker image

We recommend to engrave scores via the [ees-tools](https://ghcr.io/edition-esser-skala/ees-tools) Docker image. This image is based on [python:3.9](https://hub.docker.com/_/python), with all dependencies installed by [docker/setup.sh](docker/setup.sh). GitHub Actions uses this image to automatically engrave and release scores of the Edition Esser-Skala whenever a tag is pushed.

Build the image via

```bash
sudo docker build --build-arg user_id=$(id -u) --build-arg group_id=$(id -g) --tag ees-tools .
```

From the root directory of an edition, run

```bash
sudo docker run --rm -it -u engraver -v $PWD:/ees ees-tools
```

to engrave all final scores (i.e., `make final/scores`). To list all available build targets, run

```bash
sudo docker run --rm -it -u engraver -v $PWD:/ees ees-tools make info
```

(Note: These commands ensure that there is a user *engraver* in the container whose uid and gid match the user who runs the container. Thereby, all files created by the container will have the correct permissions.)


### … using a manual installation

Install the following dependencies:
- [Python](https://python.org/) v3.9 with packages [numpy](https://numpy.org/), [pandas](https://pandas.pydata.org/), [GitPython](https://github.com/gitpython-developers/GitPython), and [PyYAML](https://pyyaml.org/)
- [Source Sans](https://github.com/adobe-fonts/source-sans) v3.046 and [Fredericka the Great](https://github.com/google/fonts) v1.001
- [TinyTex](https://yihui.org/tinytex/) v2021.11 with LaTeX packages in [docker/tinytex_packages.txt](docker/tinytex_packages.txt)
- [LilyPond](https://lilypond.org/) v2.22.1

Clone the repository and make sure that the files can be found by the respective programs:
- Define the shell variable `EES_TOOLS_PATH` to point to this directory.
- Run `tlmgr conf auxtrees add $EES_TOOLS_PATH`.
- Always run LilyPond with the flag `--include=$EES_TOOLS_PATH`.

From the root directory of an edition, invoke `make` to engrave scores:
- `make final/scores` generates all publication-ready scores in folder *final*.
- `make info` lists all available build targets.



## Structure of a score repository

In order to create a new edition, clone the [ees-template](https://github.com/edition-esser-skala/ees-tools) repository:

```bash
gh repo create edition-esser-skala/<repository> \
  --public \
  -p edition-esser-skala/ees-template \
  -d "<composer>: <title>"
```

The new repository will contain the following folders and files:
- **notes/*.ly** – LilyPond files containing individual voices; add new variables with [add_variables.py](#add_variablespy)
- **scores/*.ly** – LilyPond files containing score definitions
- **CHANGELOG.md** – the [changelog](https://keepachangelog.com/en/1.0.0/)
- **definitions.ly** – general definitions; include [ees.ly](#eesly)
- **LICENSE** – the [license](https://creativecommons.org/licenses/by-sa/4.0/)
- **Makefile** – configuration file for `make`; imports [ees.mk](#eesmk)
- **metadata.yaml** – metadata whose format is described [below](#metadatayaml); can be processed with [read_metadata.py](#read_metadatapy)
- **.github/workflows/engrave-and-release.yaml** – GitHub Actions workflow that reuses the [workflow of the same name](#githubworkflowsengrave-and-releaseyaml) from EES Tools
- **front_matter/critical_report.tex** – prefatory material based upon [ees.cls](#texlatexeescls)



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
  create missing files (default: false)


## ees.ly

General LilyPond settings and macros. This file is included by `definitions.ly` in the repository of each work.


### Options

Set these Scheme variables before including the file, like

```lilypond
#(define option-movement-title-markup "number-title")
#(define option-init-toc #t)
#(define option-print-all-bar-numbers #f)
\include "ees.ly"
```

- `option-movement-title-markup`: Select the format of the movement title and the number of arguments for `\section`. Choices: `"genre-number-title"`, `"number-title"`, and `"title"` (default).
- `option-init-toc`: If true, generate a table of contents in `lilypond.toc`, which can be interpreted by LaTeX (default: true).
- `option-print-all-bar-numbers`: If true, print all bar numbers (useful when preparing a score; default: false).


### Score settings

Include one of the following files in subfolder `score_settings` at the beginning of a score definition:
- `one-staff.ly`: Format parts with a single staff (e.g., vl 1). `option-instrument-name` sets the instrument name of this staff.
- `two-staves.ly`: Format parts with two bracketed staves (e.g., cor 1, 2). `option-instrument-name` sets the instrument name of the bracket.
- `three-staves.ly`: Format parts with three staves, of which the upper two are bracketed (e.g., ottoni). `option-instrument-name-upper` and `option-instrument-name-lower` set the instrument name of the bracket and lower staff, respectively.
- `four-staves.ly`: Format parts with four staves, of which the upper three are bracketed (e.g., ottoni with three trumpets). `option-instrument-name-upper` and `option-instrument-name-lower` set the instrument name of the bracket and lower staff, respectively.
- `full-score.ly`: Format the full score.
- `coro.ly`: Format the vocal score.
- `org-realized.ly`: Format the realized organ part.


### System configuration

- `\setGroupDistance <staff-staff> <after-group>`
- `\setStaffDistance <after-staff>`

These commands modify the vertical spacing of staff groups and single staves. `<staff-staff>` will be the spacing between staves in the group, while `<after-group>` and `<after-staff>` will be the distance after the group and staff, respectively.

```lilypond
\new Staff \with { \setStaffDistance #10 } { … }

\new StaffGroup <<
  \new GrandStaff \with { \setGroupDistance #12 #15 } <<
    \new Staff { … }
    \new Staff { … }
  >>
  \new Staff { … }
>>
```

- `\smallGroupDistance`
- `\normalGroupDistance`
- `\smallStaffDistance`

For convenience, these three commands for changing distances are predefined.

- `\incipit "<name>" "<clef>" #<space1> #<space2>`
- `\incipitSoprano`
- `\incipitAlto`
- `\incipitTenore`

`\incipit` prints an incipit in front of a staff with the given instrument `name` and `clef`. `space1` and `space2` determine the horizontal space between the instrument name and the staff, or the staff and the system, respectively. For convenience, predefined incipit commands for soprano, alto, and tenor are provided.

```lilypond
\new Staff {
  \incipitSoprano
  \new Voice = "Soprano" { \dynamicUp \SopranoNotes }
}
```

- `\transposedName "<name>" "<pitch>" "<accidental>"`
- `\transposedNameShort "<name>" "<pitch>" "<accidental>"`
- `\transposedTimp "<pitch-high>" "<acc-high>" "<pitch-low>" "<acc-low>"`
- `\transposedTimpShort "<pitch-high>" "<acc-high>" "<pitch-low>" "<acc-low>"`
- `make-one-pitch`
- `make-timp-pitches`

These commands print an instrument name including pitches. `\transposedName` and `\transposedTimp` should be used for the first movement, commands ending in `…Short` should be used for subsequent movements. For special cases, the Scheme functions `make-one-pitch` and `make-timp-pitches` are available.

```lilypond
\new Staff {
  \set Staff.instrumentName = \transposedName "Clarino" "B" "flat"
  \Clarino
}
\new Staff {
  \set Staff.instrumentName = \transposedTimp "B" "flat" "F" ""
  \Timpani
}
```


### Sectioning and TOC

Sectioning commands:
- `\insertEmptyPage`: Inserts an empty page (useful if parts should start on the right page).
- `\part "<label>" "<number>" "<title>"`: Adds a part page, followed by an empty left page. Must be used inside a `\book`. For technical reasons, a `<label>` has to be supplied even if the command is used for a default TOC.
- `\section "<title>"`,
- `\section "<number>" "<title>"`, or
- `\section "<number>" "<genre>" "<title>"`: Adds a section heading. The number of arguments is determined by the option `option-movement-title-format`.
- `\subsection "<title>"`: Adds an unnumbered subsection heading. `\section` and `\subsection` must be used inside a `\bookpart`.

TOC commands:
- `\addTocEntry`: Adds a TOC entry; should be used immediately after a heading command.
- `\addTocLabel "<label>"`: Adds a labeled TOC entry. The `<label>` must be unique throughout the score.

```lilypond
% normal TOC entries
\book {
  \part "" "1" "First part"
  \bookpart {
    \section "1" "Kyrie"
    \addTocEntry
    \score { … }
  }
  \bookpart {
    \subsection "Christe"
    \addTocEntry
    \score { … }
  }
}

% labeled TOC entries
\book {
  \part "firstpart" "1" "First part"
  \bookpart {
    \section "2" "Recitativo" "Title"
    \addTocLabel "label2"
    \score { … }
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

- `\twofourtime` and `\twotwotime` adjust automatic beaming in 2/4 and 2/2 time, respectively.
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


### parse_logs.py

Each run of LilyPond and LuaLaTeX generates a log file, which is stored in *tmp/<score>.ly.log* and *tmp/<score>.tex.log*, respectively. This script collects all errors, warnings, and full boxes from these logs and stores them in *tmp/_logs.txt*.



## instrument_data.csv

This table describes instruments (rows) via the following variables (columns):
- *abbreviation* – abbreviation used in the scoring, the list of abbreviations, and score file names
- *long* – full English name given in the list of abbreviations
- *variable* – name used in LilyPond variables
- *score_type* – name used for the score type on the title page
- *relative* – start pitch for relative octave entry
- *clef* – default clef
- *autobeam* – should notes be beamed automatically? (false for vocal parts)
- *default_key* – overrides key for transposing instruments; 'none' indicates no override
- *second_template* – second variable template to add (for vocal parts and figured bass)



## read_metadata.py

This script creates various outputs from information in `metadata.yaml`, depending on the subcommand given as first argument.

### Subcommand `edition`

Generate a set of LaTeX macros that can be imported by `front_matter/critical_report.tex`. Each of these LaTeX macros starts with `\Metadata...`. The mapping between YAML keys and macros is described below.

- `-h`, `--help`: show this help message and exit
- `-i`, `--input FILE`: read metadata from `FILE` (default: `metadata.yaml`)
- `-o`, `--output FILE`: write the macros to `FILE` (default: `front_matter/critical_report.macros`)
- `-t`, `--type TYPE`: select score `TYPE` for front matter:
  - `draft` (default):
    - set `\MetadataScoretype` to `Draft`
    - include critical report, changelog and TOC
    - do *not* print any scores
  - `full_score`:
    - set `\MetadataScoretype` to `Full Score`
    - include critical report, changelog and TOC
    - print the full score
  - any other value is interpreted as scoring abbreviation:
    - set `\MetadataScoretype` to the long form of the abbreviation
    - do *not* print critical report, changelog and TOC
    - print the respective score
- `-c`, `--checksum-from {head,tag}`: obtain version, date, and checksum from HEAD or the most recent tag (default: `head`)

The long form of a scoring abbreviation is looked up [instrument_data.csv](#instrument_datacsv). The abbreviation may end in an Arabic number, which is converted to a Roman numeral (e.g., `vl2` -> "Violino II"). Abbreviations can also be defined in `metadata.yaml` via the `parts` key (e.g., `clno12` -> "Clarino I, II in C").

The subcommand also obtains the following information from the git metadata:
- name of the remote repository `origin` (-> `\MetadataRepository`)
- version … (-> `\MetadataVersion`)
- … date … (-> `\MetadataDate`)
- … and checksum of HEAD or the most recent tag (-> `\MetadataChecksum`)

Furthermore, the subcommand reads the LilyPond version from the output of `lilypond --version` (-> `\MetadataLilypondVersion`).


### Subcommand `table`

Collect metadata from several repositories and save it as a table. The subcommand requires a folder structure like root -> composer -> work.

- `-h`, `--help`: show this help message and exit
- `-d`, `--root-directory ROOT`: read metadata from all repositories in `ROOT`, assuming the folder structure root -> composer -> repository (default: current folder)
- `-o`, `--output FILE`: write the table to `FILE` (default: `works.csv`)



### metadata.yaml

This file describes metadata for each work and comprises the following keys:
- `composer` (required): The composer's name. The value should either be a single string with format `last name, first name`, or contain the following subkeys:
  - `first` (required): first name (-> `\MetadataFirstname`)
  - `last` (required): last name (-> `\MetadataLastname`)
  - `suffix` (optional): name suffix (-> `\MetadataNamesuffix`)
- `title` (required): Work title (-> `\MetadataTitle`).
- `subtitle` (optional): Work subtitle. The subtitle is combined with the work identifier and stored in `\MetadataSubtitle`. If this key is missing, the work identifier is used alone.
- `id` (optional): Work identifier (typically, the catalogue of works number). If this key is missing, the RISM library siglum and shelfmark of the principal source are used.
- `genre` (required): Work genre (only used on the webpage).
- `scoring` (required): Scoring of the work (-> `\MetadataScoring`). The value should be either a single string or an array. In the latter case, array elements will be joined by newlines. See the editorial guidelines for the scoring syntax. The list of abbreviations in the critical report is also assembled from the scoring information (-> `\MetadataAbbreviations`)
- `sources` (required): Manuscript and print sources used for the edition (-> `\MetadataSources`). The name of each subkey will be used as source identifier (e.g., A1, B2). Each source is described by the following keys:
  - `siglum` (required): RISM library siglum
  - `shelfmark` (required): shelfmark
  - `date` (optional): date
  - `rism` (optional): RISM identifier
  - `url` (optional): link to digital version
  - `notes` (optional): miscellaneous notes
  - `principal` (optional): Boolean that denotes whether this source is the principal source. Exactly one source *must* contain this key with a true value.
- `imslp` (optional): IMSLP identifier (only used on the webpage).
- `notes` (optional): Miscellaneous notes (only used on the webpage).
- `parts` (optional): For each file in the `scores/` subdirectory, this key may contain a subkey-value pair. The subkey corresponds to the file name (without extension), and the value will be used as score type on the title page (-> `\MetadataScoretype`). File names that correspond to default scoring abbreviations (such as `org` and `vl1`) will be converted even in the absence of a respective subkey.
- `extra_abbreviations` (optional): Additional abbreviations and their long forms (subkeys and values, respectively) to be included in the critical report. If the subkey corresponds to a known abbreviation, its value may be empty.



## tex/latex/ees.cls

LaTeX class for printing scores with prefatory material.

### Class options

Type and default value in parentheses.
- `abbrwidth` (length, 3em): width of the first column in the list of abbreviations
- `shortnamesize` (number, 80): font size for the composer name in the title page head
- `shorttitlesize` (number, 60): font size for the work title in the title page head
- `tocstyle` (string, `default`): selects a style for the table of contents
  - `none`: do not print a TOC
  - `default`: print a normal TOC
  - `ref`: print a manual TOC using labels
  - `ref-genre`: print a manual TOC using labels; include a genre

  Note that even if a TOC is not printed, the pdf will contain bookmarks with entries for movements as well as sections in the prefatory material
- `toe` (Boolean, true): indicates whether the commentary contains a table of emendations


### Formatting

- `\textlt{<text>}` and `\ltseries`: Select light text weight.
- `\textsb{<text>}` and `\sbseries`: Select semibold text weight.
- `\A{<number>}` to `\E{<number>}`: Typeset a source identifier (uppercase letter plus index `<number>`).
- `\doublesharp{<pitch>}`, `\sharp{<pitch>}`, `\natural{<pitch>}`, `\flat{<pitch>}`, and `\flatflat{<pitch>}`: Add an accidental to `<pitch>` and ensure correct kerning.
- `\wholeNoteRest` and `\halfNoteRest`: Print respective rest with improved kerning.
- `\demisemiquaverRest` and `\demisemiquaverRestDotted`: Print (dotted) thirty-second rest.
- `\hemidemisemiquaverRest` and `\hemidemisemiquaverRestDotted`: Print (dotted) sixty-fourth rest.


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
- `\ckecksum{}`: checksum of the most recent git tag (default: `\MetadataChecksum`)


### Document structure

- `\eesTitlePage`: Print the default title and copyright page.
- `\eesCriticalReport{<table rows>}`: Print the critical report (abbreviations, sources, and commentary) and the changelog. The single argument may contain rows for the table of emendations, which comprises three columns if `tocstyle=none`, and four columns otherwise. If `toe` is false, the argument is ignored.
- `\eesCommentaryIntro`: Print the default introduction of the commentary section (automatically invoked by `\eesCriticalReport`).
- `\eesToc{<contents>}`: Setup pdf bookmarks; print the table of contents unless `tocstyle=none`. If `tocstyle=ref` or `ref-genre`, the value of the argument is printed under the headline *Contents* and allows to format the TOC manually (see below).
- `\eesScore`: Print the included score.
- `\ifPrintFrontMatter` … `\fi`: Additional content in the prefatory material should be surrounded by this conditional, which ensures that it is only printed in the full score and draft.


### Manual TOC

- `\part{<label>}`: Print a TOC entry for the part with `<label>` as defined in the LY file via `\addTocLabel`.
- `\section{<label>}`: Print a TOC entry for the section with `<label>`.
- `\begin{movement}{<label>} <lyrics> \end{movement}`: Print the TOC entry (section level) for the movement with `<label>`. The `<lyrics>` may comprise
  - continuous text, which represents all lyrics of the respective movement (as seen, for instance, in Michael Haydn's [Litaniae MH 532](https://github.com/edition-esser-skala/haydn-m-litaniae-mh-532)); or
  - text blocks labeled with the associated voice (as seen, for instance, in Stölzel's [Jeſu, Deine Paßion](https://github.com/edition-esser-skala/stoelzel-jesu-deine-passion)). `\voice[<label>]` sets the `<label>` of each text block.


## .github/workflows/engrave-and-release.yaml

This GitHub Actions workflow engraves scores using the [ees-tools](https://ghcr.io/edition-esser-skala/ees-tools) Docker container and creates a GitHub release that includes the generated PDFs. It is triggered whenever a [SemVer](https://semver.org) tag is pushed to GitHub.


## Appendix

### Useful LilyPond snippets

Increase length of multi measure rest.

```lilypond
\override MultiMeasureRest.minimum-length = #40
R\breve.*123 \bar "||"
```

Adjust overall horizontal spacing.

```lilypond
\layout { \context { \Score \override SpacingSpanner.common-shortest-duration = #(ly:make-moment 1/8) } }
```

Define a left-aligned mark.

```lilypond
markFine = {
  \mark \markup { \remarkE "Fine" }
}
```

Change displayed time signature fraction.

```lilypond
\set Staff.timeSignatureFraction = 3/8
```

Add name to choir staff group.

```lilypond
\set ChoirStaff.instrumentName = \markup { \rotate #90 "C O R O   1" \hspace #8 }
```



### Spacing recommendations

Vertical spacing is changed by modifying
- the *top margin* via `top-system-spacing` (default: 20 staff spaces), `top-markup-spacing` (5), and `markup-system-spacing` (15);
- the distance *between systems* via `system-system-spacing` (20); and
- distances *within a system* via `\smallGroupDistance`, `\smallStaffDistance`, and user-defined similar commands.

Note that both the `.basic-distance` and `.minimum-distance` must be changed.

For full scores with **eight staves** (e.g., horns, Vienna church trio and four-part choir), the following settings might allow to print two systems per page:

```lilypond
\paper {
  top-system-spacing.basic-distance = #10
  top-system-spacing.minimum-distance = #10
  top-markup-spacing.basic-distance = #0
  top-markup-spacing.minimum-distance = #0
  markup-system-spacing.basic-distance = #10
  markup-system-spacing.minimum-distance = #10
  system-system-spacing.basic-distance = #17
  system-system-spacing.minimum-distance = #17
  systems-per-page = #2
}

\layout {
  \context {
    \StaffGroup
    \smallGroupDistance
  }
  \context {
    \GrandStaff
    \setGroupDistance #11 #12
  }
  \context {
    \ChoirStaff
    \setGroupDistance #12 #13
  }
}
```

For full scores with **seven staves** (e.g., Vienna church trio and four-part choir), the following settings usually allow to print two systems per page:

```lilypond
\paper {
  top-system-spacing.basic-distance = #10
  top-system-spacing.minimum-distance = #10
  top-markup-spacing.basic-distance = #0
  top-markup-spacing.minimum-distance = #0
  markup-system-spacing.basic-distance = #10
  markup-system-spacing.minimum-distance = #10
  systems-per-page = #2
}
```

Alternatively, decrease system-system spacing to 20 and use `\smallGroupDistance`; this allows to preserve the top margin..

For scores with **six or less staves**, change (a) the distance between systems and (b) the number of systems per page (written as “a/b” in the table below):

```lilypond
\paper {
  system-system-spacing.basic-distance = <a>
  system-system-spacing.minimum-distance = <b>
  systems-per-page = #2
}
```

Staves|Full score                                |Vocal score
------|------------------------------------------|-----------
6     |–/2                                       |–/2
5     |30/2                                      |–/–
4     |22/3                                      |25/3
3     |20/4 (or 30/3)                            |22/4
2     |21/5 (or 18/6 with `\smallGroupDistance`) |20/6

If a work contains **chorals with two stanzas**, define

```lilypond
twoStanzaDistance = \setGroupDistance #15 #20
twoStanzaDistanceCoro = \setGroupDistance #13 #13
```

and apply these to the choir staff in the full and vocal score, respectively. In the vocal score, also increase system-system spacing to 15 if there are three systems on the page.

In **accompagnatos**, parts comprise up to 5 staves per page by default. The number of staves may be increased to six per page if system-system spacing is 16 and the choir staff uses `\smallGroupDistance`.
