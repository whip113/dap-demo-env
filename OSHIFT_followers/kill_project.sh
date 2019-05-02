#!/bin/bash
set -euo pipefail

. utils.sh

if [[ $PLATFORM == openshift ]]; then
  $cli login -u $OSHIFT_CLUSTER_ADMIN_USERNAME
fi

set_namespace default

if has_namespace $CONJUR_NAMESPACE_NAME; then
  $cli delete namespace $CONJUR_NAMESPACE_NAME >& /dev/null &

  printf "Waiting for $CONJUR_NAMESPACE_NAME namespace deletion to complete"

  while : ; do
    printf "..."
    
    if has_namespace "$CONJUR_NAMESPACE_NAME"; then
      sleep 5
    else
      break
    fi
  done

  echo ""
fi

echo "Conjur environment purged."
