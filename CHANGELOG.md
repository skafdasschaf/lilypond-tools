# Changelog

## 2023.02.0

### Added

- generation and release of a zip file `midi_collection.zip` with MIDI files in folder `midi`
- inclusion of `ees_articulate.ly` in `ees-template`


## 2022.12.0

### Breaking changes

None, but you may
- remove `#(define option-init-toc #t)` from `definitions.ly`
- replace `\l` by `_` if no extenders are printed


### Added

- TODO list
- changelog
- `documents/imslp_instructions.md`, which describes how to submit scores to IMSLP
- a folder `utils` with the following scripts:
  - `add_variables.py` (moved here)
  - `download_from_manuscriptorium.sh`: obtains high-resolution images from Manuscriptorium
  - `split_image.sh`: splits double-sided PDFs
- `ees_articulate.ly`, a customized MIDI articulation script
- support for `chords` instrument in `add_variables.py`
- in front matter: EES Tools version used for typesetting (available via `\MetadataEESToolsVersion`)
- in front matter: QR code pointing to the URL of the score PDF (pgf macros, available via `\MetadataQRCode`)
- new commands:
  - `\conSord`, `\conSordE`, `\senzaSord`, and `\senzaSordE` for “con/senza sordino” markup
  - `\markTimeSig` for adding a time signature mark
  - `\tacet` for indicating movements where an instrument pauses
  - `\whOn` and `\whOff` for producing white (void) notation
- snippets:
  - add a tie to the last note (`\extendLV`)
  - add a time signature mark (`\markTimeSig`)
  - adjust overall horizontal spacing (`\tightNotes`)
  - define a multirow short instrument name
  - incipits for solo voice and strings
  - mark deleted parts of a score by gaps across the staves (`\startDeleted` and `\stopDeleted`)
  - show only the numerator of the time signature
- the `zip` command to the `ees-tools` DOcker image
- an argument to customize the QR code base URL (`-q`, `--qr-base-url`) to `parse_metadata.py`


### Changed

- Markdown documents (e.g., editorial guidelines) are now stored in a folder `documents`.
- The table of spacing recommendations now also contains default values.
- `\partCombine` in the template now combines up to a tenth by default.
- `ees-tools` now uses LilyPond v2.24.0, TinyTeX v2022.12, and Python v3.11.
- `parse_metadata.py` now uses strictyaml instead of PyYAML.


### Fixed

- `add_variables` now adds a bass figure variable for instruments `bc`, `bc_realized`, and `fond`.
- `add_variables` now includes `\twofourtime` and `\twotwotime` for time signatures 2/4 and 2/2, respectively.
- Horizontal spacing between choir staff and its instrument name has been improved.
- Custom right-aligned marks are now invisible at the beginning of a line.


### Removed

- the `option-init-toc` Scheme variable, since there was no use case for setting it to false
- the customized bass figure function `new-format-bass-figure`, since LilyPond 2.24.0 greatly improved typesetting of bass figures


## 2022.01.0

### Added

- initial release
