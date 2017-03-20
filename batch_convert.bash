for flextext in `ls *.flextext`; 
    do   
         exb=$(echo $flextext | sed 's/flextext/exb/g');   
         curl -F file=@$flextext "http://localhost:8080/flex2exb/transform/file/upload" > $exb; 
done
