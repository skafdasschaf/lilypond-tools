"""Merge works files to create a collection."""

from os import makedirs
import re
import subprocess
from sys import argv


FRONT_MATTER_TEMPLATE = """\
\\documentclass[tocdir=../../tmp/{name}]{{ees}}

\\begin{{document}}

\\title{{[collection – add custom title page]}}
\\date{{{date}}}
\\license{{{license}}}
\\def\\MetadataLilypondVersion{{{lilypond_version}}}
\\def\\MetadataEESToolsVersion{{{eestools_version}}}
\\repository{{{repository}}}
\\version{{{version}}}
\\checksum{{{checksum}}}
\\def\\MetadataQRCode{{\\relax}}
\\eesTitlePage

\\chapter{{Critical Report}}

In general, this edition closely follows the respective principal source.
Any changes that were introduced by the editor are indicated
by italic type (lyrics, dynamics and directives), parentheses
(expressive marks and bass figures) or dashes (slurs and ties).
Accidentals are used according to modern conventions.
For further details, consult the Editorial Guidelines
available on the Edition’s webpage.

\\section{{Abbreviations}}

\\begin{{abbreviations}}
{abbr}
\\end{{abbreviations}}

{works}

\\eesToc{{}}

\\cleardoublepage%
\\pagenumbering{{arabic}}%
\\setcounter{{page}}{{1}}%
\\includepdf[pages=-,link=true,linkname=score]{{../../tmp/{name}/full_score.pdf}}%

\\end{{document}}
"""

WORK_TEMPLATE = """\
\\section{{{title} · {subtitle}}}

\\begin{{xltabular}}{{\\linewidth}}{{@{{}} >\\itshape l X}}
genre & {genre} \\\\
festival & {festival} \\\\
scoring & {scoring} \\\\
\\end{{xltabular}}
{sources}
{toe}
{lyrics}
"""

TOE_TEMPLATE = """\
\\begin{{xltabular}}{{\\linewidth}}{{ll X}}
\\toprule
\\itshape Bar & \\itshape Staff & \\itshape Description \\\\
\\midrule \\endhead
{}
\\bottomrule
\\end{{xltabular}}
"""

LYRICS_TEMPLATE = "\\textlt{{\\textit{{Lyrics}}\\\\{}}}"

FULL_SCORE_TEMPLATE = """\
\\version "2.24.0"

\\include "../../definitions_main.ly"
\\include "definitions.ly"
\\include "score_settings/full-score.ly"

\\book {{
{}
}}
"""


PYTHON_CALL = """
mkdir -p tmp/{name}
python $EES_TOOLS_PATH/read_metadata.py edition \\
    -i works/{work}/metadata.yaml \\
    -o tmp/{name}/metadata_{work}.macros \\
    -t full_score \\
    -k festival genre lyrics toe \\
    -c tag
"""


def extract_value(metadata: str, key: str) -> str:
    """Extracts the value from a metadata LaTeX macro."""
    value = re.search(
        rf"\\def\\Metadata{key}{{(.*?)}}\n\\def",
        metadata,
        re.DOTALL
    )
    if not value:
        return ""
    return value.group(1)


def get_definitions(work: str) -> list[str]:
    """Extracts info from definitions.ly of a single work"""
    def_file = f"works/{work}/definitions.ly"
    res = [f"\n% from {def_file}\n"]
    with open(def_file, encoding="utf8") as f:
        for line in f:
            if line.startswith("\\version"):
                continue
            if line.startswith("\\include"):
                res.append(
                    line.replace(
                        "notes",
                        f"works/{work}/notes"
                    )
                )
                continue
            res.append(line)
    return res


def extract_paper_variables(match: re.Match | None) -> list[str]:
    """Extract paper variables as list from Match object."""
    if match is None:
        return []
    return ["      " + s.strip()
            for s in match.group(1)
                          .replace("\\", "\\\\")
                          .strip()
                          .split("\n")]


