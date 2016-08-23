#!/bin/bash

server=$1
username=$2
password=$3

vm=`./install_wheezy.sh $1 $2 $3 | tail -n 1`
rm -rf tmp
mkdir tmp
curl -k https://$username:$password@$server/export\?uuid=$vm\&use_compression=true -o tmp/box.xva
echo "{\"provider\": \"xenserver\"}" > tmp/metadata.json
pushd tmp
tar cf ../wheezy.box .
popd



