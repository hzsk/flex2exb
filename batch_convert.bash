#!/bin/bash

# I've been using this script to convert all flextext files
# in a folder to EXB format. One could also make it bit nicer
# by passing the URL and folders as arguments maybe.

for flextext in `ls *.flextext`; 
    do   
         exb=$(echo $flextext | sed 's/flextext/exb/g');   
         curl -F file=@$flextext "http://localhost:8080/flex2exb/transform/file/upload" > $exb; 
done
