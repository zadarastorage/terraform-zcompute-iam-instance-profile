#!/usr/bin/env bash
# verify-iam-cleanup.sh - Verify IAM resources are actually deleted after terraform destroy
#
# This script checks that IAM resources (role, policy, instance profile) are gone
# after a terraform destroy. On zCompute, destroy can succeed in Terraform but leave
# orphaned resources behind, causing name collisions on the next apply.
#
# Required environment variables:
#   AWS_ENDPOINT_URL   - zCompute IAM endpoint
#   AWS_ACCESS_KEY_ID  - AWS-style access key
#   AWS_SECRET_ACCESS_KEY - AWS-style secret key
#   AWS_REGION         - Region (typically us-east-1)
#   ROLE_NAME          - Expected role name to verify is gone
#   PROFILE_NAME       - Expected instance profile name to verify is gone
#   POLICY_PREFIX      - Policy name prefix (policy name includes MD5 hash)
#
# Optional:
#   MAX_WAIT_SECONDS   - Max time to wait for eventual consistency (default: 60)
#   FORCE_CLEANUP      - If "true", attempt to force-delete any remaining resources

set -euo pipefail

: "${ROLE_NAME:?ROLE_NAME is required}"
: "${PROFILE_NAME:?PROFILE_NAME is required}"
: "${POLICY_PREFIX:?POLICY_PREFIX is required}"
: "${MAX_WAIT_SECONDS:=60}"
: "${FORCE_CLEANUP:=false}"

POLL_INTERVAL=5
ELAPSED=0
RESOURCES_REMAINING=true

echo "============================================"
echo "IAM Cleanup Verification"
echo "============================================"
echo "Role:            $ROLE_NAME"
echo "Profile:         $PROFILE_NAME"
echo "Policy prefix:   $POLICY_PREFIX"
echo "Max wait:        ${MAX_WAIT_SECONDS}s"
echo "Force cleanup:   $FORCE_CLEANUP"
echo "============================================"

check_role_exists() {
  aws iam get-role --role-name "$ROLE_NAME" --output json --no-verify-ssl 2>/dev/null && return 0
  return 1
}

check_profile_exists() {
  aws iam get-instance-profile --instance-profile-name "$PROFILE_NAME" --output json --no-verify-ssl 2>/dev/null && return 0
  return 1
}

check_policy_exists() {
  # Policy name includes an MD5 hash suffix, so we search by prefix
  local policies
  policies=$(aws iam list-policies --scope Local --output json --no-verify-ssl 2>/dev/null || echo '{"Policies":[]}')
  local matches
  matches=$(echo "$policies" | jq -r ".Policies[] | select(.PolicyName | startswith(\"${POLICY_PREFIX}\")) | .PolicyName")
  if [ -n "$matches" ]; then
    echo "$matches"
    return 0
  fi
  return 1
}

force_cleanup_role() {
  echo "  Force-cleaning role: $ROLE_NAME"

  # Detach all managed policies
  local attached
  attached=$(aws iam list-attached-role-policies --role-name "$ROLE_NAME" --output json --no-verify-ssl 2>/dev/null || echo '{"AttachedPolicies":[]}')
  local arns
  arns=$(echo "$attached" | jq -r '.AttachedPolicies[].PolicyArn // empty')
  for arn in $arns; do
    echo "    Detaching policy: $arn"
    aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "$arn" --no-verify-ssl 2>/dev/null || true
  done

  # Remove inline policies
  local inline
  inline=$(aws iam list-role-policies --role-name "$ROLE_NAME" --output json --no-verify-ssl 2>/dev/null || echo '{"PolicyNames":[]}')
  local names
  names=$(echo "$inline" | jq -r '.PolicyNames[] // empty')
  for name in $names; do
    echo "    Deleting inline policy: $name"
    aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name "$name" --no-verify-ssl 2>/dev/null || true
  done

  # Delete the role
  aws iam delete-role --role-name "$ROLE_NAME" --no-verify-ssl 2>/dev/null || true
}

force_cleanup_profile() {
  echo "  Force-cleaning instance profile: $PROFILE_NAME"

  # Remove roles from profile
  local profile_info
  profile_info=$(aws iam get-instance-profile --instance-profile-name "$PROFILE_NAME" --output json --no-verify-ssl 2>/dev/null || echo '{}')
  local roles
  roles=$(echo "$profile_info" | jq -r '.InstanceProfile.Roles[].RoleName // empty')
  for role in $roles; do
    echo "    Removing role $role from profile"
    aws iam remove-role-from-instance-profile --instance-profile-name "$PROFILE_NAME" --role-name "$role" --no-verify-ssl 2>/dev/null || true
  done

  # Delete the profile
  aws iam delete-instance-profile --instance-profile-name "$PROFILE_NAME" --no-verify-ssl 2>/dev/null || true
}

