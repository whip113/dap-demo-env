#!/bin/bash
########################################
##  This script executes on AWS host  ##
########################################

source ./demo.config

if [[ "$(cat /etc/os-release | grep 'Ubuntu 18.04.2 LTS')" == "" ]]; then
  echo "These installation scripts assume Ubuntu 18.04"
  exit -1
fi

if [[ "$CONJUR_MASTER_HOSTNAME" == "" ]]; then
  echo "Please edit demo.config and set CONJUR_MASTER_HOSTNAME to the Public DNS hostname of the Conjur Master."
  exit -1
fi

main() {
  ruby_setup
  install_summon
  install_jq
  load_policies
}

ruby_setup() {
  sudo apt-get update
  sudo apt-get install -qy ruby-dev rubygems build-essential
  # use -V argument for verbose gem install output
  sudo gem install aws-sdk-core
  sudo gem install aws-sigv4
  sudo gem install conjur-api
}

install_summon() {
  ###
  # Also install Summon and create directory for providers
  pushd /tmp
  curl -LO https://github.com/cyberark/summon/releases/download/v0.6.7/summon-linux-amd64.tar.gz \
    && tar xzf summon-linux-amd64.tar.gz \
    && sudo mv summon /usr/local/bin/ \
    && rm summon-linux-amd64.tar.gz
  popd
}

install_jq() {
  sudo snap install jq
}

load_policies() {
   printf "\nEnter admin user name: "
   read admin_uname
   printf "Enter the admin password (it will not be echoed): "
   read -s admin_pwd
   export AUTHN_USERNAME=$admin_uname
   export AUTHN_PASSWORD=$admin_pwd

  ./load_policy_REST.sh root policy/authn-iam.yaml
  ./load_policy_REST.sh root policy/cust-portal.yaml
  ./load_policy_REST.sh root policy/authn-grant.yaml
  ./var_value_add_REST.sh $APPLICATION_NAME/database/username OracleDBuser
  ./var_value_add_REST.sh $APPLICATION_NAME/database/password ueus#!9
}

main "$@"
