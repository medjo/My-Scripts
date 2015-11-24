#!/bin/sh

pid=0
mem_size=0

while true
do
    pid="$(ps h -C plugin-container -o pid)"
    #echo "pid = $pid"
    mem_size="$(ps h -C plugin-container -o rss)"
    #echo "mem_size = $mem_size"

    if [ ! -z ${mem_size} ]; then
        #On entre si le processus existe (si la variable mem_size n'est pas vide)
        if [ $mem_size -gt 2000000 ];
        then
            #Si le processus prend trop de place en mémoire, on le tue
            kill $pid
        fi
    fi

    sleep 15
done
