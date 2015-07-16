#!/bin/bash

ip=`ip -4 a s dev eth0 | grep inet | cut -f1 -d'/' | cut -f6 -d' '`
echo "Host ip: ${ip}"

command -v chef-solo
if [ "$?" -gt "0" ]; then
	echo "Need install chef-solo"
	curl -sL https://www.opscode.com/chef/install.sh | bash 
fi

chef-solo -c solo.rb -j nodes/${ip}.json
