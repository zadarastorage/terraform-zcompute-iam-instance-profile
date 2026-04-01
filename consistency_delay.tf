# Optional delays for IAM eventual consistency.
#
# The IAM API may reject create calls with "already used" for several
# minutes after a successful delete due to eventual consistency between
# the read and write paths.
#
# destroy_delay_seconds: waits after IAM resources are destroyed, giving
#   the backend time to fully purge before terraform exits. Helps ensure
#   the next apply succeeds without intervention.
#
# create_delay_seconds: waits before creating IAM resources, for cases
#   where a prior destroy did not include a destroy delay.

resource "time_sleep" "consistency_delay" {
  count            = (var.create_delay_seconds > 0 || var.destroy_delay_seconds > 0) ? 1 : 0
  create_duration  = var.create_delay_seconds > 0 ? "${var.create_delay_seconds}s" : "0s"
  destroy_duration = var.destroy_delay_seconds > 0 ? "${var.destroy_delay_seconds}s" : "0s"
}
