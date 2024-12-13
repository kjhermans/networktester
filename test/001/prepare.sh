#!/bin/sh

rm -f /tmp/stolenpasswd
rm -f /tmp/tcpdump.log

./network.pl test.json off
./network.pl test.json on
