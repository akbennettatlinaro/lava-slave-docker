#!/bin/bash
pykush -s YK22916 -d 1
sleep 2
pykush -s YK22916 -u 1
sleep 20 
telnet 172.17.0.1 2001
