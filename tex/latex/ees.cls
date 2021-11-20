\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ees}[2021/12/01 Front matter for the Edition Esser-Skala]



% Class options -----------------------------------------------------------

\RequirePackage{ifthen}


\RequirePackage{kvoptions}

\SetupKeyvalOptions{
  family=ees,
  prefix=ees@
}

\DeclareStringOption[3em]{abbrwidth}
\DeclareStringOption[80]{shortnamesize}
\DeclareStringOption[60]{shorttitlesize}
\DeclareStringOption[default]{tocstyle}
\DeclareBoolOption[true]{toe}

\def\ees@tocstyle@none{none}
\def\ees@tocstyle@default{default}
\def\ees@tocstyle@ref{ref}
\def\ees@tocstyle@refgenre{ref-genre}

\ProcessKeyvalOptions*



% Load base class ---------------------------------------------------------

\LoadClass[parskip=full]{scrreprt}

\setcounter{secnumdepth}{-1}
\RedeclareSectionCommand[pagestyle=plain,afterskip=10pt plus 1pt]{chapter}
\RedeclareSectionCommand[afterskip=0pt plus 1pt,runin=false]{section}
\RedeclareSectionCommand[beforeskip=0pt,afterskip=0pt]{subsection}
\setkomafont{chapter}{\mdseries\headingfont\fontsize{40}{40}\selectfont\color{black!80}}
\setkomafont{section}{\normalfont\sbseries\large}
\setkomafont{subsection}{\normalfont\itshape}
\setkomafont{pageheadfoot}{\normalsize}
\setkomafont{descriptionlabel}{\rmfamily\sbseries}

\def\pnumbox#1{#1\hspace*{8cm}}
\DeclareTOCStyleEntry[
  indent=0pt,
  beforeskip=\baselineskip,
  entryformat=\sbseries,
  entrynumberformat=\textcolor{eesred},
  numwidth=2em,
  linefill=\hfill,
  pagenumberbox=\pnumbox,
  pagenumberformat=\sbseries
]{tocline}{part}

\DeclareTOCStyleEntry[
  indent=0pt,
  beforeskip=0pt,
  entrynumberformat=\textcolor{eesred},
  numwidth=2em,
  linefill=\hfill,
  pagenumberbox=\pnumbox
]{tocline}{section}

\DeclareTOCStyleEntry[
  indent=0pt,
  beforeskip=-\parskip,
  entrynumberformat=\@gobble,
  entryformat=\ltseries,
  numwidth=2em,
  linefill=\hfill,
  pagenumberbox=\pnumbox,
  pagenumberformat=\ltseries
]{tocline}{subsection}



% Packages ----------------------------------------------------------------

\RequirePackage{polyglossia}
\setdefaultlanguage{english}
\appto{\textenglish}{\frenchspacing}


\RequirePackage{fontspec}
\setmainfont{Source Sans 3}[
  ItalicFont = Source Sans 3 Italic,
  BoldFont = Source Sans 3 Bold,
  BoldItalicFont = Source Sans 3 Bold Italic,
  FontFace = {lt}{n}{Source Sans 3 Light},
  FontFace = {lt}{it}{Source Sans 3 Light Italic},
  FontFace = {sb}{n}{Source Sans 3 Semibold},
  FontFace = {sb}{it}{Source Sans 3 Semibold Italic},
  Numbers = Proportional,
  Ligatures = Common
]
\DeclareRobustCommand{\ltseries}{\fontseries{lt}\selectfont}
\DeclareRobustCommand{\sbseries}{\fontseries{sb}\selectfont}
\DeclareTextFontCommand{\textlt}{\ltseries}
\DeclareTextFontCommand{\textsb}{\sbseries}
\newfontfamily\headingfont{Fredericka the Great}


\RequirePackage{fontawesome5}


\RequirePackage{lilyglyphs}

\let\ees@oldflat\flat
\def\flat#1{#1\kern.1em\ees@oldflat}
\let\ees@oldsharp\sharp
\def\sharp#1{#1\kern.1em\ees@oldsharp}
\let\ees@oldnatural\natural
\def\natural#1{#1\kern.1em\ees@oldnatural}
\let\ees@olddoublesharp\doublesharp
\def\doublesharp#1{#1\kern.1em\ees@olddoublesharp}
\let\ees@oldflatflat\flatflat
\def\flatflat#1{#1\kern.1em\ees@oldflatflat}
\let\ees@oldwholeNoteRest\wholeNoteRest
\def\wholeNoteRest{\kern.12em\ees@oldwholeNoteRest\kern.2em}
\let\ees@oldhalfNoteRest\halfNoteRest
\def\halfNoteRest{\kern.12em\ees@oldhalfNoteRest\kern.2em}

