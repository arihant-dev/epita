#!/bin/bash
echo "Enter a filename"
read filename
if [ -f "$filename" ]; then
	echo "File found!"
	exit 0
else
	echo "File not found!"
	exit 1
fi
