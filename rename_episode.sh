#! /bin/bash

# Rename a serie of files

base_name="Lucifer 02x"
extension=".mkv"

for dizaine in {0..2}
  do

    for unites in {0..9}
    do
      ep=$dizaine$unites
      file_name=${base_name}${ep}${extension}

      bad_file=`ls lcf.2${ep}*${extension} 2> /dev/null`

      if [ -e "$bad_file" ]
      then
        mv "$bad_file" "$file_name"
        echo "$bad_file --> $file_name"
      fi
    done
  done
exit 0