\newcommand*\demisemiquaverRest[1][]{%
  \setkeys{lilyDesignOptions}{scale=1.3,raise=0.5}%
  \lilyPrint[#1]{\lilyGetGlyph{rests.5}}%
}

\newcommand*\demisemiquaverRestDotted[1][]{%
  \setkeys{lilyDesignOptions}{scale=0.8,raise=0.2}%
  \lilySetDotOptions[#1]{0}{0}{-0.1}%
  \demisemiquaverRest[#1]\lilyDotSpace\lilyPrintDot%
}

\newcommand*\hemidemisemiquaverRest[1][]{%
  \setkeys{lilyDesignOptions}{scale=1.3,raise=0.8}%
  \lilyPrint[#1]{\lilyGetGlyph{rests.6}}%
}

\newcommand*\hemidemisemiquaverRestDotted[1][]{%
  \setkeys{lilyDesignOptions}{scale=0.8,raise=0.2}%
  \lilySetDotOptions[#1]{0}{0}{-0.1}%
  \hemidemisemiquaverRest[#1]\lilyDotSpace\lilyPrintDot%
}


\RequirePackage[pass]{geometry}
\newgeometry{twoside,inner=20mm,outer=40mm,top=20mm,bottom=40mm}


\RequirePackage[hyphens]{url}
\urlstyle{same}


\RequirePackage{microtype}
\microtypesetup{verbose=silent}


\RequirePackage{booktabs,xltabular}


\RequirePackage{graphicx}


\RequirePackage{xcolor}
\definecolor{eesred}{RGB}{212,0,0}


\RequirePackage{pdfpages}


\RequirePackage{scrlayer-scrpage}
\pagestyle{scrheadings}
\clearscrheadfoot
\cfoot[\thepage]{\thepage}
\pagenumbering{roman}


\RequirePackage{enumitem}
\ifthenelse{\equal{\ees@tocstyle}{\ees@tocstyle@refgenre}}{%
  \def\ees@movement@labelwidth{6.5em}%
  \def\ees@movement@leftmargin{8.5em}%
  \def\ees@movement@topsep{0pt}%
}{%
  \def\ees@movement@labelwidth{0em}%
  \def\ees@movement@leftmargin{2em}%
  \def\ees@movement@topsep{-\parskip}%
}


\newlist{ees@movement}{description}{1}
\setlist[ees@movement]{
  labelindent=2em,
  labelwidth=\ees@movement@labelwidth,
  leftmargin=\ees@movement@leftmargin,
  labelsep=0pt,
  first=\vspace*{\ees@movement@topsep}\ltseries,
  font=\normalfont\itshape\ltseries
}
\newenvironment{movement}[1]{%
  \section{#1}%
  \begin{ees@movement}%
  \let\voice\item%
  \ifthenelse{\equal{\ees@tocstyle}{\ees@tocstyle@refgenre}}{}{\item[]}%
}{%
  \end{ees@movement}%
}

\newlist{sources}{description}{1}
\setlist[sources]{
  labelindent=0pt,
  labelwidth=\ees@abbrwidth,
  leftmargin=\ees@abbrwidth,
  labelsep=0pt,
  font=\normalfont\sbseries,
  parsep=\baselineskip,
  itemsep=0pt
}

\def\ees@sourceitemlabel#1{\makebox[6em][l]{\itshape#1}}
\newcommand\sourceitem[8]{%
  \item[#1]%
    \ees@sourceitemlabel{Library}\textmd{#2}\newline%
    \ees@sourceitemlabel{Shelfmark}\textmd{#3}\newline%
    \ees@sourceitemlabel{Category}#4\newline%
    \ees@sourceitemlabel{Date}#5\newline%
    \ees@sourceitemlabel{RISM ID}#6\newline%
    \ees@sourceitemlabel{URL}\url{#7}%
    \ifthenelse{\equal{#8}{\@empty}}{}{\newline\ees@sourceitemlabel{Notes}#8}%
}

\def\A#1{\textsb{A#1}}
\def\B#1{\textsb{B#1}}
\def\C#1{\textsb{C#1}}
\def\D#1{\textsb{D#1}}
\def\E#1{\textsb{E#1}}

\newlist{abbreviations}{description}{1}
\setlist[abbreviations]{
  labelindent=0pt,
  labelwidth=\ees@abbrwidth,
  leftmargin=\ees@abbrwidth,
  labelsep=0pt,
  font=\normalfont\sbseries,
  itemsep=-\parsep
}
\newcommand\abbr[2]{\item[#1]#2}


\RequirePackage[cacheDir=/tmp/latex-markdown,smartEllipses]{markdown}


\RequirePackage{datetime2}
\DTMsetstyle{iso}


\RequirePackage{bibleref}


\RequirePackage[linktoc=all,hidelinks]{hyperref}



% TOC commands ------------------------------------------------------------

\def\ees@dotfill{\leavevmode\cleaders\hb@xt@ .75em{\hss .\hss }\hfill \kern \z@}

\ifthenelse{\equal{\ees@tocstyle}{\ees@tocstyle@default}}{%
  \newcommand\newtocentry[6]{\contentsline{#2}{\numberline{#3}#5}{#6}{score.#6}}%
}{}
\ifthenelse{%
  \equal{\ees@tocstyle}{\ees@tocstyle@ref}%
  \or%
  \equal{\ees@tocstyle}{\ees@tocstyle@refgenre}%
}{%
  \newcommand\newtocentry[6]{\newlabel{#1}{{#3}{#4}{#5}{#6}}}%
}{}
\providecommand\newtocentry[6]{}


\def\ees@ref@getnumber#1#2#3#4{#1}
\def\ees@ref@getgenre#1#2#3#4{#2}
\def\ees@ref@gettitle#1#2#3#4{#3}
\def\ees@ref@getpage#1#2#3#4{#4}

\def\ees@ref@number#1{%
  \expandafter\@setref\csname r@#1\endcsname\ees@ref@getnumber{#1}%
}
\def\ees@ref@genre#1{%
  \expandafter\@setref\csname r@#1\endcsname\ees@ref@getgenre{#1}%
}
\def\ees@ref@title#1{%
  \expandafter\@setref\csname r@#1\endcsname\ees@ref@gettitle{#1}%
}
\def\ees@ref@page#1{%
  \expandafter\@setref\csname r@#1\endcsname\ees@ref@getpage{#1}%
}


\def\ees@toc@part#1{%
  \begingroup%
  \makebox[0pt][l]{\sbseries\color{eesred}\ees@ref@number{#1}}%
  \hspace*{2em}%
  \makebox[0pt][l]{\sbseries\ees@ref@title{#1}}%
  \hfill%
  \sbseries\ees@ref@page{#1}%
  \endgroup%
}

\def\ees@toc@section#1{%
  \begingroup%
  \makebox[0pt][l]{\color{eesred}\ees@ref@number{#1}}%
  \hspace*{2em}%
  \ifthenelse{\equal{\ees@tocstyle}{\ees@tocstyle@refgenre}}{%
    \makebox[0pt][l]{\ltseries\ees@ref@genre{#1}}%
    \hspace*{6.5em}%
  }{}%
  \ees@ref@title{#1}%
  \ees@dotfill%
  \ees@ref@page{#1}%
  \endgroup%
}



% Title page --------------------------------------------------------------

\newcommand\eestitlehead{%
  \headingfont%
  \fontsize{\ees@shortnamesize}{\ees@shortnamesize}\selectfont%
  \textcolor{black!80}{%
    \makebox[0pt][l]{\@shortname.}%
  }\\[15pt]%
  \fontsize{\ees@shorttitlesize}{\ees@shorttitlesize}\selectfont%
  \makebox[0pt][l]{\@shorttitle.}%
}

\def\firstname#1{\def\@firstname{#1}}
\def\lastname#1{\def\@lastname{#1}}
\def\shortname#1{\def\@shortname{#1}}
\def\shorttitle#1{\def\@shorttitle{#1}}
\def\namesuffix#1{\def\@namesuffix{#1}}
\def\scoring#1{\def\@scoring{#1}}
\def\scoretype#1{\def\@scoretype{#1}}
\def\repository#1{\def\@repository{#1}}
\def\version#1{\def\@version{#1}}
\def\date#1{\DTMsavedate{tagdate}{#1}}
\def\checksum#1{\def\@checksum{#1}}



% Metadata ----------------------------------------------------------------

\newif\ifPrintFrontMatter\PrintFrontMattertrue

\InputIfFileExists{critical_report.macros}{}{}
\providecommand\MetadataFirstname{\relax}
\providecommand\MetadataLastname{\relax}
\providecommand\MetadataNamesuffix{\relax}
\providecommand\MetadataTitle{\relax}
\providecommand\MetadataSubtitle{\relax}
\providecommand\MetadataScoring{\relax}
\providecommand\MetadataScoretype{\relax}
\providecommand\MetadataRepository{\relax}
\providecommand\MetadataVersion{\relax}
\providecommand\MetadataDate{2021-01-01}
\providecommand\MetadataChecksum{\relax}
\providecommand\MetadataLilypondVersion{\relax}
\providecommand\MetadataSources{\relax}
\providecommand\MetadataAbbreviations{\relax}
\providecommand\eesScore{\relax}

\titlehead{\eestitlehead}
\firstname{\MetadataFirstname}
\lastname{\MetadataLastname}
\namesuffix{\MetadataNamesuffix}
\shortname{\MetadataLastname}
\title{\MetadataTitle}
\shorttitle{\MetadataTitle}
\subtitle{\MetadataSubtitle}
\scoring{\MetadataScoring}
\scoretype{\MetadataScoretype}
\repository{\MetadataRepository}
\version{\MetadataVersion}
\date{\MetadataDate}
\checksum{\MetadataChecksum}



% Text blocks -------------------------------------------------------------

\def\eesTitlePage{%
  \begin{titlepage}%
    \Large%
    {\@titlehead}%
    \vfill%
    {\strut\@firstname}\\%
    {\sbseries\color{eesred}\strut\@lastname}\\%
    {\strut\@namesuffix}%
    \vfill%
    {\sbseries\@title}\\%
    {\@subtitle}\\[\baselineskip]%
    {\itshape\@scoring}%
    \vfill%
    {\itshape\@scoretype}\hspace*{\fill}%
     \raisebox{0pt}[0pt][0pt]{\includegraphics[scale=1.25]{logo_full}}%
  \end{titlepage}%

  \thispagestyle{empty}

  \vspace*{\fill}

  \raisebox{-4mm}{\includegraphics{by-sa}}\hspace*{1em}%
  Edition Esser-Skala, \DTMfetchyear{tagdate}

  © \DTMfetchyear{tagdate} by Edition Esser-Skala. This edition is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit \url{https://creativecommons.org/licenses/by-sa/4.0/}.

  Music engraving by LilyPond \MetadataLilypondVersion~(\url{https://www.lilypond.org}).\\
  Front matter typeset with Source Sans and Fredericka the Great.

  Please report any errors or mistakes to \url{edition@esser-skala.at.}

  \faGithub~\@repository\\
  \textit{\@version, \DTMusedate{tagdate} (\@checksum)}

  \vspace*{2cm}%
}

\def\eesCriticalReport#1{%
  \ifPrintFrontMatter%
    \chapter*{Critical Report}%
      \section*{Abbreviations}%
        \MetadataAbbreviations%
      \section*{Sources}%
        \MetadataSources%
      \section*{Commentary}%
        \eesCommentaryIntro%
        \ifees@toe%
          \par Asterisks denote the following emendations:
          \ifthenelse{\equal{\ees@tocstyle}{\ees@tocstyle@none}}{%
            \begin{xltabular}{\linewidth}{ll X}
              \toprule
              \itshape Bar & \itshape Staff & \itshape Description \\
              \midrule \endhead
              #1
              \bottomrule
            \end{xltabular}%
          }{
            \begin{xltabular}{\linewidth}{lll X}
              \toprule
              \itshape Mov. & \itshape Bar & \itshape Staff & \itshape Description \\
              \midrule \endhead
              #1
              \bottomrule
            \end{xltabular}%
          }%
        \fi% ifees@toe
    \cleardoublepage%
    \markdownInput{../CHANGELOG.md}%
  \fi% ifPrintFrontMatter
}

\def\eesCommentaryIntro{%
  In general, this edition closely follows the principal source. Any changes that were introduced by the editor are indicated by italic type (lyrics, dynamics and directives), parentheses (expressive marks and bass figures) or dashes (slurs and ties). Accidentals are used according to modern conventions. For further details, consult the Editorial Guidelines available on the Edition's webpage.%
}

\long\def\eesToc#1{%
  \ifPrintFrontMatter%
    \cleardoublepage%
    \chapter*{Contents}%
    \InputIfFileExists%
      {../tmp/lilypond.toc}%
      {}%
      {\InputIfFileExists{../lilypond.toc}{}{}}%
    \begingroup%
    \let\part\ees@toc@part%
    \let\section\ees@toc@section%
    #1%
    \endgroup%
  \fi%
}
