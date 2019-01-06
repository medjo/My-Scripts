#! /bin/bash

CURR_DIR=`readlink -e .`

if [[ -z "$@" ]]
then
    echo "You must pass one or several arguments that matche files"
    exit -1
fi

for file in "$@"
do
    ls -alh "$CURR_DIR"/"$file"
    res="$?"

    if [[ $res != 0 ]]
    then
        echo "At least one argument does not match to any file"
        exit -1
    fi
done

echo
echo "Do you want to remove the files listed above ? [y/N]"
read ans
if [ "$ans" == "y" -o "$ans" == "Y" ]
then
    for file in "$@"
    do
        rm "$file"
        echo "file removed : '$file'"
    done
else
    echo "Nothing has been removed"
fi
