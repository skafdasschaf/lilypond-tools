# How to submit scores to IMSLP

## Uploading new scores

Generally, follow the official instructions on

- [composition lists](https://imslp.org/wiki/Composer_Composition_Lists_Manual_of_Style)
- [genres](https://imslp.org/wiki/IMSLP:Tagging)
- [work pages](https://imslp.org/wiki/IMSLP:Score_submission_guide/Layout_of_Work_Pages).

Submit vocal scores as “Other” and manually change the header to
```
===Vocal Scores===
```

Template for work metadata:
```
|Language=Latin
|Piece Style=Baroque
|Manuscript Sources={{RISMc|212006126|Mss full score (D-Dl, Mus.2973-D-26)}}
|Instrumentation=soprano, alto, tenor, bass, mixed chorus (SATB), orchestra
|InstrDetail=2 flutes, 2 oboes, 2 horns, 2 trumpets, timpani, strings, continuo
```


## Updating scores

When uploading the new file, add a note like
```
update to v2.0.0
```

Mark a superseded score for deletion by editing its page and inserting a note like
```
{{Delete|in v2.0.0, trumpets+timpani and horns have been split into two separate files}}
```
