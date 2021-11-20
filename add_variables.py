#!/bin/python

import argparse
import logging
import os
import re

import numpy as np
import pandas as pd

logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s [%(asctime)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)


# Patterns and templates ----

note_pattern = re.compile(r"([A-Za-z]+)(\d?)")
key_pattern = re.compile(r"([A-Za-z]+)_?([a-z]*)")

DOCUMENT_PREAMBLE = """\
\\version "2.22.0"
"""

INSTRUMENT_TEMPLATE = """
{movement}{instrument} = {{
  \\relative {relative} {{
    \\clef {clef}
    \\key {key} \\time {time} {autobeam}\\tempo{movement}
    {flags}
  }}
}}
"""

LYRICS_TEMPLATE = """
{movement}{instrument}Lyrics = \\lyricmode {{

}}
"""

FIGURES_TEMPLATE = """
{movement}BassFigures = \\figuremode {{

}}
"""



# Create parser ----

parser = argparse.ArgumentParser(
    description="Add instrument variables to LilyPond files."
)
parser.add_argument(
    "-m",
    "--movement",
    help="add this movement",
    required=True
)
parser.add_argument(
    "-n",
    "--notes",
    help="""add the movement to these instruments
            (default: all instruments in folder notes/)""",
    nargs="*",
    default="ALL"
)
parser.add_argument(
    "-k",
    "--key",
    help="""key signature (default: C major).
            Examples: C -> c \\major,
                      d -> d \\minor,
                      d_dorian -> d \\dorian""",
    default="C"
)
parser.add_argument(
    "-t",
    "--time",
    help="time signature (default: 4/4)",
    default="4/4"
)
parser.add_argument(
    "-p",
    "--partial",
    help="duration of upbeat (default: no upbeat)",
    default=False
)
parser.add_argument(
    "-b",
    "--current-bar",
    help="start movement with this bar number (default: 1)",
    default=False
)
parser.add_argument(
    "-f",
    "--force-file-creation",
    help="""create missing files (default: false)""",
    action="store_true"
)

args = parser.parse_args()



# Functions ----

def arabic_to_roman(number=None):
    """Converts an arabic number to a Roman numeral."""
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


def make_key_signature(k):
    """Converts a key signature abbreviation
    to the corresponding LilyPond string."""
    key, mode = key_pattern.match(k).groups()
    if mode == "":
        if key[0].isupper():
            key = key.lower()
            mode = "major"
        else:
            mode = "minor"

    return f"{key} \\{mode}"



# Add movements ----

os.makedirs("notes", exist_ok=True)

metadata_file = os.path.join(
    os.path.dirname(os.path.realpath(__file__)),
    "instrument_data.csv"
)
instrument_data = pd.read_csv(metadata_file).set_index("abbreviation")

available_notes = sorted([os.path.splitext(f)[0] for f in os.listdir("notes")])
if args.notes == "ALL":
    args.notes = available_notes


for instrument in args.notes:
    abbr, id = note_pattern.match(instrument).groups()

    try:
        instrument_long = instrument_data.loc[abbr, 'long']
    except KeyError:
        logging.warning(f"Ignoring unknown instrument '{instrument}'.")
        continue

    if instrument_data.loc[abbr, "default_key"] == "none":
        key = args.key
    else:
        key = instrument_data.loc[abbr, "default_key"]

    flags = []
    if args.current_bar:
        flags.append(f"  \\set Score.currentBarNumber = #{args.current_bar}")
    if args.partial:
        flags.append(f"\\partial {args.partial}")

    keys = dict(
        movement=args.movement,
        instrument=f"{instrument_long}{arabic_to_roman(id)}",
        relative=instrument_data.loc[abbr, "relative"],
        clef=instrument_data.loc[abbr, "clef"],
        key=make_key_signature(key),
        time=args.time,
        autobeam="\\autoBeamOff "
                 if not instrument_data.loc[abbr, "autobeam"]
                 else "",
        flags="\n    ".join(flags)
    )

    if instrument not in available_notes:
        if args.force_file_creation:
            with open(os.path.join("notes", f"{instrument}.ly"), "w") as f:
                f.write(DOCUMENT_PREAMBLE)
            logging.info(f"Successfully created '{instrument}'.")
        else:
            logging.warning(
                f"Ignoring unknown file for instrument '{instrument}'."
            )
            continue

    with open(os.path.join("notes", f"{instrument}.ly"), "a+") as f:
        f.write(INSTRUMENT_TEMPLATE.format(**keys))
        if instrument_data.loc[abbr, "second_template"] == "lyrics":
            f.write(LYRICS_TEMPLATE.format(**keys))
        elif instrument_data.loc[abbr, "second_template"] == "figures":
            f.write(FIGURES_TEMPLATE.format(**keys))

    logging.info(f"Successfully updated '{instrument}'.")
