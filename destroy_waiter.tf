# Destroy-time waiter for IAM eventual consistency.
#
# The AWS provider does not poll after IAM deletes — it fires the API call,
# gets 200 OK, and moves on. The backend may not have fully processed the
# deletion, causing subsequent creates with the same name to fail with
# "already used/exists".
#
# This resource sits at the bottom of the dependency graph (all IAM
# resources depends_on it). On destroy, IAM resources are deleted first
# (reverse order), then this waiter runs last and polls until the names
# are confirmed gone.
#
# Uses null_resource instead of terraform_data due to known bugs with
# terraform_data destroy provisioners not executing:
# https://github.com/hashicorp/terraform/issues/34711

resource "null_resource" "destroy_waiter" {
  triggers = {
    role_name           = local.role_name
    profile_name        = var.name
    use_existing_role   = tostring(var.use_existing_role)
    use_existing_policy = tostring(var.use_existing_policy)
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "Verifying IAM resources are fully deleted..."

      for i in $(seq 1 30); do
        STILL_EXISTS=false

        if [ "${self.triggers.use_existing_role}" != "true" ]; then
          aws iam get-role --role-name "${self.triggers.role_name}" --no-verify-ssl 2>/dev/null && STILL_EXISTS=true
          aws iam get-instance-profile --instance-profile-name "${self.triggers.profile_name}" --no-verify-ssl 2>/dev/null && STILL_EXISTS=true
        fi

        if [ "$STILL_EXISTS" = "false" ]; then
          echo "IAM resources confirmed deleted after $i checks"
          exit 0
        fi

        echo "Attempt $i/30: resources still present, waiting 5s..."
        sleep 5
      done

      echo "WARNING: IAM resources may not be fully deleted after 150s"
      echo "Subsequent creates with the same names may fail."
      exit 1
    EOT
  }
}
