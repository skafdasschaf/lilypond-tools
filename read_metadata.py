#!/usr/bin/python

import argparse
from git import Repo
import logging
import os
import re
import subprocess
import time
import yaml


logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s [%(asctime)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)


# Constants ---------------------------------------------------------------

NAME_SUFFIXES = ["der Ältere", "der Jüngere"]

DEFAULT_ABBREVIATIONS = {
    "Ms": "manuscript",
    "r": "rest"
}

ABBR_INFO = {
    "fl": "flute",
    "cnto": "cornett",
    "ob": "oboe",
    "cl": "clarinet",
    "fag": "bassoon",
    "cor": "horn",
    "clno": "clarion",
    "tr": "trumpet",
    "trb": "trombone",
    "timp": "timpani",
    "vl": "violin",
    "vla": "viola",
    "vlc": "violoncello",
    "vlne": "violone",
    "S": "soprano",
    "A": "alto",
    "T": "tenor",
    "B": "bass",
    "org": "organ",
    "cemb": "cembalo",
    "b": "basses"
}

SOURCE_TYPES = {
    "A": "autograph manuscript",
    "B": "manuscript copy",
    "C": "print",
    "D": "manuscript not used for this edition",
    "E": "print not used for this edition"
}



# LaTeX templates ---------------------------------------------------------

METADATA_TEMPLATE = """
\\def\\MetadataFirstname{{{first_name}}}
\\def\\MetadataLastname{{{last_name}}}
\\def\\MetadataNamesuffix{{{name_suffix}}}
\\def\\MetadataTitle{{{title}}}
\\def\\MetadataSubtitle{{{subtitle}}}
\\def\\MetadataScoring{{{scoring}}}
\\def\\MetadataScoretype{{{score_type}}}
\\def\\MetadataRepository{{{repository}}}
\\def\\MetadataVersion{{{version}}}
\\def\\MetadataDate{{{date}}}
\\def\\MetadataLilypondVersion{{{lilypond_version}}}
\\def\\MetadataSources{{{sources_formatted}}}
\\def\\MetadataAbbreviations{{{abbreviations}}}
"""

SUBTITLE_TEMPLATE = "{}\\newline {}"

PRIMARY_SOURCE_TEMPLATE = "{} (primary source)"

PRIMARY_ID_TEMPLATE = "({} {})"

SOURCES_TEMPLATE = """
\\begin{{sources}}
  {}
\\end{{sources}}
"""

SOURCE_ITEM_TEMPLATE = """
\\sourceitem%
  {{{id}}}%
  {{{siglum}}}%
  {{{shelfmark}}}%
  {{{type}}}%
  {{{date}}}%
  {{{rism}}}%
  {{{url}}}%
  {{{notes}}}
"""

ABBREVIATIONS_TEMPLATE = """
\\begin{{abbreviations}}
  {}
\\end{{abbreviations}}
"""

ABBREVIATIONS_ITEM_TEMPLATE = "\\abbr{{{short}}}{{{long}}}"

PRINT_SCORE_TEMPLATE = """
\\def\\eesScore{{\\cleardoublepage\\includepdf[pages=-]{{../tmp/{}.pdf}}}}
"""



# Parse arguments ---------------------------------------------------------

parser = argparse.ArgumentParser(add_help=True)
parser.add_argument(
    "-t",
    dest="type",
    default="draft",
    help="selects output type ('full_score', 'draft', or part name)"
)
args = parser.parse_args()



# Prepare metadata --------------------------------------------------------

with open("metadata.yaml") as f:
    metadata = yaml.load(f, Loader=yaml.SafeLoader)


## Names

# The `composer` key is required and will be split into first and last name.
# If the last name ends with a known name suffix (NAME_SUFFIXES),
# it is stored in a separate variable.

metadata["last_name"], metadata["first_name"] = metadata["composer"].split(", ")
for ns in NAME_SUFFIXES:
    m = re.search(f"(.+) ({ns})", metadata["last_name"])
    if m:
        metadata["last_name"], metadata["name_suffix"] = m.groups()
        break
else:
    metadata["name_suffix"] = ""


## Scoring

# The `scoring` key may be a string or array.
# In the latter case, its elements are joined by newlines.

if isinstance(metadata["scoring"], list):
    metadata["scoring"] = "\\newline ".join(metadata["scoring"])


## Score type

