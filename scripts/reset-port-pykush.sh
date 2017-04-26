#!/bin/bash
pykush -s YK22916 -d $1
while [ $? -ne 0 ]; do
	echo "Disable port failed, retrying..."
	pykush -s YK22916 -d $1
done
sleep 10
pykush -s YK22916 -u $1
while [ $? -ne 0 ]; do
	echo "Enable port failed, retrying..."
	pykush -s YK22916 -u $1
done
sleep 10
