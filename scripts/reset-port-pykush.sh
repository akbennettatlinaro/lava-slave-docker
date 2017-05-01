#!/bin/bash
flock /var/lock/lava-pykush.lck pykush -s YK22916 -d $1
while [ $? -ne 0 ]; do
	echo "Disable port failed, retrying..."
	flock /var/lock/lava-pykush.lck pykush -s YK22916 -d $1
done
sleep 5
flock /var/lock/lava-pykush.lck pykush -s YK22916 -u $1
while [ $? -ne 0 ]; do
	echo "Enable port failed, retrying..."
	flock /var/lock/lava-pykush.lck pykush -s YK22916 -u $1
done
sleep 20
