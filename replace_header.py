import argparse
import glob
import os
import re



# Constants ---------------------------------------------------------------

KNOWN_HEADERS = {
    "K Y R I E": "Kyrie",
    "C H R I S T E": "Christe",
    "C H R I S T E   E L E I S O N": "Christe",
    "G L O R I A": "Gloria",
    "L A U D A M U S   T E": "Laudamus te",
    "G R A T I A S   A G I M U S   T I B I": "Gratias agimus tibi",
    "D O M I N E   D E U S": "Domine Deus",
    "Q U I   T O L L I S": "Qui tollis",
    "Q U O N I A M": "Quoniam",
    "Q U O N I A M   T U   S O L U S   S A N C T U S": "Quoniam",
    "C U M   S A N C T O   S P I R I T U": "Cum Sancto Spiritu",
    "C R E D O": "Credo",
    "E T   I N C A R N A T U S   E S T": "Et incarnatus est",
    "C R U C I F I X U S": "Crucifixus",
    "E T   R E S U R R E X I T": "Et resurrexit",
    "E T   I N   S P I R I T U M   S A N C T U M": "Et in Spiritum Sanctum",
    "E T   V I T A M": "Et vitam",
    "S A N C T U S": "Sanctus",
    "P L E N I   S U N T   C O E L I": "Pleni sunt cœli",
    "O S A N N A": "Osanna",
    "B E N E D I C T U S": "Benedictus",
    "A G N U S   D E I": "Agnus Dei",
    "D O N A   N O B I S   P A C E M": "Dona nobis pacem",
    "D O N A   N O B I S": "Dona nobis pacem",

    "K Y R I E   E L E I S O N": "Kyrie eleison",
    "P A T E R   D E   C O E L I S": "Pater de cœlis",
    "R O S A   M Y S T I C A": "Rosa mystica",
    "S P E C U L U M   I U S T I T I A E": "Speculum iustitiæ",
    "S A L U S   I N F I R M O R U M": "Salus infirmorum",
    "S A N C T A   M A R I A": "Sancta Maria",
    "R E G I N A   A N G E L O R U M": "Regina Angelorum",

    "D I X I T   D O M I N U S": "Dixit Dominus",
    "C O N F I T E B O R": "Confitebor",
    "B E A T U S   V I R": "Beatus vir",
    "D E   P R O F U N D I S": "De profundis",
    "M E M E N T O,   D O M I N E,   D A V I D": "Memento, Domine, David",
    "S A L V E T E,   F L O R E S   M A R T Y R U M": "Salvete, flores martyrum",
    "M A G N I F I C A T": "Magnificat",

    "I N T R O I T U S": "Introitus",
    "T E   D E C E T   H Y M N U S": "Te decet hymnus",
    "R E Q U I E M   –   K Y R I E": "Requiem – Kyrie",
    "S E Q U E N T I A": "Sequentia",
    "T U B A   M I R U M": "Tuba mirum",
    "R E X   T R E M E N D Æ": "Rex tremendæ",
    "R E C O R D A R E": "Recordare",
    "C O N F U T A T I S": "Confutatis",
    "H U I C   E R G O": "Huic ergo",

    "M I S E R E R E": "Miserere",
    "Q U O N I A M   I N I Q U I T A T E M": "Quoniam iniquitatem",
    "T I B I   S O L I   P E C C A V I": "Tibi soli peccavi",
    "A V E R T E   F A C I E M   T U A M": "Averte faciem tuam",
    "R E D D E   M I H I   L A E T I T I A M": "Redde mihi lætitiam",
    "Q U O N I A M   S I   V O L U I S S E S": "Quoniam si voluisses",
    "B E N I G N E   F A C": "Benigne fac",
    "G L O R I A   P A T R I": "Gloria Patri",
    "O F F E R T O R I U M": "Offertorium",
    "C U M   S A N C T I S   T U I S": "Cum Sanctis Tuis",

    "A C C O M P A G N A T O": "Accompagnato",
    "A C C O M P A G N A T O   /   C O R O": "Accompagnato, Coro",
    "A R I A": "Aria",
    "A R I O S O": "Arioso",
    "C H O R A L": "Choral",
    "C O R O": "Coro",
    "D U E T T O": "Duetto",
    "Q U A R T E T T O": "Quartetto",
    "R E C I T A T I V O": "Recitativo",
    "S C H L U S S C H O R A L": "Schlußchoral",
    "T E R Z E T T O": "Terzetto"
}

OLD_HEADERS = {
    "number": r'\\header {\n\s*number = "(?P<number>.+?)"\n\s*}',
    "number-section": r'\\header {\n\s*number = "(?P<number>\d+)"\n\s*title = "(?P<title>.+?)"\n\s*}',
    "section": r'\\header {\n\s*title = "(?P<title>.+?)"\n\s*}',
    "subsection": r'\\header {\n\s*subtitle = "(?P<title>.+?)"\n\s*}',
    "grt": r'\\header {\n\s*genre = "(?P<genre>.+)"\n\s*number = "(?P<number>.+)"\n\s*title = "(?P<title>.+?)"\n\s*}'
}

NEW_HEADERS = {
    "number": '\\section "{number}" ""\n    \\addTocEntry',
    "number-section": '\\section "{number}" "{title_new}"\n    \\addTocEntry',
    "section": '\\section "{title_new}"\n    \\addTocEntry',
    "subsection": '\\subsection "{title_new}"\n    \\addTocEntry',
    "grt": '\\section "{number}" "{genre_new}" "{title}"\n    \\addTocEntry'
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
    elif args.type == "grt":
        genre_new = KNOWN_HEADERS.get(match.group("genre"))
        if genre_new is None:
            print(f"Warning: Skipping unknown old genre '{match.group('genre')}'.")
            new_header = match.group(0)
        else:
            print(f"Replacing old genre '{match.group('genre')}'")
            new_header = NEW_HEADERS[args.type].format(genre_new=genre_new, **match.groupdict())
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


# for score in ["scores/fag1.ly"]:
for score in glob.glob("scores/*.ly"):
    with open(score) as f:
        doc = f.read()

    doc = replace_headers(doc)

    with open(score, "w") as f:
        f.write(doc)
