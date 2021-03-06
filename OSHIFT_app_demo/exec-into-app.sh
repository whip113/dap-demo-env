#!/bin/bash 
. utils.sh
if [[ $# != 1 ]]; then
  echo "specify 'web' or 'app'"
  exit -1
fi
set_namespace $TEST_APP_NAMESPACE_NAME
app_pod=$($cli get pods | grep "Running" | grep $1 | awk '{print $1}')
$cli exec -it $app_pod -- bash
