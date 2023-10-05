#!/bin/python

"""Parse LilyPond and LaTeX logs to look for warnings."""

import argparse
import glob
import re
from termcolor import cprint
from texoutparse import LatexLogParser


parser = argparse.ArgumentParser(
    description="Check LaTeX and LilyPond log files for errors/warnings."
)
parser.add_argument(
    "dir",
    nargs="?",
    default="tmp",
    help="search this directory"
)
args = parser.parse_args()


cprint(
  "LaTeX files ---------------------------------------------------------------",
  attrs=["bold"]
)

parser = LatexLogParser()
tex_errors_found = False
for tex_logs in glob.glob(f"{args.dir}/*.tex.log"):
    with open(tex_logs, encoding="utf8") as f:
        parser.process(f)

    if len(parser.errors) + len(parser.warnings) + len(parser.badboxes) > 0:
        cprint(f"File: {tex_logs}", attrs=["underline"])
        tex_errors_found = True
        for e in parser.errors:
            cprint(e, "red")
        for w in parser.warnings:
            cprint(w, "yellow")
        for b in parser.badboxes:
            cprint(b, "cyan")
if not tex_errors_found:
    cprint("No problems detected! :)", "green")

cprint(
  "LilyPond files ------------------------------------------------------------",
  attrs=["bold"]
)

LILYPOND_MESSAGE_TEMPLATE = """
{type} on line {line}, col {col}: {message}
{context_line_1}
{context_line_2}
"""

re_warning_error = re.compile("([^:]+):([^:]+):([^:]+):([^:]+):(.+)")
re_other_warning = re.compile("$warning:|Warnung:")

ly_errors_found = False
for ly_logs in glob.glob(f"{args.dir}/*.ly.log"):
    with open(ly_logs, encoding="utf8") as f:
        lines = list(f.readlines())

    messages = []
    for line_no, line in enumerate(lines):
        message = re_warning_error.match(line)
        if message:
            message_type = message.group(4).strip()
            if message_type in ["Fehler", "Error"]:
                color = "red"
            elif message_type in ["Warnung", "Warning"]:
                color = "yellow"
            else:
                color = "cyan"
            messages.append(
                dict(
                    line=message.group(2),
                    col=message.group(3),
                    type=message_type,
                    message=message.group(5).strip(),
                    context_line_1=lines[line_no + 1].strip("\n"),
                    context_line_2=lines[line_no + 2].strip("\n"),
                    color=color
                )
            )
        message = re_other_warning.match(line)
        if message:
            if line.count("MIDI") + line.count("modulo") == 0:
                messages.append(line)

    if messages:
        cprint(f"File: {ly_logs}", attrs=["underline"])
        ly_errors_found = True
        for m in messages:
            try:
                cprint(LILYPOND_MESSAGE_TEMPLATE.format(**m), m["color"])
            except TypeError:
                cprint(m, "yellow")

if not ly_errors_found:
    cprint("No problems detected! :)", "green")
