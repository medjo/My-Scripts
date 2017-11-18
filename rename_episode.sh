#! /bin/bash

# Rename a serie of files
# Careful ! You have to rename one type of file at the time (srt then video)

# Usefull to preformat file names
# for i in *.{mkv,srt,flv,avi,mp4}; do good=`echo $i |tr -d "-"`; mv $i $good; done


echo "Enter the name of the serie you want to rename"
read serie

echo "Enter how the serie appears in the file name (if you enter nothing, \
only the files containing the correct serie name will be renamed)"

read bad_serie

if [ -z $bad_serie ]
then
    bad_serie=$serie
fi

apply=false
video_search=0

while true
do
    for season in {01..18}
    do
        if [ $season -lt 10 ]
        then
            season_unit=`echo $season| tail -c 2`
            season_hundred=$((season_unit * 100))
        else
            season_hundred=$((season * 100))
        fi

        for ep in {00..29}
        do
            count=0
            if [ $ep -lt 10 ]
            then
                ep_unit=`echo $ep| tail -c 2`
                season_ep=$((season_hundred + ep_unit)) 
            else
                season_ep=$((season_hundred + ep)) 
            fi

            while [ $count -lt 2 ]
            do
                count=$(( count + 1 ))
                if [ "$video_search" -eq 0 ]
                then
                    bad_file=`ls -1| egrep -i -m 1 "[[:print:]]*${bad_serie}[[:print:]]+($season_ep|${season}(e|x)${ep})[^[:alnum:]][[:print:]]*\.(srt)$" 2> /dev/null`
                else
                    bad_file=`ls -1| egrep -i -m 1 "[[:print:]]*${bad_serie}[[:print:]]+($season_ep|${season}(e|x)${ep})[^[:alnum:]][[:print:]]*\.(mkv|flv|avi|mp4)$" 2> /dev/null`
                fi
                video_search=$((!$video_search))

                extension=`echo "$bad_file" |tail -c 4`
                file_name="${serie} ${season}x${ep}.${extension}"

                #echo file_name : $file_name
                #echo bad_file : $bad_file

                if [ -e "$bad_file" ]
                then
                    if [[ "$bad_file" == "$file_name" ]]
                    then
                        continue
                    fi
                    if [[ "$apply" == true ]]
                    then
                        mv "$bad_file" "$file_name"
                    else
                        echo "$bad_file --> $file_name"
                        if [[ "$extension" != "srt" ]]
                        then
                            echo
                        fi
                    fi
                fi
            done
        done
    done

    if [[ "$apply" != true ]]
    then
        echo "Do you wish to apply the changes ? [y/N]"
        read apply
        if [[ "$apply" == y ]] || [[ "$apply" == Y ]]
        then
            apply=true
        else
            echo -e "The changes won't be applied.\nExiting."
            exit 0
        fi
    else
        echo -e "Changed applied.\nExiting."
        exit 0
    fi

done
