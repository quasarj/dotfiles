#!/usr/bin/bash

#xdg-open "https://arkansas.attask-ondemand.com/search?objCode=TASK&allowRedirect=true&query=38708" &
google-chrome "https://arkansas.attask-ondemand.com/search?objCode=TASK&allowRedirect=true&query=$1" > /dev/null &
