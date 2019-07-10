# Alerts(Classic) will be retired on June 30th. - awaiting Terraform update

resource "azurerm_monitor_metric_alertrule" "cpu" {
  name                                      = "${var.name}-cpu"
  resource_group_name                       = "${var.name}-rg"
  location                                  = "${var.location}"
  description                               = "An alert rule to watch the metric Percentage CPU"
  tags                                      = "${var.tags}"

  enabled                                   = true
  resource_id                               = ["${element(azurerm_virtual_machine.dmz.*.id, count.index)}"]
  metric_name                               = "Percentage CPU"
  operator                                  = "GreaterThan"
  threshold                                 = 75
  aggregation                               = "Average"
  period                                    = "PT5M"

  email_action {
    send_to_service_owners                  = false

    custom_emails = [
      "some.user@example.com",
    ]
  }

  webhook_action {
    service_uri = "https://example.com/some-url"

    properties = {
      severity        = "incredible"
      acceptance_test = "true"
    }
  }
}