#!/bin/bash

VAULT_NAME=dashboard_efs_backup
for ARN in $(aws backup list-recovery-points-by-backup-vault --backup-vault-name "${VAULT_NAME}" --query 'RecoveryPoints[].RecoveryPointArn' --output text); do
  echo "deleting ${ARN} ..."
  aws backup delete-recovery-point --backup-vault-name "${VAULT_NAME}" --recovery-point-arn "${ARN}"
done