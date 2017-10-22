#! /bin/bash

# Rename a serie of files
# Careful ! You have to rename one type of file at the time (srt then video)

# Usefull to preformat file names
# for i in *.{mkv,srt,flv,avi,mp4}; do good=`echo $i |tr -d "-"`; mv $i $good; done


echo "Enter the name of the serie you want to rename"
read serie
apply=false

while true
do
  for season in {00..29}
  do
    for ep in {00..29}
    do
      bad_file=`ls -1| egrep -i -m 1 "[[:print:]]*${serie}[[:print:]]+${season}(e|x)${ep}[[:print:]]*\.(srt|mkv|flv|avi|mp4)$" 2> /dev/null`
      extension=`echo $bad_file |tail -c 4`
      file_name="${serie} ${season}x${ep}.${extension}"
  
      #echo file_name : $file_name
      #echo bad_file : $bad_file
    
      if [ -e "$bad_file" ]
      then
        if [[ $apply == true ]]
        then
          mv "$bad_file" "$file_name"
        else
          echo "$bad_file --> $file_name"
        fi
      fi
    done
  done

  if [[ $apply != true ]]
  then
    echo "Do you wish to apply the changes ? [y/N]"
    read apply
    if [[ $apply == y ]] || [[ $apply == Y ]]
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
