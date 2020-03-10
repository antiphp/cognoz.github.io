#!/bin/bash

KOLLA_SERVICES="ALL"
AGE="10w"

show_help () {
  echo "Usage: `basename $0` --inventory|-i [kolla-ansible inventory location, e.g. /etc/kolla/inventory] (MANDATORY argument)"
  echo
  echo "OPTIONAL arguments:"
  echo "--kolla-services|-k    services-to-gather, e.g 'nova,cinder,neutron', default value: all services"
  echo "--age|-a               age in weeks,days,hours, eg. '1w','3d', default value: '10w'"
  echo
  echo "Other options can be set in roles/support-bundle/defaults/main.yml or in playbook support-bundle-playbook.yml"
}

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -k|--kolla-services)
            if [ "$2" ]; then
                KOLLA_SERVICES=$2
                shift
            else
                echo 'ERROR: "-k|--kolla-services must be non-empty comma separated list of services, e.g. "cinder,nova"'
                exit 1
            fi
            ;;
        -i|--inventory)
            if [ "$2" ]; then
                INVENTORY=$2
                shift
            else
                echo 'ERROR: "-i|--inventory must be non-empty path to kolla ansible inventory, e.g. "/etc/kolla/inventory"'
                exit 1
            fi
            ;;
        -a|--age)
            if [ "$2" ]; then
                AGE=$2
                shift
            else
                echo 'ERROR: "-a|--age must be non-empty age value in weeks/days/hours, e.g: "1w,4d,7h"'
                exit 1
            fi
            ;;
        *) break
    esac
    shift
done


if [[ -z ${INVENTORY} ]]; then
  echo "--inventory|-i argument must be set! Exiting"
  echo
  echo "Use `basename $0` -h|--help for help"
  exit 1
fi

ans_vars () {
  if [[ ${KOLLA_SERVICES} != 'ALL' ]]; then
    if [[ ${AGE} != '10w' ]] ; then
      ANS_VARS="{sb_max_age: $AGE, sb_kolla_log_services: [${KOLLA_SERVICES}]}"
    else
      ANS_VARS="{sb_kolla_log_services: [${KOLLA_SERVICES}]}"
    fi
  elif [[ ${AGE} != '10w' ]]; then
    ANS_VARS="{sb_max_age: ${AGE}}"
  fi
}

run_playbook () {
  ans_vars
  echo "Gathering info for ${KOLLA_SERVICES} services with age less or equal to ${AGE}"
  set -x
  echo "gm ${ANS_VARS}"
  if [[ ! -z ${ANS_VARS} ]]; then
    echo 'kek'
    ansible-playbook -v -i ${INVENTORY} -e "${ANS_VARS}" support-bundle-playbook.yml
  else
    ansible-playbook -v -i ${INVENTORY} support-bundle-playbook.yml
  fi
}

run_playbook
