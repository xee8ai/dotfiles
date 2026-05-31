#!/usr/bin/env python3

import os
from PIL import Image
from PIL.ExifTags import TAGS
from pprint import pprint
import sys

for filename_original in os.listdir("."):
    im = Image.open(filename_original)
    exifdata = im.getexif()

    # 306 is ID for DateTime; see TAGS
    datetime = exifdata.get(306)

    if not datetime:
        print(f"No datetime found for {filename_original}")
        continue

    datetime = datetime.replace(" ", "t").replace(":", "-")

    if filename_original.startswith(datetime):
        print(f"{filename_original} already starts with {datetime}")

    filename_new = f"{datetime}__{filename_original}"
    pprint(f"Renaming {filename_original} to {filename_new}")
    os.rename(filename_original, filename_new)
