#!/bin/bash

while getopts ":v:" opt; do
  case ${opt} in
    v )
      VAULT_NAME=$OPTARG
      ;;
    \? )
      echo "Usage: $0 [-v VAULT_NAME]" >&2
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

if [ -z "$VAULT_NAME" ]; then
  echo "Vault name is required. Usage: $0 [-v VAULT_NAME]" >&2
  exit 1
fi

for ARN in $(aws backup list-recovery-points-by-backup-vault --backup-vault-name "${VAULT_NAME}" --query 'RecoveryPoints[].RecoveryPointArn' --output text); do
  echo "deleting ${ARN} ..."
  aws backup delete-recovery-point --backup-vault-name "${VAULT_NAME}" --recovery-point-arn "${ARN}"
done