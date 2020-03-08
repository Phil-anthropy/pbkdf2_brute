#!/bin/bash
# Expecting hash and salt to be hexified

usage() { 
	echo "Brute force pbkdf2 SHA256 using John with salt/hash (hex format)." 
	echo -e "\nUsage:\n ./pbkdf2_brute.sh -s salt -h hash -i iterations -f passwords \n" 
	} 

if [  $# -le 1 ] 
then 
      usage
      exit 1
fi

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--salt)
    SALT="$2"
    shift # past argument
    shift # past value
    ;;
    -h|--hash)
    HASH="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--iterations)
    ITER="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--file)
    FILE="$2"
    shift # past argument
    shift
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}"

for ((i=1;i<=${ITER};i++));
do
    salt=`echo $SALT | xxd -r -p | base64 | sed 's/+/./g' | tr -d '='`
    hash=`echo $HASH | xxd -r -p | base64 | sed 's/+/./g' | tr -d '='`
    echo '$pbkdf2-sha256$'$i'$'${salt}'$'${hash} > /tmp/hash.txt 
    john --format=PBKDF2-HMAC-SHA256 --wordlist=$FILE /tmp/hash.txt 
done