force_cleanup_policies() {
  echo "  Force-cleaning policies with prefix: $POLICY_PREFIX"

  local policies
  policies=$(aws iam list-policies --scope Local --output json --no-verify-ssl 2>/dev/null || echo '{"Policies":[]}')
  local matches
  matches=$(echo "$policies" | jq -r ".Policies[] | select(.PolicyName | startswith(\"${POLICY_PREFIX}\")) | \"\(.PolicyName)|\(.Arn)\"")

  echo "$matches" | while IFS='|' read -r name arn; do
    [ -z "$name" ] && continue
    echo "    Deleting policy: $name ($arn)"

    # Detach from all entities first
    local entities
    entities=$(aws iam list-entities-for-policy --policy-arn "$arn" --output json --no-verify-ssl 2>/dev/null || echo '{}')

    for role_name in $(echo "$entities" | jq -r '.PolicyRoles[].RoleName // empty'); do
      aws iam detach-role-policy --role-name "$role_name" --policy-arn "$arn" --no-verify-ssl 2>/dev/null || true
    done

    aws iam delete-policy --policy-arn "$arn" --no-verify-ssl 2>/dev/null || true
  done
}

# Poll until resources are gone or timeout
while [ "$RESOURCES_REMAINING" = "true" ] && [ "$ELAPSED" -lt "$MAX_WAIT_SECONDS" ]; do
  RESOURCES_REMAINING=false

  echo ""
  echo "--- Check at ${ELAPSED}s ---"

  # Check role
  if check_role_exists >/dev/null 2>&1; then
    echo "  STILL EXISTS: Role '$ROLE_NAME'"
    RESOURCES_REMAINING=true
  else
    echo "  GONE: Role '$ROLE_NAME'"
  fi

  # Check instance profile
  if check_profile_exists >/dev/null 2>&1; then
    echo "  STILL EXISTS: Instance profile '$PROFILE_NAME'"
    RESOURCES_REMAINING=true
  else
    echo "  GONE: Instance profile '$PROFILE_NAME'"
  fi

  # Check policies
  local_policies=""
  if local_policies=$(check_policy_exists 2>/dev/null); then
    echo "  STILL EXISTS: Policies matching '$POLICY_PREFIX': $local_policies"
    RESOURCES_REMAINING=true
  else
    echo "  GONE: No policies matching '$POLICY_PREFIX'"
  fi

  if [ "$RESOURCES_REMAINING" = "true" ]; then
    if [ "$ELAPSED" -lt "$MAX_WAIT_SECONDS" ]; then
      echo "  Waiting ${POLL_INTERVAL}s for eventual consistency..."
      sleep "$POLL_INTERVAL"
      ELAPSED=$((ELAPSED + POLL_INTERVAL))
    fi
  fi
done

echo ""
echo "============================================"

if [ "$RESOURCES_REMAINING" = "true" ]; then
  echo "WARNING: Resources still exist after ${MAX_WAIT_SECONDS}s"

  if [ "$FORCE_CLEANUP" = "true" ]; then
    echo ""
    echo "FORCE_CLEANUP enabled - attempting manual deletion..."
    echo ""

    # Clean up in dependency order: profile -> role -> policy
    if check_profile_exists >/dev/null 2>&1; then
      force_cleanup_profile
    fi

    if check_role_exists >/dev/null 2>&1; then
      force_cleanup_role
    fi

    if check_policy_exists >/dev/null 2>&1; then
      force_cleanup_policies
    fi

    # Final verification after force cleanup
    echo ""
    echo "--- Final verification after force cleanup ---"
    STILL_REMAINING=false

    if check_role_exists >/dev/null 2>&1; then
      echo "  STILL EXISTS: Role '$ROLE_NAME'"
      STILL_REMAINING=true
    else
      echo "  GONE: Role '$ROLE_NAME'"
    fi

    if check_profile_exists >/dev/null 2>&1; then
      echo "  STILL EXISTS: Instance profile '$PROFILE_NAME'"
      STILL_REMAINING=true
    else
      echo "  GONE: Instance profile '$PROFILE_NAME'"
    fi

    if check_policy_exists >/dev/null 2>&1; then
      echo "  STILL EXISTS: Policies matching '$POLICY_PREFIX'"
      STILL_REMAINING=true
    else
      echo "  GONE: No policies matching '$POLICY_PREFIX'"
    fi

    if [ "$STILL_REMAINING" = "true" ]; then
      echo ""
      echo "ERROR: Force cleanup failed - resources still remain"
      echo "force_cleaned=partial" >> "$GITHUB_OUTPUT"
      exit 1
    else
      echo ""
      echo "Force cleanup succeeded - all resources removed"
      echo "force_cleaned=true" >> "$GITHUB_OUTPUT"
      exit 0
    fi
  else
    echo ""
    echo "Set FORCE_CLEANUP=true to attempt manual deletion"
    echo "force_cleaned=false" >> "$GITHUB_OUTPUT"
    exit 1
  fi
else
  echo "All resources confirmed deleted"
  echo "force_cleaned=false" >> "$GITHUB_OUTPUT"
  exit 0
fi