def get_full_score(work: str) -> list[str]:
    """Get the full score of a work."""
    score_file = f"works/{work}/scores/full_score.ly"
    with open(score_file, encoding="utf8") as f:
        score = "".join(f.readlines())

    # get top-level paper variables
    top_level_paper_variables = re.search(
        r"\n\\paper {(.*?)}",
        score,
        re.DOTALL
    )
    top_vars = extract_paper_variables(top_level_paper_variables)

    # reformat bookparts by combining paper variables
    bookparts = re.findall(
        r"  \\bookpart {.*?\n  }\n",
        score,
        re.DOTALL
    )
    bookparts_reformatted: list[str] = []
    for bookpart in bookparts:
        paper_variables = re.search(
            r"\\paper {(.*?)}",
            bookpart,
            re.DOTALL
        )
        paper_vars = extract_paper_variables(paper_variables)
        all_vars = "\n".join(top_vars + paper_vars)

        b = re.sub(
            r"\\addTocEntry.*\\score",
            r"\\addTocEntry\n    \\paper {\n"
                + all_vars
                + r"\n    }\n    \\score",
            bookpart,
            flags=re.DOTALL
        )
        bookparts_reformatted.append(b)

    # TBD: handle top-level \context settings

    return bookparts_reformatted


def main() -> None:
    """Main function."""
    coll_name = argv[1]
    works = argv[2:]

    definitions: list[str] = []
    full_score: list[str] = []
    abbreviations: set[str] = set()
    work_details: list[str] = []

    for work in works:
        # merge definitions
        definitions += get_definitions(work)

        # merge full scores
        full_score += get_full_score(work)

        # generate metadata
        print("Generate metadata for", work)
        subprocess.run(
            PYTHON_CALL.format(name=coll_name, work=work),
            check=False,
            shell=True,
            capture_output=True
        )

        # parse metadata
        with open(f"tmp/{coll_name}/metadata_{work}.macros",
                  encoding="utf8") as f:
            metadata = f.read()

        # add new abbreviations
        abbr = extract_value(metadata, "Abbreviations")
        abbreviations.update(
            [a for a in abbr.replace(" ", "").split("\n")
               if a.startswith("\\abbr")]
        )

        # format selected metadata values
        festival = extract_value(metadata, "Festival")
        if not festival:
            festival = "–"

        toe_contents = extract_value(metadata, "Toe")
        if toe_contents:
            toe = TOE_TEMPLATE.format(toe_contents)
        else:
            toe = ""

        lyrics = extract_value(metadata, "Lyrics")
        if lyrics:
            lyrics = LYRICS_TEMPLATE.format(lyrics)

        # format work information
        work_details.append(
            WORK_TEMPLATE.format(
                title=extract_value(metadata, "Title"),
                subtitle=extract_value(metadata, "Subtitle"),
                genre=extract_value(metadata, "Genre"),
                festival=festival,
                scoring=extract_value(metadata, "Scoring").replace("\\\\", " "),
                sources=extract_value(metadata, "Sources"),
                toe=toe,
                lyrics=lyrics,
            )
        )

    # format front matter
    front_matter = FRONT_MATTER_TEMPLATE.format(
        name=coll_name,
        date=extract_value(metadata, "Date"),
        license=extract_value(metadata, "License"),
        lilypond_version=extract_value(metadata, "LilypondVersion"),
        eestools_version=extract_value(metadata, "EESToolsVersion"),
        repository=extract_value(metadata, "Repository"),
        version=extract_value(metadata, "Version"),
        checksum=extract_value(metadata, "Checksum"),
        abbr="\n".join(sorted(abbreviations)),
        works="\n".join(work_details)
    )

    # save files
    makedirs(f"collections/{coll_name}", exist_ok=True)
    with open(f"collections/{coll_name}/critical_report.tex",
              "w",
              encoding="utf8") as f:
        f.write(front_matter)

    with open(f"collections/{coll_name}/definitions.ly",
              "w",
              encoding="utf8") as f:
        f.write("".join(definitions))

    with open(f"collections/{coll_name}/full_score.ly",
              "w",
              encoding="utf8") as f:
        f.write(FULL_SCORE_TEMPLATE.format("".join(full_score)))


if __name__ == "__main__":
    main()
