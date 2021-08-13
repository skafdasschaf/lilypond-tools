#!/usr/bin/python

import datetime
import os
import pandas as pd
import yaml


ROOT_DIR = "/home/wolfgang/Dokumente/Noten"
IGNORED_COMPOSER_DIRS = ["Misc", "TODO"]
OUTPUT_FILE = "works.csv"


# read metadata
metadata = []
for composer_dir in os.listdir(ROOT_DIR):
    full_composer_dir = os.path.join(ROOT_DIR, composer_dir)
    if (not os.path.isdir(full_composer_dir) or
        composer_dir in IGNORED_COMPOSER_DIRS):
        continue
    for work_dir in os.listdir(full_composer_dir):
        full_work_dir = os.path.join(full_composer_dir, work_dir)
        if not os.path.isdir(full_work_dir):
            continue
        try:
            with open (os.path.join(full_work_dir, "metadata.yaml")) as f:
                work_data = yaml.load(f, Loader=yaml.SafeLoader)
                work_data["folder"] = full_work_dir
                metadata.append(work_data)
        except FileNotFoundError:
            print("Warning: No metadata found in", full_work_dir)
            pass


# normalize and save as CSV
for i in range(len(metadata)):
    try:
        metadata[i]["sources"] = {str(k): v for k, v in metadata[i]["sources"].items()}
    except (AttributeError, KeyError):
        pass

(pd.json_normalize(metadata, sep="_")
   .sort_values(["composer", "title"])
   .to_csv(OUTPUT_FILE, index=False))
