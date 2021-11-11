\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ees}[2021/12/01 Front matter for the Edition Esser-Skala]



% Package options ---------------------------------------------------------

\RequirePackage{kvoptions}

\SetupKeyvalOptions{
  family=ees,
  prefix=ees@
}

\DeclareBoolOption{parts}
\DeclareBoolOption{toclyrics}
\DeclareBoolOption[true]{table}
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

\def\pnumbox#1{#1\hspace*{8cm}}
\DeclareTOCStyleEntry[
  indent=\ifees@parts 2em \else 0pt \fi,
  beforeskip=\ifees@parts -\baselineskip \else 0pt \fi,
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


\RequirePackage{fontspec}
\setmainfont{Source Sans Pro}[
  ItalicFont = Source Sans Pro Italic,
  BoldFont = Source Sans Pro Bold,
  BoldItalicFont = Source Sans Pro Bold Italic,
  FontFace = {lt}{n}{Source Sans Pro Light},
  FontFace = {lt}{it}{Source Sans Pro Light Italic},
  FontFace = {sb}{n}{Source Sans Pro Semibold},
  FontFace = {sb}{it}{Source Sans Pro Semibold Italic},
  Numbers = Proportional,
  Ligatures = Common
]
\DeclareRobustCommand{\ltseries}{\fontseries{lt}\selectfont}
\DeclareRobustCommand{\sbseries}{\fontseries{sb}\selectfont}
\DeclareTextFontCommand{\textlt}{\ltseries}
\DeclareTextFontCommand{\textsb}{\sbseries}
\newfontfamily\headingfont{Fredericka the Great}
\newfontfamily\fontawesome{FontAwesome}


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
\ifees@toclyrics
  \setlist[description]{
    labelindent=2em,
    labelwidth=6.5em,
    leftmargin=8.5em,
    labelsep=0pt,
    first=\ltseries,
    font=\normalfont\itshape\ltseries
  }
\else
  \setlist[description]{
    style=nextline,
    leftmargin=2em,
    first=\ltseries,
    font=\normalfont
  }
\fi
\def\lyrefitem#1{\item[\lyref{#1}]}

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

\def\sourceitemlabel#1{\makebox[6em][l]{\itshape#1}}
\newcommand\sourceitem[8]{%
  \begingroup%
  \def\@tempa{#8}%
  \item[#1]%
    \sourceitemlabel{Library}\textmd{#2}\newline%
    \sourceitemlabel{Shelfmark}\textmd{#3}\newline%
    \sourceitemlabel{Type}#4\newline%
    \sourceitemlabel{Date}#5\newline%
    \sourceitemlabel{RISM ID}#6\newline%
    \sourceitemlabel{URL}\url{#7}%
    \ifx\@tempa\@empty\else\newline\sourceitemlabel{Notes}#8\fi%
  \endgroup%
}

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

\def\@firstofthree#1#2#3{#1}
\def\@secondofthree#1#2#3{#2}
\def\@thirdofthree#1#2#3{#3}
\def\@firstoffour#1#2#3#4{#1}
\def\@secondoffour#1#2#3#4{#2}
\def\@thirdoffour#1#2#3#4{#3}
\def\@fourthoffour#1#2#3#4{#4}
\def\Dotfill{\leavevmode\cleaders\hb@xt@ .75em{\hss .\hss }\hfill \kern \z@}

\def\lyrefshortnumber#1{%
  \expandafter\@setref\csname r@#1\endcsname\@firstofthree{#1}%
}
\def\lyrefshorttitle#1{%
  \expandafter\@setref\csname r@#1\endcsname\@secondofthree{#1}%
}
\def\lyrefshortpage#1{%
  \expandafter\@setref\csname r@#1\endcsname\@thirdofthree{#1}%
}

\def\lyreflongnumber#1{%
  \expandafter\@setref\csname r@#1\endcsname\@firstoffour{#1}%
}
\def\lyreflonggenre#1{%
  \expandafter\@setref\csname r@#1\endcsname\@secondoffour{#1}%
}
\def\lyreflongtitle#1{%
  \expandafter\@setref\csname r@#1\endcsname\@thirdoffour{#1}%
}
\def\lyreflongpage#1{%
  \expandafter\@setref\csname r@#1\endcsname\@fourthoffour{#1}%
}

\def\lyref#1{%
  \begingroup%
  \makebox[0pt][l]{\color{eesred}\lyrefshortnumber{#1}}\hspace*{2em}%
  \lyrefshorttitle{#1}\Dotfill\lyrefshortpage{#1}%
  \endgroup%
}
\def\lyrefpart#1{%
  \begingroup%
  \makebox[0pt][l]{\sbseries\color{eesred}\lyrefshortnumber{#1}}\hspace*{2em}%
  \makebox[0pt][l]{\sbseries\lyrefshorttitle{#1}}\hspace*{6.5em}%
  \hfill\sbseries\lyrefshortpage{#1}%
  \endgroup%
}
\def\lyrefsection#1{%
  \begingroup%
  \makebox[0pt][l]{\color{eesred}\lyreflongnumber{#1}}\hspace*{2em}%
  \makebox[0pt][l]{\ltseries\lyreflonggenre{#1}}\hspace*{6.5em}%
  \lyreflongtitle{#1}\Dotfill\lyreflongpage{#1}%
  \endgroup%
}
\InputIfFileExists%
  {../tmp/lilypond.ref}%
  {}%
  {\InputIfFileExists{../lilypond.ref}{}{}}



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

  \raisebox{-4mm}{\includegraphics{byncsaeu}}\hspace*{1em}%
  Edition Esser-Skala, \DTMfetchyear{tagdate}

  © \DTMfetchyear{tagdate} by Edition Esser-Skala. This edition is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit \url{https://creativecommons.org/licenses/by-nc-sa/4.0/}.

  Music engraving by LilyPond \MetadataLilypondVersion~(\url{https://www.lilypond.org}).\\
  Front matter typeset with Source Sans and Fredericka the Great.

  Please report any errors or mistakes to \url{edition@esser-skala.at.}

  {\fontawesome}~\@repository\\
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
        \ifees@table%
          \par Asterisks denote the following emendations:
          \ifees@movcol%
            \begin{xltabular}{\linewidth}{lll X}
              \toprule
              \itshape Mov. & \itshape Bar & \itshape Staff & \itshape Note \\
              \midrule \endhead
              #1
              \bottomrule
            \end{xltabular}%
          \else%
          \begin{xltabular}{\linewidth}{ll X}
            \toprule
            \itshape Bar & \itshape Staff & \itshape Note \\
            \midrule \endhead
            #1
            \bottomrule
          \end{xltabular}%
          \fi% ifees@movcol
        \fi% ifees@table
  \fi% ifPrintFrontMatter
}

\def\eesCommentaryIntro{%
  In general, this edition closely follows the primary source. Any changes that were introduced by the editor are indicated by italic type (lyrics, dynamics and directions), parentheses (expressive marks and bass figures) or dashes (slurs and ties). Accidentals are used according to modern conventions. For further details, consult the Editorial Guidelines available on the Edition's webpage.%
}

\def\eesToc#1{%
  \ifPrintFrontMatter%
    \cleardoublepage%
    \markdownInput{../CHANGELOG.md}%
    \cleardoublepage%
    \chapter*{Contents}%
    \InputIfFileExists%
      {../tmp/lilypond.toc}%
      {}%
      {\InputIfFileExists{../lilypond.toc}{}{}}%
    #1%
  \fi%
}

\AtBeginDocument{\frenchspacing}
