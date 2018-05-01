#! /usr/bin/python3.5

# Clean up the tv show files that are in the current directory, by moving them
# in the folder : SERIE_NAME/Saison SEASON_NUMBER/FILENAME

# Careful ! FILENAME muste be formatted this way :
# SERIE_NAME SEASONxEPISODE.{mkv,srt,flv,avi,mp4}

import os, glob

confirmed = False
DEBUG = False

while True:
    #i = 0
    print()
    for file in os.listdir("."):
        # We only treat files with a particular extension
        if (file.endswith(".mkv") or file.endswith(".srt") or file.endswith(".avi")
                or file.endswith(".mp4") or file.endswith(".flv")):

            name_season_ep = file[:file.rfind(".")]
            x_index = name_season_ep.rfind("x")
            season = name_season_ep[x_index - 2:x_index]
            name = name_season_ep[:x_index - 3]

            if DEBUG == True:
                print()
                print("Full filename : ", file)
                print("Filename without extension : ", name_season_ep)
                print("Season only : ", season)
                print("Name only : ", name)

            if season.isdigit():
                season_int = int(season)
                season = str(season_int)
            else:
                raise ValueError("'season' in not a number. Maybe the episode file is\
                        not formatted properly.\nIncorrect filename : " + file)

            target_dir = name+"/Saison " + season + "/"

            print("./" + file + " -> ./" + target_dir + file)

            if (confirmed):
                os.makedirs(target_dir, exist_ok=True)
                os.rename(file, target_dir+file)
        #if i >= 1:
        #    break
        #i += 1

    if confirmed:
        print("Changed applied.\nExiting.")
        exit(0)

    print()
    try:
        confirmation = input("Do you wish to apply the changes ? [y/N]")
    except:
        print()
        exit(-1)

    if confirmation == "y" or confirmation == "Y":
        confirmed = True
    else:
        print("The changes won't be applied.\nExiting.")
        exit(0)

exit(0)
