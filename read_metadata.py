#!/usr/bin/python

import argparse
from datetime import date
from git import Repo
import os
import re
import subprocess
import yaml


# ensure that metadata.yaml contains no duplicate keys
# after https://stackoverflow.com/questions/33490870
class UniqueKeyLoader(yaml.SafeLoader):
    def construct_mapping(self, node, deep=False):
        mapping = []
        for key_node, value_node in node.value:
            key = self.construct_object(key_node, deep=deep)
            if key in mapping:
                raise KeyError("Duplicate YAML keys detected.")
            mapping.append(key)
        return super().construct_mapping(node, deep)



# Constants ---------------------------------------------------------------

DEFAULT_ABBREVIATIONS = {
    "Ms": "manuscript",
    "r": "rest"
}

ABBR_INFO = {
    "fl": "flute",
    "cnto": "cornett",
    "ob": "oboe",
    "ob d'amore": "oboe d'amore",
    "ob da caccia": "oboe da caccia",
    "cl": "clarinet",
    "chalumeau": "chalumeau",
    "fag": "bassoon",
    "cor": "horn",
    "cor da caccia": "corno da caccia",
    "clno": "clarion",
    "tr": "trumpet",
    "trb": "trombone",
    "a-trb": "alto trombone",
    "t-trb": "tenor trombone",
    "b-trb": "bass trombone",
    "timp": "timpani",
    "vl": "violin",
    "vla": "viola",
    "vla da gamba": "viola da gamba",
    "vlc": "violoncello",
    "vlne": "violone",
    "cb": "contrabass",
    "S": "soprano",
    "A": "alto",
    "T": "tenor",
    "B": "bass",
    "org": "organ",
    "cemb": "cembalo",
    "pf": "piano",
    "b": "basses",
    "bc": "basso continuo"
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
\\def\\MetadataFirstname{{{composer[first]}}}
\\def\\MetadataLastname{{{composer[last]}}}
\\def\\MetadataNamesuffix{{{composer[suffix]}}}
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
    metadata = yaml.load(f, Loader=UniqueKeyLoader)


## Names

# The `composer` key is required. If the value is a single string,
# it will be split into first and last name.

if isinstance(metadata["composer"], dict):
    if "suffix" not in metadata["composer"]:
        metadata["composer"]["suffix"] = ""
else:
    last_name, first_name = metadata["composer"].split(", ")
    metadata["composer"] = dict(first=first_name, last=last_name, suffix="")


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
# as are the version and date of the most recent tag. If there are no tags,
# use the current date and set version to "work in progress".

github_repo = re.search("github\\.com.(.+)", Repo(".").remotes.origin.url)
if github_repo is None:
    raise ValueError("URL of origin repository has unknown format.")
metadata["repository"] = github_repo.group(1).removesuffix(".git")

if Repo(".").tags:
    metadata["version"] = Repo(".").tags[-1].name
    metadata["date"] = Repo(".").tags[-1].commit.committed_datetime.strftime("%Y-%m-%d")
else:
    metadata["version"] = "work in progress"
    metadata["date"] = date.today().strftime("%Y-%m-%d")


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

# For each entry in `sources`, add missing date, RISM information and notes,
# and determine the identifier of the primary source

source_items = []
for id, info in metadata["sources"].items():
    info["type"] = SOURCE_TYPES[id[0]]

    if "date" not in info or info["date"] is None:
        info["date"] = "unknown"

    if "rism" not in info or info["rism"] is None:
        info["rism"] = "not available"

    if "notes" not in info or info["notes"] is None:
        info["notes"] = ""

    if "url" not in info or info["url"] is None:
        info["url"] = "none"

    if "primary" in info and info["primary"]:
        if "primary_id" in metadata:
            raise KeyError("Exactly one source must be marked as primary.")
        info["type"] = PRIMARY_SOURCE_TEMPLATE.format(info["type"])
        metadata["primary_id"] = PRIMARY_ID_TEMPLATE.format(info["siglum"],
                                                            info["shelfmark"])

    source_items.append(SOURCE_ITEM_TEMPLATE.format(id=id, **info))

metadata["sources_formatted"] = SOURCES_TEMPLATE.format("\n".join(source_items))


## Subtitle

# The subtitle consists of the value of the `subtitle` key (if available)
# and the catalogue of works id, separated by a newline. If the latter id
# is not specified, the primary source identifier is used.

if "primary_id" not in metadata:
    raise KeyError("No primary source specified.")

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
    a = a.lstrip("0123456789 ").removesuffix("solo").rstrip()
    try:
        abbreviations[a] = ABBR_INFO[a]
    except KeyError:
        raise ValueError(f"Abbreviation {a} unknown.")

metadata["abbreviations"] = ABBREVIATIONS_TEMPLATE.format(
    "\n  ".join(
        [ABBREVIATIONS_ITEM_TEMPLATE.format(short=k, long=v)
         for k, v in sorted(abbreviations.items(), key=lambda x: x[0].lower())]
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
