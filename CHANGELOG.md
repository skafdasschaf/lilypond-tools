# Changelog

## unreleased

### Added

- a TODO list
- a changelog
- `documents/imslp_instructions.md`, which describes how to submit scores to IMSLP
- a folder `utils` with the following scripts:
  - `download_from_manuscriptorium.sh`: obtains high-resolution images from Manuscriptorium
  - `split_image.sh`: splits double-sided PDFs
- `articulate_ees.ly`, a customized MIDI articulation script
- support for `chords` to `add_variables`
- new commands:
  - `\tacet` for indicating movements where an instrument pauses
  - `\whOn` and `\whOff` for producing white (void) notation
- several snippets:
  - add a tie to the last note (`\extendLV`)
  - add a time signature mark (`\markTimeSig`)
  - adjust overall horizontal spacing (`\tightNotes`)
  - define a multirow short instrument name
  - incipits for solo voice and strings
  - mark deleted parts of a score by gaps across the staves (`\startDeleted` and `\stopDeleted`)
  - show only the numerator of the time signature


### Changed

- Markdown documents (e.g., editorial giudelines) are now stored in a folder `documents`.
- The table of spacing recommendations now also contains default values.
- `\partCombine` in the template now combines up to a tenth by default.

### Fixed

- `add_variables` now adds a bass figure variable for instruments `bc`, `bc_realized`, and `fond`.
- `add_variables` now includes `\twofourtime` and `\twotwotime` for time signatures 2/4 and 2/2, respectively.
- Horizontal spacing between choir staff and its instrument name has been improved.
- Custom right-aligned marks are now invisible at the beginning of a line.


## 2022.01.0

### Added

- initial release
