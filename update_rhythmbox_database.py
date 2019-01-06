#! /usr/bin/python3.5

# Update the RhythmBox database file usually
# ($HOME/.local/share/rhythmbox/rhythmdb.xml), in order to keep track of moved
# files.

# This script has to be ran from the new location : where the files has been
# moved to.

import os, glob
import xml.etree.ElementTree as ET
from pathlib import Path
from urllib.parse import quote

NB_FILES_TO_HANDLE = 100000
HOME = str(Path.home())
#DB_LOCATION = HOME+"/Documents/Scripts/test.xml"
#DB_LOCATION_OUTPUT = HOME+"/Documents/Scripts/test_output.xml"
DB_LOCATION = HOME+"/.local/share/rhythmbox/rhythmdb.xml"
DB_LOCATION_OUTPUT = DB_LOCATION
#DB_LOCATION_OUTPUT = HOME+"/.local/share/rhythmbox/rhythmdb_output.xml"




# Update the old entry with the new location
def updateOldEntry(root, quoted_file, quoted_new_location):
    entries_found = 0
    for location in root.iter("location"):
        if quoted_file in location.text:
            if entries_found > 1:
                raise Exception("Only 1 entry should match the file name")
            entries_found += 1
            print(location.text+" -> "+quoted_new_location)
            location.text = quoted_new_location


# count number of entries with matching filename
def countEntriesWithMatchingFilename(root, quoted_file):
    entries_found = 0
    for entry in root.findall("entry"):
        location = entry.find('location').text

        if quoted_file in location:
            entries_found += 1
            continue
    print("found", entries_found, "entries")
    return entries_found


# Remove the newly created entry, backup the new location
def rmNewEntryAndBackupNewLocation(root, quoted_new_location):
    for entry in root.findall("entry"):
        location = entry.find('location').text
        if quoted_new_location in location:
            root.remove(entry)
            print("entry removed")
            return location

def formatString(string):
    url_char = [
            ["%21", "!"],
            ["%22", "\""],
            #["%23", "#"],
            ["%24", "$"],
            ["%25", "%"],
            ["%26", "&"],
            ["%27", "'"],
            ["%28", "("],
            ["%29", ")"],
            ["%2A", "*"],
            ["%2B", "+"],
            ["%2C", ","],
            ["%2D", "-"],
            ["%2E", "."],
            ["%2F", "/"],
            ["%3A", ":"],
            ["%3B", ";"],
            ["%3C", "<"],
            ["%3D", "="],
            ["%3E", ">"],
            ["%3F", "?"],
            ["%40", "@"],
            ["%5C", "\\"],
            ["%5E", "^"],
            ["%5F", "_"],
            ["%7B", "{"],
            ["%7C", "|"],
            ["%7D", "}"],
            ["%7E", "~"],
            ["%B0", "°"],
            ["%B2", "²"],
            #["%B3", "³"],
            ["%C0", "À"],
            ["%C7", "Ç"],
            ["%C8", "À"],
            ["%C9", "É"],
            ["%CA", "È"],
            ["%CB", "Ê"],
            ["%E0", "à"],
            ["%E7", "ç"],
            ["%E8", "è"],
            ["%E9", "é"],
            ["%EA", "ê"],
            ["%EB", "ë"],
            ["%EE", "î"],
            ["%F9", "ù"],
            ["%F3", "ó"],
            ]

    fmt_str = quote(string)
    for item in url_char:
        fmt_str = fmt_str.replace(item[0], item[1])

    return fmt_str

def handleOneFile(filename, root):
    new_location = os.path.abspath(filename)
    quoted_file = formatString(filename)
    quoted_new_location = "file://" + formatString(new_location)
    print("\nHandling file : " + new_location)
    #print("quoted_new_location : " + quoted_new_location)
    #print("quoted_file : " + quoted_file)

    entries_found = countEntriesWithMatchingFilename(root, quoted_file)
    
    if entries_found == 2:
        rmNewEntryAndBackupNewLocation(root, quoted_new_location)
        updateOldEntry(root, quoted_file, quoted_new_location)
    elif entries_found == 0:
        print("quoted_file : " + quoted_file)
        raise Exception("Error processing file : " + filename +
                "\nTry converting a special character from URL to character")
    elif entries_found == 1:
        print("Skipped")
        return
    else:
        print("quoted_file : " + quoted_file)
        raise Exception("Error processing file : " + filename +
                "\nTry to manually edit the database")

# START
i = 0
tree = ET.parse(DB_LOCATION)

for file in os.listdir("."):
    i += 1
    root = tree.getroot()

    handleOneFile(file, root)
    if i >= NB_FILES_TO_HANDLE:
        break

tree.write(DB_LOCATION_OUTPUT)
print("\n Number of files analysed : " + str(i))
