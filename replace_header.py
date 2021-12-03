import argparse
import glob
import os
import re



# Constants ---------------------------------------------------------------

KNOWN_HEADERS = {
    "K Y R I E": "Kyrie",
    "G L O R I A": "Gloria",
    "C R E D O": "Credo",
    "S A N C T U S": "Sanctus",
    "B E N E D I C T U S": "Benedictus",
    "A G N U S   D E I": "Agnus Dei",

    "K Y R I E   E L E I S O N": "Kyrie eleison",
    "P A T E R   D E   C O E L I S": "Pater de cœlis",
    "R O S A   M Y S T I C A": "Rosa mystica",
    "S A L U S   I N F I R M O R U M": "Salus infirmorum",
    "S A N C T A   M A R I A": "Sancta Maria",
    "R E G I N A   A N G E L O R U M": "Regina angelorum",

    "D I X I T   D O M I N U S": "Dixit Dominus",
    "C O N F I T E B O R": "Confitebor",
    "B E A T U S   V I R": "Beatus vir",
    "D E   P R O F U N D I S": "De profundis",
    "M E M E N T O,   D O M I N E,   D A V I D": "Memento, Domine, David",
    "S A L V E T E,   F L O R E S   M A R T Y R U M": "Salvete, flores martyrum",
    "M A G N I F I C A T": "Magnificat"
}

OLD_HEADERS = {
    "number": r'\\header {\n\s*number = "(?P<number>.+?)"\n\s*}',
    "number-section": r'\\header {\n\s*number = "(?P<number>\d+)"\n\s*title = "(?P<title>.+?)"\n\s*}',
    "section": r'\\header {\n\s*title = "(?P<title>.+?)"\n\s*}'
}

NEW_HEADERS = {
    "number": '\\section "{number}" ""\n    \\addTocEntry',
    "number-section": '\\section "{number}" "{title_new}"\n    \\addTocEntry',
    "section": '\\section "{title_new}"\n    \\addTocEntry'
}



# Arguments ---------------------------------------------------------------

parser = argparse.ArgumentParser()
parser.add_argument("type")
parser.add_argument("titles", nargs="*", default=None)
args = parser.parse_args()

if args.titles:
    if len(args.titles) % 2 != 0:
        print("ERROR: Wrong number of titles specified.")
        exit()
    for i in range(0, len(args.titles), 2):
        KNOWN_HEADERS[args.titles[i]] = args.titles[i+1]

print("Known substitutions:")
for k, v in KNOWN_HEADERS.items():
    print(f"'{k}' -> '{v}'")



# Title substitution ------------------------------------------------------

old_header = re.compile(OLD_HEADERS[args.type])

def replace_headers(doc):
    match = old_header.search(doc)
    if match is None:
        return doc

    if args.type == "number":
        print(f"Replacing old number '{match.group('number')}'")
        new_header = NEW_HEADERS[args.type].format(**match.groupdict())
    else:
        title_new = KNOWN_HEADERS.get(match.group("title"))
        if title_new is None:
            print(f"Warning: Skipping unknown old header '{match.group('title')}'.")
            new_header = match.group(0)
        else:
            print(f"Replacing old title '{match.group('title')}'")
            new_header = NEW_HEADERS[args.type].format(title_new=title_new, **match.groupdict())

    doc_before = doc[:match.start()]
    doc_after = doc[match.end():]
    return doc_before + new_header + replace_headers(doc_after)


# for score in ["scores/b.ly"]:
for score in glob.glob("scores/*.ly"):
    with open(score) as f:
        doc = f.read()

    doc = replace_headers(doc)

    with open(score, "w") as f:
        f.write(doc)
