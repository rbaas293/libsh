#!/bin/bash
PKG=$1

mkdir -p $PKG

cd $PKG

rm -f error.txt
apt download $(apt-rdepends $PKG | grep -v "^ ") 2> error.txt
#IF THERE WAS ERRORS (DEPENDENCIES NOT FOUND)
if [ $(cat error.txt | wc -l) -gt 0 ]
then
    partial_command="\("
    while read -r line
    do
        conflictive_package="$(awk '{split($0,array," "); print array[8]}' <<< $line)"
        partial_command="$partial_command$conflictive_package\|"
    done < error.txt

    partial_command="$(awk '{print substr($0, 1, length($0)-2)}' <<< $partial_command)\)"
    eval "apt download \$(apt-rdepends $PKG | grep -v '^ ' | grep -v '^$partial_command$')"
fi
rm error.txt

cd ..
