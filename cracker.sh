#!/bin/bash
set -e

crack_hash () {
     
     user_info=$1
     dict=$2
     user="$(cut -d':' -f1 <<< $user_info)"
     pass="$(cut -d':' -f2 <<< $user_info)"
     salt="$(cut -d'?' -f3 <<< $pass)"
     flag=0
    while read word
    do
     crack_pass="$(openssl passwd -salt $salt -6 $word)"
     pass="$(echo $pass | sed 's/\?/\$/g')"
     if [ "$pass" = "$crack_pass" ]
     then
      echo -e "Found password for user $(tput setaf 2)$user: $word$(tput setaf 7)\n"
      flag=1
     fi
    done < $dict

   if [ $flag = 0 ]
   then
    echo -e "No Password Found for $(tput setaf 1)$user $(tput setaf 7), try different list\n"
   fi
   exit 0
}

export -f crack_hash

if [ "$1" = "-h" ]||[ "$1" = "--help" ]
 then
    echo "USAGE:"
    echo "	./cracker <dictionay> <unshadow_file>"
    echo ""
    exit
elif [ $# -gt 2 ]
 then
    echo "Your command line contains $# arguments"
    echo "This program accepts only 2 arguments"
    exit
elif [ $# -lt 2 ]
 then
    echo "Your command line contains insufficient arguments"
    exit
else
# Call to the cracker function
   if [ -f "$1" ]&&[ -f "$2" ]
   then
    dict_file=$1
    pass_file=$2
    sed 's/\$/\?/g' $pass_file | xargs -P 4 -I '{}' bash -c "crack_hash '{}' $dict_file &" 
    #wait
    #echo "All the hashes have been checked. Process completed"
    exit 0
   else
    echo "The supplied files do not exist"
   fi
fi
