\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ees}[2021/12/01 Front matter for the Edition Esser-Skala]



% Class options -----------------------------------------------------------

\RequirePackage{kvoptions}

\SetupKeyvalOptions{
  family=ees,
  prefix=ees@
}

\DeclareBoolOption[false]{parts}
\DeclareBoolOption[false]{tocgenre}
\DeclareBoolOption[true]{toe}
\DeclareBoolOption[true]{movcol}
\DeclareStringOption[80]{shortnamesize}
\DeclareStringOption[60]{shorttitlesize}
\DeclareStringOption[3em]{abbrwidth}

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
  indent=\ifees@parts2em\else0pt\fi,
  beforeskip=\ifees@parts-\baselineskip\else0pt\fi,
  entryformat=\itshape,
  entrynumberformat=\textcolor{eesred},
  numwidth=2em,
  linefill=\hfill,
  pagenumberbox=\pnumbox,
  pagenumberformat=\itshape
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
  entrynumberformat=\gobble,
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
\edef\ees@movement@labelwidth{\ifees@tocgenre6.5em\else0em\fi}
\edef\ees@movement@leftmargin{\ifees@tocgenre8.5em\else2em\fi}
\edef\ees@movement@topsep{\ifees@tocgenre0pt\else-\parskip\fi}
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
  \ifees@tocgenre\else\item[]\fi%
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
  \begingroup%
  \def\@tempa{#8}%
  \item[#1]%
    \ees@sourceitemlabel{Library}\textmd{#2}\newline%
    \ees@sourceitemlabel{Shelfmark}\textmd{#3}\newline%
    \ees@sourceitemlabel{Type}#4\newline%
    \ees@sourceitemlabel{Date}#5\newline%
    \ees@sourceitemlabel{RISM ID}#6\newline%
    \ees@sourceitemlabel{URL}\url{#7}%
    \ifx\@tempa\@empty\else\newline\ees@sourceitemlabel{Notes}#8\fi%
  \endgroup%
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



% TOC commands ------------------------------------------------------------

\InputIfFileExists%
  {../tmp/lilypond.ref}%
  {}%
  {\InputIfFileExists{../lilypond.ref}{}{}}

\def\ees@dotfill{\leavevmode\cleaders\hb@xt@ .75em{\hss .\hss }\hfill \kern \z@}


%% Short references
\def\@firstofthree#1#2#3{#1}
\def\@secondofthree#1#2#3{#2}
\def\@thirdofthree#1#2#3{#3}

\def\ees@shortref@number#1{%
  \expandafter\@setref\csname r@#1\endcsname\@firstofthree{#1}%
}
\def\ees@shortref@title#1{%
  \expandafter\@setref\csname r@#1\endcsname\@secondofthree{#1}%
}
\def\ees@shortref@page#1{%
  \expandafter\@setref\csname r@#1\endcsname\@thirdofthree{#1}%
}

\def\ees@toc@section@short#1{%
  \begingroup%
  \makebox[0pt][l]{\color{eesred}\ees@shortref@number{#1}}%
  \hspace*{2em}%
  \ees@shortref@title{#1}%
  \ees@dotfill%
  \ees@shortref@page{#1}%
  \endgroup%
}


%% Long references
\def\@firstoffour#1#2#3#4{#1}
\def\@secondoffour#1#2#3#4{#2}
\def\@thirdoffour#1#2#3#4{#3}
\def\@fourthoffour#1#2#3#4{#4}

\def\ees@longref@number#1{%
  \expandafter\@setref\csname r@#1\endcsname\@firstoffour{#1}%
}
\def\ees@longref@genre#1{%
  \expandafter\@setref\csname r@#1\endcsname\@secondoffour{#1}%
}
\def\ees@longref@title#1{%
  \expandafter\@setref\csname r@#1\endcsname\@thirdoffour{#1}%
}
\def\ees@longref@page#1{%
  \expandafter\@setref\csname r@#1\endcsname\@fourthoffour{#1}%
}

\def\ees@toc@part#1{%
  \begingroup%
  \makebox[0pt][l]{\sbseries\color{eesred}\ees@shortref@number{#1}}%
  \hspace*{2em}%
  \makebox[0pt][l]{\sbseries\ees@shortref@title{#1}}%
  \hfill%
  \sbseries\ees@shortref@page{#1}%
  \endgroup%
}
\def\ees@toc@section@long#1{%
  \begingroup%
  \makebox[0pt][l]{\color{eesred}\ees@longref@number{#1}}%
  \hspace*{2em}%
  \makebox[0pt][l]{\ltseries\ees@longref@genre{#1}}%
  \hspace*{6.5em}%
  \ees@longref@title{#1}%
  \ees@dotfill%
  \ees@longref@page{#1}%
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
  \textit{\@version, \DTMusedate{tagdate}}

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
          \ifees@movcol%
            \begin{xltabular}{\linewidth}{lll X}
              \toprule
              \itshape Mov. & \itshape Bar & \itshape Staff & \itshape Description \\
              \midrule \endhead
              #1
              \bottomrule
            \end{xltabular}%
          \else%
          \begin{xltabular}{\linewidth}{ll X}
            \toprule
            \itshape Bar & \itshape Staff & \itshape Description \\
            \midrule \endhead
            #1
            \bottomrule
          \end{xltabular}%
          \fi% ifees@movcol
        \fi% ifees@toe
  \fi% ifPrintFrontMatter
}

\def\eesCommentaryIntro{%
  In general, this edition closely follows the primary source. Any changes that were introduced by the editor are indicated by italic type (lyrics, dynamics and directives), parentheses (expressive marks and bass figures) or dashes (slurs and ties). Accidentals are used according to modern conventions. For further details, consult the Editorial Guidelines available on the Edition's webpage.%
}

\long\def\eesToc#1{%
  \ifPrintFrontMatter%
    \cleardoublepage%
    \markdownInput{../CHANGELOG.md}%
    \cleardoublepage%
    \chapter*{Contents}%
    \InputIfFileExists%
      {../tmp/lilypond.toc}%
      {}%
      {\InputIfFileExists{../lilypond.toc}{}{}}%
    \begingroup%
    \let\part\ees@toc@part%
    \ifees@tocgenre%
      \let\section\ees@toc@section@long%
    \else%
      \let\section\ees@toc@section@short%
    \fi%
    #1%
    \endgroup%
  \fi%
}
