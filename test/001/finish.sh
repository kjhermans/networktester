#!/bin/sh

./network.pl test.json off

cat /tmp/tcpdump.log
echo
cat /tmp/stolenpasswd
