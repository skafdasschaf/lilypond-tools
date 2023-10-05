#!/usr/bin/python

import argparse
from datetime import date
from git import Repo
import io
import os
from pandas import json_normalize, read_csv
import re
import segno
import subprocess
import sys
import strictyaml



# General functions and classes -------------------------------------------

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

EES_TOOLS_PATH = os.getenv("EES_TOOLS_PATH")

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

LICENSE_HEADINGS = {
    "cc-by-sa-4.0": "Attribution-ShareAlike 4.0 International",
    "cc-by-nc-sa-4.0": "Attribution-NonCommercial-ShareAlike 4.0 International"
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
\\def\\MetadataEditor{{{editor}}}
\\def\\MetadataScoretype{{{score_type}}}
\\def\\MetadataLicense{{{license}}}
\\def\\MetadataRepository{{{repository}}}
\\def\\MetadataVersion{{{version}}}
\\def\\MetadataDate{{{date}}}
\\def\\MetadataChecksum{{{checksum}}}
\\def\\MetadataLilypondVersion{{{lilypond_version}}}
\\def\\MetadataEESToolsVersion{{{eestools_version}}}
\\def\\MetadataQRCode{{{qr_code}}}
\\def\\MetadataSources{{{sources_env}}}
\\def\\MetadataAbbreviations{{{abbr_env}}}
"""

ADDITIONAL_METADATA_TEMPLATE = "\\def\\Metadata{key}{{{value}}}"

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
  {{{license}}}%
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
\\def\\eesScore{{%
  \\cleardoublepage%
  \\pagenumbering{{arabic}}%
  \\setcounter{{page}}{{1}}%
  \\includepdf[pages=-,link=true,linkname=score]{{{score_dir}/{type}.pdf}}%
}}
"""



# Prepare metadata --------------------------------------------------------

# derive the score type shown on the title page from the score type abbreviation
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


# get the long form of a scoring abbreviation
def get_abbr(a):
    try:
        res = INSTRUMENT_METADATA.loc[a, "long"]
    except KeyError:
        error_exit(f"Abbreviation {a} unknown.")
    return res


def parse_metadata(file=None,
                   string=None,
                   score_type="draft",
                   checksum_from="tag",
                   check_license=True,
                   license_directory=".",
                   qr_base_url=None):
    if file is not None:
        with open(file) as f:
            yaml_data = f.read()
    elif string is not None:
        yaml_data = string
    else:
        error_exit("No metadata specified.")
    metadata = strictyaml.load(yaml_data).data

    ## Names
    # The `composer` key is optional to accomodate collections of works.
    # The `first` subkey is optional to accomodate anonymous works.

    if "composer" not in metadata:
        metadata["composer"] = {"first": "(unknown)", "last": "(unknown)"}
    if "first" not in metadata["composer"]:
        metadata["composer"]["first"] = ""
    if "suffix" not in metadata["composer"]:
        metadata["composer"]["suffix"] = ""

    ## Score type
    # The score type depends on the value of `-t` and is either set to "Draft",
    # "Full Score", or the respective part as specified in the
    # instrument metadata. Can be overridden by the `parts` key.
    # Roman numbers are automatically appended.

    if "parts" not in metadata:
        metadata["parts"] = None
    metadata["score_type"] = get_score_type(score_type, metadata["parts"])

    ## Repository
    # The name of the remote repository "origin" is read from the git metadata,
    # as are the version, date, and SHA1 of HEAD or the most recent tag.
    # In the former case, set version to "work in progress".

    if checksum_from is not None:
        github_repo = re.search("github\\.com.(.+)", Repo(".").remotes.origin.url)
        if github_repo is None:
            error_exit("URL of origin repository has unknown format.")
        metadata["repository"] = github_repo.group(1).removesuffix(".git")

        if checksum_from == "tag":
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
            r"GNU LilyPond ([^\s]+)",
            lilypond_version
        ).group(1)
    except FileNotFoundError:
        metadata["lilypond_version"] = "(not available)"

    ## EES Tools version
    # This version is obtained from the most recent tag of the repository
    # in $EES_TOOLS_PATH.

    metadata["eestools_version"] = Repo(EES_TOOLS_PATH).tags[-1].name

    ## QR Code
    # It will contain a link to the PDF in the current release.

    if score_type == "draft":
        metadata["qr_code"] = ""
    else:
        if qr_base_url is None:
            qr_base_url = (f"https://github.com/{metadata['repository']}/"
                           f"releases/download/{metadata['version']}")
        qr_url = f"{qr_base_url}/{score_type}.pdf"
        qr_buffer = io.StringIO()
        segno.make_qr(qr_url).save(qr_buffer, kind="tex", scale=1.5, url=qr_url)
        metadata["qr_code"] = qr_buffer.getvalue()
        qr_buffer.close()


    ## Sources
    # For each entry in `sources`, add missing date, RISM information
    # and notes, and determine the identifier of the principal source.

    source_items = []
    for id, info in metadata["sources"].items():
        info["category"] = SOURCE_CATEGORIES[id[0]]

        if "date" not in info or info["date"] == "":
            info["date"] = ""

        if "rism" not in info or info["rism"] == "":
            info["rism"] = ""

        if "notes" not in info or info["notes"] == "":
            info["notes"] = ""

        if "url" not in info or info["url"] == "":
            info["url"] = ""

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

    if "id" not in metadata or metadata["id"] == "":
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
    if "extra_abbreviations" in metadata:
        for a, long in metadata["extra_abbreviations"].items():
            if long == "":
                abbr[a] = get_abbr(a)
            else:
                abbr[a] = long

    for a in (metadata["scoring"]
              .replace("\\newline", "")
              .replace("\\\\", "")
              .split(",")):
        a = a.strip(" \n")
        if a[0] == "[":
            a = a[1:-1]
        if a[-1] == ")":
            a = re.match("[^\(]+", a).group(0).strip()
        a = a.lstrip("0123456789 ").removesuffix("solo").rstrip()
        if a not in abbr:
            abbr[a] = get_abbr(a)

    abbr_items = [ABBR_ITEM_TEMPLATE.format(short=k, long=v)
                  for k, v in sorted(abbr.items(), key=lambda x: x[0].lower())]
    metadata["abbr_env"] = ABBR_TEMPLATE.format("\n  ".join(abbr_items))

    ## Editor
    # set a default editor
    if "editor" not in metadata:
        metadata["editor"] = "Wolfgang Esser-Skala"

    ## License
    # Check whether the license key (a) exists, (b) has a known value, and
    # (c) correponds to the LICENSE file (optionally).

    if "license" not in metadata:
        error_exit("Key 'license' missing.")
    if metadata["license"] not in LICENSE_HEADINGS:
        error_exit(f'Unknown license: {metadata["license"]}')

    if check_license:
        try:
            with open(os.path.join(license_directory, "LICENSE")) as f:
                license_heading = f.readline().strip()
        except FileNotFoundError:
            error_exit("No LICENSE file found.")
        if license_heading != LICENSE_HEADINGS[metadata["license"]]:
            error_exit("LICENSE does not match the 'license' key.")

    return metadata



