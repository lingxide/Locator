#!/bin/bash
init(){
	###Please modify the following settings###
	TOTALFILE="total/*";
	BANNER="banner.txt";
	DEBUG="OFF";
	DEBUG_SN="6CU7316LAY";
	###Please modify the above settings###

	DATE=`date --rfc-3339=date`;  # Define Date format 
	if [ ! -f log-$DATE.tmp ]; then
	touch log-$DATE.tmp
	fi
	touch log-$DATE.tmp
	if [[ $V1 == "debug" ]]; then
	debug
	fi
	if [[ $V1 == "cleanlog" ]]; then
	cleanlog
	fi
	if [[ $V1 == "showlog" ]]; then
	showlog
	fi
	cat $BANNER
}
debug(){
	DEBUG="ON";  #Set Debug Switch to ON
	echo "You are in debug mode now."
	if [ ! -n "$V2" ]; then
	echo -e "You did not entered SN number, now setting SN to $DEBUG_SN"
	SN=$DEBUG_SN
	else
	DEBUG_SN=$V2
	fi
	echo -e "Ending in running debug module.\n
	***********************\n
	Total File is $TOTALFILE \n
	Banner File is $BANNER \n
	Debugging SN number is $DEBUG_SN \n
	Date is $DATE \n
	\$1 is $V1 \n
	\$2 is $V2 \n
	***********************"
	search

}
cleanlog(){
	if [ -s log-$DATE.tmp ]; then
	read -p "Are you sure to remove .tmp file?" choice
	if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
	rm log-$DATE.tmp
	echo -e "File log-$DATE.tmp deleted."
	fi
	fi
	if [ -f log-$DATE.csv ]; then
	read -p "Are you sure to remove .csv file?" choice
	if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
	rm log-$DATE.csv
	echo -e "File log-$DATE.csv deleted."
	fi
	fi
	exit
}
showlog(){
	echo -e "\nDisplaying log on $DATE\n"
	if [ -f log-$DATE.csv ]; then
	cat log-$DATE.csv | sort | awk -F "," ' BEGIN {i=0} {i++; print i, "\tServer SN:"$1"\t iLO IP:"$2"\t Rack Position:"$3} END {print "\nTotal: "i "\n"}'
	else
	echo -e "No Logs Available."
	fi
	exit
}
search(){
	echo -e "\n"

	### Debug Module START ###
	if [ "$DEBUG" = "ON" ]; then
	echo -e "Now read the iLO address: \n\n `cat csv/*.csv | grep -w '^'$DEBUG_SN | sort | uniq | awk -F "," '{print $5}'` \n"  # iLO Column in CSV
	DEBUG_ILO=`cat csv/*.csv | awk -F "," '{print $1,$5}' | grep -w '^'$DEBUG_SN | sort | uniq | awk '{print $2}'`  # SN Column and iLO Column in CSV
	echo -e "iLO Total: `cat csv/*.csv | grep -w '^'$DEBUG_SN | sort | wc -l` \n"
	if [ -n "$DEBUG_ILO" ]; then
	echo -e "Debug iLO: $DEBUG_ILO\n"
	echo -e "Now read the position: \n\n`cat $TOTALFILE | grep -w $DEBUG_ILO |awk '{print $2}' | sort | uniq` \n"  # Position Column in TOTALFILE
	echo -e "Position Total: `cat $TOTALFILE | grep -w $DEBUG_ILO |awk '{print $2}' |sort | uniq | wc -l` \n"  # Same as above
	else
	echo -e "DEBUG_ILO is \"$DEBUG_ILO\", which is invaild."
	fi
	echo -e "Now read the Building: \n\n`cat $TOTALFILE | grep -w $DEBUG_ILO |awk '{print $3}'` \n"  # Building Column in TOTALFILE
	exit
	fi
	### Debug Module END ###

	if [ ! -n "$SN" ]; then
	read -p "Please read SN or type Q to exit:" SN
	fi
	if [ "$SN" = "" ]; then
	search
	fi
	if [ "$SN" = "q" ] || [ "$SN" = "Q" ]; then
	quit
	elif [ "$SN" = "q!" ]; then
	echo -e "Quit without saving..." && exit
	else
	#Read iLO address here
	if [ `cat csv/*.csv | grep -w '^'$SN | sort | uniq | wc -l` -eq "0" ]; then
	throwerror 501;
	elif  [ `cat csv/*.csv | grep -w '^'$SN | sort | uniq | wc -l` -gt "1" ]; then
	throwerror 500;
	fi
	ILO=`cat csv/*.csv | grep -w '^'$SN | sort | uniq | awk -F "," '{print $5}'`  # Read *.csv from HPe Provided List, iLO Column
	[[ -z "$ILO"  ]] && throwerror 404;
	#Read Building here
	BUILDING=`cat $TOTALFILE | grep -w $ILO |awk '{print $3}'`  # Building Column
	#Read Position here
	POS=`cat $TOTALFILE | grep -w $ILO |awk '{print $2}' | sort | uniq` # Position Column
	if [ `echo $POS | wc -l` != "1" ]; then
	throwerror 503
	fi
	[[ -z "$POS" ]] && throwerror 400;
	output
	fi
}
output(){
	#clear
	printf "\n
	SN:$SN \n\n
	iLO:$ILO \n\n
	Position:$POS\n\n
	Building:$BUILDING
	"
	echo "$SN,$ILO,$POS,$BUILDING" | tee >> log-$DATE.tmp  #Log to tmp file
	SN=""
	search
}
throwerror(){
	case "$1" in
	404) echo -e "\e[41m[Critical]\e[40m Err code: 404 \nNo iLO address matched.\n " && quit;;  #When this occured, it means fatal error in goods list
	400) echo -e "\e[41m[Critical]\e[40m Err code: 400 \nNo Position matched.\n" &&quit;;  #When this happened, it means the iLO has no match to position
	500) echo -e "\e[41m[Warning]\e[40m Err code: 500 \nConflict content.\n" 
	     echo -e "Current SN: $SN\nConflict SN:"
	     echo `cat csv/*.csv | grep -xF $SN `
	     quit;;
	501) echo -e "\e[41m[Critical]\e[40m Err code: 501 \nNo content.\n" &&quit;;
	503) echo -e "\e[41m[Critical]\e[40m Err code: 503 \nMultiple Position matched.\n" &&quit;;
	*) echo -e  "Unknown Error." && debug;;
	esac
	echo "Test"
}
quit(){
	if [ ! -f log-$DATE.csv ]; then
	touch log-$DATE.csv
	fi
	cat log-$DATE.csv >> log-$DATE.tmp
	cat log-$DATE.tmp | sort | uniq > log-$DATE.csv  #Uniq the final log
	rm -rf log-$DATE.tmp
	echo "quiting..."
	exit
}
main(){
	init
	search
	exit
}
V1=$1
V2=$2
main
