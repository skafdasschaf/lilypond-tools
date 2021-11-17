#!/usr/bin/python

import argparse
from datetime import date
from git import Repo
import os
from pandas import json_normalize, read_csv
import re
import subprocess
import sys
import yaml



# General functions and classes -------------------------------------------

# ensure that metadata.yaml contains no duplicate keys
# after https://stackoverflow.com/questions/33490870
class UniqueKeyLoader(yaml.SafeLoader):
    def construct_mapping(self, node, deep=False):
        mapping = []
        for key_node, value_node in node.value:
            key = self.construct_object(key_node, deep=deep)
            if key in mapping:
                error_exit("Duplicate YAML keys detected.")
            mapping.append(key)
        return super().construct_mapping(node, deep)


# if an exception is caught, print an error message and exit gracefully
def error_exit(msg):
    print(f"ERROR: {msg}")
    sys.exit(1)

# convert an Arabic number to a Roman numeral
def arabic_to_roman(number=None):
    conv = [[1000, "M"], [900, "CM"], [500, "D"], [400, "CD"],
            [ 100, "C"], [ 90, "XC"], [ 50, "L"], [ 40, "XL"],
            [  10, "X"], [  9, "IX"], [  5, "V"], [  4, "IV"],
            [   1, "I"]]

    if number is None or number == "":
        return ""
    else:
        number = int(number)

    result = ""
    for denom, roman_digit in conv:
        result += roman_digit * (number // denom)
        number %= denom
    return result



# Constants ---------------------------------------------------------------

instrument_data_file = os.path.join(
    os.path.dirname(os.path.realpath(__file__)),
    "instrument_data.csv"
)
INSTRUMENT_METADATA = read_csv(instrument_data_file).set_index("abbreviation")

# abbreviations included in each edition
DEFAULT_ABBR = {}

# description of source categories
SOURCE_CATEGORIES = {
    "A": "autograph manuscript",
    "B": "manuscript copy",
    "C": "print",
    "D": "manuscript not used for this edition",
    "E": "print not used for this edition"
}

# subfolders ignored when preparing the table
IGNORED_COMPOSER_DIRS = ["Misc", "TODO"]

# metadata keys that are excluded from the generated table
INCLUDED_COLUMNS = ["composer_last", "composer_suffix", "composer_first",
                    "title", "id", "genre", "scoring", "sources", "imslp",
                    "repository", "version", "date", "folder", "notes"]


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
\\def\\MetadataChecksum{{{checksum}}}
\\def\\MetadataLilypondVersion{{{lilypond_version}}}
\\def\\MetadataSources{{{sources_env}}}
\\def\\MetadataAbbreviations{{{abbr_env}}}
"""

SUBTITLE_TEMPLATE = "{}\\newline {}"

PRINCIPAL_SRC_TEMPLATE = "{} (principal source)"

PRINCIPAL_ID_TEMPLATE = "({} {})"

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
  {{{category}}}%
  {{{date}}}%
  {{{rism}}}%
  {{{url}}}%
  {{{notes}}}
"""

ABBR_TEMPLATE = """
\\begin{{abbreviations}}
  {}
\\end{{abbreviations}}
"""

ABBR_ITEM_TEMPLATE = "\\abbr{{{short}}}{{{long}}}"

PRINT_SCORE_TEMPLATE = """
\\def\\eesScore{{\\cleardoublepage\\includepdf[pages=-]{{../tmp/{}.pdf}}}}
"""



# Prepare metadata --------------------------------------------------------

def get_score_type(abbr, parts):
    if abbr == "draft":
        return "Draft"

    if abbr == "full_score":
        return "Full score"

    if parts and abbr in parts:
        return parts[abbr]

    try:
        abbr_bare, number = re.match("(\D+)(\d*)", abbr).groups()
        name = INSTRUMENT_METADATA.loc[abbr_bare, "score_type"]
        number = arabic_to_roman(number)
        return f"{name} {number}".strip()
    except (KeyError, AttributeError):
        error_exit(f"No long form for {abbr} defined")


def read_metadata(metadata_file, score_type="draft"):
    with open(metadata_file) as f:
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
    # "Full Score", or the respective part as specified in the
    # instrument metadata. Can be overridden by the `parts` key.
    # Roman numbers are automatically appended.

    metadata["score_type"] = get_score_type(score_type, metadata["parts"])

    ## Repository
    # The name of the remote repository "origin" is read from the git metadata,
    # as are the version, date, and SHA1 of HEAD or the most recent tag.
    # In the former case, set version to "work in progress".

    github_repo = re.search("github\\.com.(.+)", Repo(".").remotes.origin.url)
    if github_repo is None:
        error_exit("URL of origin repository has unknown format.")
    metadata["repository"] = github_repo.group(1).removesuffix(".git")

    if args.checksum_from == "tag":
        if Repo(".").tags:
            metadata["version"] = Repo(".").tags[-1].name
            commit = Repo(".").tags[-1].commit
        else:
            error_exit("ERROR: No tag found – unable to retrieve metadata.")
    else:
        metadata["version"] = "work in progress"
        commit = Repo(".").head.commit
    metadata["date"] = commit.committed_datetime.strftime("%Y-%m-%d")
    metadata["checksum"] = commit.hexsha

    ## LilyPond version
    # The LilyPond version is obtained from the executable.
    # If LilyPond is not installed, display an appropriate string.

    try:
        lilypond_version = subprocess.run(
            ["lilypond", "--version"],
            capture_output=True,
            text=True
        ).stdout
        metadata["lilypond_version"] = re.search(
            "GNU LilyPond (.+)\n",
            lilypond_version
        ).group(1)
    except FileNotFoundError:
        metadata["lilypond_version"] = "(not available)"

    ## Sources
    # For each entry in `sources`, add missing date, RISM information
    # and notes, and determine the identifier of the principal source.

    source_items = []
    for id, info in metadata["sources"].items():
        info["category"] = SOURCE_CATEGORIES[id[0]]

        if "date" not in info or info["date"] is None:
            info["date"] = "unknown"

        if "rism" not in info or info["rism"] is None:
            info["rism"] = "not available"

        if "notes" not in info or info["notes"] is None:
            info["notes"] = ""

        if "url" not in info or info["url"] is None:
            info["url"] = "none"

        if "principal" in info and info["principal"]:
            if "principal_id" in metadata:
                error_exit("Exactly one source must be marked as principal.")
            info["category"] = PRINCIPAL_SRC_TEMPLATE.format(info["category"])
            metadata["principal_id"] = PRINCIPAL_ID_TEMPLATE.format(
                info["siglum"], info["shelfmark"]
            )

        source_items.append(SOURCE_ITEM_TEMPLATE.format(id=id, **info))

    metadata["sources_env"] = SOURCES_TEMPLATE.format("\n".join(source_items))

    ## Subtitle
    # The subtitle consists of the value of the `subtitle` key (if available)
    # and the catalogue of works id, separated by a newline. If the latter id
    # is not specified, the principal source identifier is used.

    if "principal_id" not in metadata:
        error_exit("No principal source specified.")

    if "id" not in metadata or metadata["id"] is None:
        metadata["id"] = metadata["principal_id"]

    if "subtitle" not in metadata:
        metadata["subtitle"] = metadata["id"]
    else:
        metadata["subtitle"] = SUBTITLE_TEMPLATE.format(
            metadata["subtitle"], metadata["id"]
        )

    ## Abbreviations
    # Abbreviations comprise the DEFAULT_ABBR and the instrument
    # abbreviations found in the `scoring` key. Since each individual
    # instrument may be surrounded by brackets or end with the pitch
    # in parentheses, these elements are removed.

    abbr = DEFAULT_ABBR
    for a in metadata["scoring"].replace("\\newline", "").split(","):
        a = a.strip(" \n")
        if a[0] == "[":
            a = a[1:-1]
        if a[-1] == ")":
            a = re.match("[^\(]+", a).group(0).strip()
        a = a.lstrip("0123456789 ").removesuffix("solo").rstrip()
        try:
            abbr[a] = INSTRUMENT_METADATA.loc[a, "long"]
        except KeyError:
            error_exit(f"Abbreviation {a} unknown.")

    abbr_items = [ABBR_ITEM_TEMPLATE.format(short=k, long=v)
                  for k, v in sorted(abbr.items(), key=lambda x: x[0].lower())]
    metadata["abbr_env"] = ABBR_TEMPLATE.format("\n  ".join(abbr_items))

    return metadata



# Dispatcher functions ----------------------------------------------------

def prepare_edition(args):
    metadata = read_metadata(args.input, args.type)

    # assemble macros
    if args.type in ("draft", "full_score"):
        macros_conditionals = "\\PrintFrontMattertrue\n"
    else:
        macros_conditionals = "\\PrintFrontMatterfalse\n"

    macros_metadata = METADATA_TEMPLATE.format(**metadata)

    if args.type == "draft":
        macros_scores = ""
    else:
        macros_scores = PRINT_SCORE_TEMPLATE.format(args.type)

    # save macros
    with open(args.output, "w") as f:
        f.writelines(macros_conditionals)
        f.writelines(macros_metadata)
        f.writelines(macros_scores)


def format_table_sources(sources):
    res = []
    for id, details in sources.items():
        if "principal" in details and details["principal"]:
            p = ", principal"
        else:
            p = ""
        res.append(f"{id} ({details['siglum']} {details['shelfmark']}{p})")
    return "".join(res)


def prepare_table(args):
    # read metadata files
    works = []
    for composer_dir in os.listdir(args.root_directory):
        full_composer_dir = os.path.join(args.root_directory, composer_dir)
        if (not os.path.isdir(full_composer_dir) or
            composer_dir in IGNORED_COMPOSER_DIRS):
            continue
        for work_dir in os.listdir(full_composer_dir):
            full_work_dir = os.path.join(full_composer_dir, work_dir)
            if not os.path.isdir(full_work_dir):
                continue
            try:
                f = os.path.join(full_work_dir, "metadata.yaml")
                metadata = read_metadata(f)
            except FileNotFoundError:
                print("WARNING: No metadata found in", full_work_dir)
                continue
            metadata["folder"] = full_work_dir
            metadata["sources"] = format_table_sources(metadata["sources"])
            works.append(metadata)


    # normalize and save as CSV
    df = (json_normalize(works, sep="_")
          .sort_values(["composer_last", "title"]))
    df[INCLUDED_COLUMNS].to_csv(args.output, index=False)


def prepare_website(args):
    raise NotImplementedError()



# Parse arguments ---------------------------------------------------------

parser = argparse.ArgumentParser(add_help=True)
subparsers = parser.add_subparsers(
    title="subcommands",
    help="additional help available for each subcommand",
    required=True
)

parser_edition = subparsers.add_parser("edition")
parser_edition.add_argument(
    "-i",
    "--input",
    default="metadata.yaml",
    help="read metadata from FILE (default: 'metadata.yaml')",
    metavar="FILE"
)
parser_edition.add_argument(
    "-o",
    "--output",
    default="front_matter/critical_report.macros",
    help="""write the macros to FILE
            (default: 'front_matter/critical_report.macros')""",
    metavar="FILE"
)
parser_edition.add_argument(
    "-t",
    "--type",
    default="draft",
    help="""select score TYPE for front matter
            ('full_score', 'draft', or part name;
            default: 'draft')"""
)
parser_edition.add_argument(
    "-c",
    "--checksum-from",
    choices=["head", "tag"],
    default="head",
    help="""obtain version, date, and checksum from HEAD or the most recent tag
            (default: head)"""
)
parser_edition.set_defaults(func=prepare_edition)

parser_table = subparsers.add_parser("table")
parser_table.add_argument(
    "-d",
    "--root-directory",
    default=".",
    help="""read metadata from all repositories in ROOT,
            assuming the folder structure root -> composer -> repository
            (default: current folder)""",
    metavar="ROOT"
)
parser_table.add_argument(
    "-o",
    "--output",
    default="works.csv",
    help="write the table to FILE (default: 'works.csv')",
    metavar="FILE"
)
parser_table.set_defaults(func=prepare_table)

parser_website = subparsers.add_parser("website")
parser_website.set_defaults(func=prepare_website)

args = parser.parse_args()
args.func(args)
