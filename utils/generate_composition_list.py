"""Convert ODS file to IMSLP COmposer Composition List"""

import re
from typing import Union
import pandas as pd


PAGE_HEADER = """\
{{worklist|Haydn, Michael}}

{{Bluebox|'''Note''': This page is currently under construction, as more and more works are added. Last change on 2023-12-22.}}

The table below gives the following information (where applicable):
* '''MH''' — numbering as given in Charles H. Sherman and T. Donley Thomas, Johann Michael Haydn (1737–1806). A Chronological Thematic Catalogue of His Works (Stuyvesant, New York, 1993).
* '''Title''' — as used on IMSLP.
* '''Key''' — the principal key of the work.
* '''Date''' — the year(s) of composition or arrangement, where known.
* '''Genre''' — as used by IMSLP's categorization system.
* '''Scoring''' — the instrumentation used.
* '''Notes''' — concerning related works, completeness, authorship, etc.

{| class="sortable wikitable" style="font-size:95%; width: 98%; vertical-align: top; border: 1px solid #AAA"
! width="6%"|MH
! width="35%"|Title
! width="6%"|Key
! width="10%"|Date
! width="6%"|Genre
! width="37%"|Notes
|-"""

TABLE_ROW_TEMPLATE = """
| {mh}
| {title}
| {key}
| {date}
| {genre}
| {notes}
"""

PAGE_FOOTER = """\
|}
"""


def format_catalogue_number(n: int) -> str:
    """Formats the MH number with leading zeros."""
    if n < 10:
        return f"{{{{Hs|00}}}}{n}"
    if n < 100:
        return f"{{{{Hs|0}}}}{n}"
    return f"{n}"


def format_title(title_imslp: str, title: str) -> str:
    """Adds a link to the work page (if available)."""
    if pd.isna(title_imslp):
        return title
    return f"{{{{LinkWorkN|{title_imslp}||Haydn|Michael|0}}}}"


def format_key(key: str) -> str:
    """Converts sharps and flats."""
    key = re.sub(r"-flat", "{{flat}}", key)
    key = re.sub(r"-sharp", "{{sharp}}", key)
    return key

def format_date(date: Union[str, pd.Timestamp]) -> str:
    """Formats the date in ISO 8601 format."""
    if isinstance(date, pd.Timestamp):
        return date.strftime("%Y-%m-%d")
    return date


works = pd.read_excel(
    "/home/wolfgang/Desktop/Tools/misc-analyses/haydn/data/mh.ods",
    engine="odf",
    nrows=50
)

table_rows = [
    TABLE_ROW_TEMPLATE.format(
        mh=format_catalogue_number(work.mh),
        title=format_title(work.title_imslp, work.title),
        key=format_key(work.key),
        date=format_date(work.date),
        genre=work.genre_imslp,
        notes=""
    )
    for work in works.itertuples()
]

with open("/home/wolfgang/Desktop/imslp_source.txt", "w", encoding="utf8") as f:
    f.write(PAGE_HEADER)
    f.write("|-".join(table_rows))
    f.write(PAGE_FOOTER)
