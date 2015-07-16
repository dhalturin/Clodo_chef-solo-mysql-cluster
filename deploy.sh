#!/bin/bash

find ./nodes/ -type f -name "*.json" | xargs -I {} basename {} ".json" | while read host
do
    echo "Deploy to: ${host}"
    ssh ${host} -lroot -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no -- "bash -c 'apt-get install -y git && rm -rf chef-solo-mysql-cluster && git clone https://github.com/dhalturin/chef-solo-mysql-cluster.git && cd chef-solo*; bash install.sh > /root/.out &'" > /dev/null &
done

echo ${host}

#watch -n1 -d "ssh ${host} -lroot -- 'crm status'"
