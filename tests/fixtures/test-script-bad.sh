#!/bin/bash

# Bad shell script with issues for testing

cd /tmp

name=$1
echo "Hello, $name"

if [ -f $HOME/file.txt ]
then
    cat $HOME/file.txt
fi

rm -rf $dir/*
