#! /bin/bash

if [ -n "$1" ]
then
	echo "$1 to md5"
	echo -n "$1" | md5 | cut -d ' ' -f1
else
	echo "Usage:"
	echo "$0 <str to md5>"
fi
