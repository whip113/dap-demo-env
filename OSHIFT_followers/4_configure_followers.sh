#!/bin/bash -x
set -euo pipefail

. utils.sh

main() {
  set_namespace $CONJUR_NAMESPACE_NAME

  announce "Configuring followers."

  configure_followers

  echo "Followers configured."
}

configure_followers() {
  pod_list=$($cli get pods -l role=follower --no-headers | awk '{ print $1 }')
  
  for pod_name in $pod_list; do
    configure_follower $pod_name &
  done
  
  wait # for parallel configuration of followers
}

configure_follower() {
  local pod_name=$1

  printf "Configuring follower %s...\n" $pod_name

  copy_file_to_container $FOLLOWER_SEED_FILE "/tmp/follower-seed.tar" "$pod_name"

  $cli exec $pod_name -- evoke unpack seed /tmp/follower-seed.tar

  if [[ $NO_DNS == true ]]; then
    $cli exec -it $pod_name -- bash -c "echo \"$CONJUR_MASTER_HOST_IP    $CONJUR_MASTER_HOST_NAME\" >> /etc/hosts"
  fi

  # copy modified configuration recipe and nginx patch script into node
  copy_file_to_container "./configure.rb.5.3.1" "/opt/conjur/evoke/chef/cookbooks/conjur/recipes/configure.rb" "$pod_name"
  copy_file_to_container "./patch_nginx.sh" "/opt/conjur/evoke/bin" "$pod_name"

  $cli exec $pod_name -- evoke configure follower -p $CONJUR_MASTER_PORT

  if [[ $PLATFORM = "openshift" ]] ; then
    $cli create route passthrough --service=conjur-follower
  fi

}

main $@