# Dispatcher functions ----------------------------------------------------

def prepare_edition(args):
    metadata = parse_metadata(
        file=args.input,
        score_type=args.type,
        checksum_from=args.checksum_from,
        license_directory=args.license_directory,
        qr_base_url=args.qr_base_url
    )

    # assemble macros
    if args.type in ("draft", "full_score"):
        macros_conditionals = "\\PrintFrontMattertrue\n"
    else:
        macros_conditionals = "\\PrintFrontMatterfalse\n"

    macros_metadata = METADATA_TEMPLATE.format(**metadata)

    macros_additional_keys = "\n".join([
        ADDITIONAL_METADATA_TEMPLATE.format(key=k.title(), value=metadata[k])
        for k in args.additional_keys
        if k in metadata
    ])

    if args.type == "draft":
        macros_scores = ""
    else:
        macros_scores = PRINT_SCORE_TEMPLATE.format(
            type=args.type, score_dir=args.score_directory
        )

    # save macros
    with open(args.output, "w") as f:
        f.writelines(macros_conditionals)
        f.writelines(macros_metadata)
        f.writelines(macros_additional_keys)
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
                metadata = parse_metadata(file=f, check_license=False)
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



# Parse arguments ---------------------------------------------------------

if __name__ == "__main__":
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
        help="""obtain version, date, and checksum from HEAD
                or the most recent tag (default: head)"""
    )
    parser_edition.add_argument(
        "-k",
        "--additional-keys",
        nargs="*",
        default=[],
        help="""process additional KEYS""",
        metavar="KEYS"
    )
    parser_edition.add_argument(
        "-s",
        "--score-directory",
        default="../tmp",
        help="""read included scores from this directory (default: ../tmp)""",
        metavar="DIR"
    )
    parser_edition.add_argument(
        "-l",
        "--license-directory",
        default=".",
        help="""check the LICENSE in this directory (default: current dir)""",
        metavar="DIR"
    )
    parser_edition.add_argument(
        "-q",
        "--qr-base-url",
        default=None,
        help="""download score PDFs from this base URL
                (default: current GitHub release)""",
        metavar="URL"
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

    args = parser.parse_args()
    args.func(args)