# The score type depends on the value of `-t` and is either set to "Draft",
# "Full Score", or the respective part as specified by the `parts` key.

if args.type == "draft":
    metadata["score_type"] = "Draft"
elif args.type == "full_score":
    metadata["score_type"] = "Full Score"
else:
    metadata["score_type"] = metadata["parts"][args.type]


## Repository

# The name of the remote repository "origin" is read from the git metadata,
# as are the version and date of the most recent tag.

metadata["repository"] = re.match(
    "git@github\\.com:(.+)\\.git",
    Repo(".").remotes.origin.url
).group(1)
metadata["version"] = Repo(".").tags[-1].tag.tag
metadata["date"] = time.strftime(
    "%Y-%m-%d",
    time.gmtime(Repo(".").tags[-1].tag.tagged_date)
)


## LilyPond version

# The LilyPond version is obtained from the executable.

lilypond_version = subprocess.run(
    ["lilypond", "--version"],
    capture_output=True,
    text=True
).stdout
metadata["lilypond_version"] = re.search(
    "GNU LilyPond (.+)\n",
    lilypond_version
).group(1)


## Sources

# For each entry in `sources`, convert the date to ISO format,
# add missing RISM information and notes,
# and determine the identifier of the primary source

source_items = []
for id, info in metadata["sources"].items():
    info["type"] = SOURCE_TYPES[id[0]]

    try:
        info["date"] = info["date"].strftime("%Y-%m-%d")
    except AttributeError:
        pass

    if "rism" not in info or info["rism"] is None:
        info["rism"] = "(none)"

    if "notes" not in info or info["notes"] is None:
        info["notes"] = ""

    if "primary" in info and info["primary"]:
        info["type"] = PRIMARY_SOURCE_TEMPLATE.format(info["type"])
        metadata["primary_id"] = PRIMARY_ID_TEMPLATE.format(info["siglum"],
                                                            info["shelfmark"])

    source_items.append(SOURCE_ITEM_TEMPLATE.format(id=id, **info))

metadata["sources_formatted"] = SOURCES_TEMPLATE.format("\n".join(source_items))


## Subtitle

# The subtitle consists of the value of the `subtitle` key (if available)
# and the catalogue of works id, separated by a newline. If the latter id
# is not specified, the primary source identifier is used.

if "id" not in metadata or metadata["id"] is None:
    metadata["id"] = metadata["primary_id"]

if "subtitle" not in metadata:
    metadata["subtitle"] = metadata["id"]
else:
    metadata["subtitle"] = SUBTITLE_TEMPLATE.format(metadata["subtitle"],
                                                    metadata["id"])


## Abbreviations

# Abbreviations comprise the DEFAULT_ABBREVIATIONS and the instrument
# abbreviations found in the `scoring` key. Since each individual instrument
# may be surrounded by brackets or end with the pitch in parentheses,
# these elements are removed.

abbreviations = DEFAULT_ABBREVIATIONS
for a in metadata["scoring"].replace("\\newline", "").split(","):
    a = a.strip(" \n")
    if a[0] == "[":
        a = a[1:-1]
    if a[-1] == ")":
        a = re.match("[^\(]+", a).group(0).strip()
    a = a.lstrip("0123456789 ")
    try:
        abbreviations[a] = ABBR_INFO[a]
    except KeyError:
        logging.warning(f"Abbreviation {a} unknown.")

metadata["abbreviations"] = ABBREVIATIONS_TEMPLATE.format(
    "\n  ".join(
        [ABBREVIATIONS_ITEM_TEMPLATE.format(short=k, long=v)
         for k, v in sorted(abbreviations.items())]
    )
)



# Assemble macros ---------------------------------------------------------

## Conditionals
if args.type in ("draft", "full_score"):
    macros_conditionals = "\\PrintFrontMattertrue\n"
else:
    macros_conditionals = "\\PrintFrontMatterfalse\n"

## Metadata
macros_metadata = METADATA_TEMPLATE.format(**metadata)

## Scores to be printed
if args.type == "draft":
    macros_scores = ""
else:
    macros_scores = PRINT_SCORE_TEMPLATE.format(args.type)



# Save macros -------------------------------------------------------------

with open("front_matter/critical_report.macros", "w") as f:
    f.writelines(macros_conditionals)
    f.writelines(macros_metadata)
    f.writelines(macros_scores)
