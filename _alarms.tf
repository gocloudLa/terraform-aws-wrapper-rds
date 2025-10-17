locals {
  alarms_default = {
    "warning-CPUUtilization" = {
      description         = "is using more than 75% of CPU"
      threshold           = 75
      unit                = "Percent"
      metric_name         = "CPUUtilization"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      comparison_operator = "GreaterThanThreshold"
      alarms_tags = {
        "alarm-level" = "WARN"
      }
    }
    "critical-CPUUtilization" = {
      description         = "is using more than 90% of CPU"
      threshold           = 90
      unit                = "Percent"
      metric_name         = "CPUUtilization"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      comparison_operator = "GreaterThanThreshold"
      alarms_tags = {
        "alarm-level" = "CRIT"
      }
    }
    "warning-EBSByteBalance" = {
      description         = "is less than 20% of EBSByte"
      threshold           = 20
      unit                = "Percent"
      metric_name         = "EBSByteBalance%"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      evaluation_periods  = 3
      datapoints_to_alarm = 3
      comparison_operator = "LessThanThreshold"
      alarms_tags = {
        "alarm-level" = "WARN"
      }
    }
    "critical-EBSByteBalance" = {
      description         = "is less than 10% of EBSByte"
      threshold           = 10
      unit                = "Percent"
      metric_name         = "EBSByteBalance%"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      evaluation_periods  = 3
      datapoints_to_alarm = 3
      comparison_operator = "LessThanThreshold"
      alarms_tags = {
        "alarm-level" = "CRIT"
      }
    }
    "warning-EBSIOBalance" = {
      description         = "is less than 20% of EBSIO"
      threshold           = 20
      unit                = "Percent"
      metric_name         = "EBSIOBalance%"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      evaluation_periods  = 3
      datapoints_to_alarm = 3
      comparison_operator = "LessThanThreshold"
      alarms_tags = {
        "alarm-level" = "WARN"
      }
    }
    "critical-EBSIOBalance" = {
      description         = "is less than 10% of EBSIO"
      threshold           = 10
      unit                = "Percent"
      metric_name         = "EBSIOBalance%"
      statistic           = "Average"
      namespace           = "AWS/RDS"
      evaluation_periods  = 3
      datapoints_to_alarm = 3
      comparison_operator = "LessThanThreshold"
      alarms_tags = {
        "alarm-level" = "CRIT"
      }
    }
    "warning-ReadLatency" = {
      description         = "ReadLatency p90 above 20 ms for 5 consecutive minutes"
      threshold           = 0.01
      unit                = "Seconds"
      metric_name         = "ReadLatency"
      extended_statistic  = "p90"
      namespace           = "AWS/RDS"
      comparison_operator = "GreaterThanThreshold"
      alarms_tags = {
        "alarm-level" = "WARN"
      }
    }
    "critical-ReadLatency" = {
      description         = "ReadLatency p90 above 20 ms for 5 consecutive minutes"
      threshold           = 0.02
      unit                = "Seconds"
      metric_name         = "ReadLatency"
      extended_statistic  = "p90"
      namespace           = "AWS/RDS"
      comparison_operator = "GreaterThanThreshold"
      alarms_tags = {
        "alarm-level" = "CRIT"
      }
    }
    "warning-WriteLatency" = {
      description         = "WriteLatency p90 above 20 ms for 5 consecutive minutes"
      threshold           = 0.01
      unit                = "Seconds"
      metric_name         = "WriteLatency"
      extended_statistic  = "p90"
      namespace           = "AWS/RDS"
      comparison_operator = "GreaterThanThreshold"
      alarms_tags = {
        "alarm-level" = "WARN"
      }
    }
    "critical-WriteLatency" = {
      description         = "WriteLatency p90 above 20 ms for 5 consecutive minutes"
      threshold           = 0.02
      unit                = "Seconds"
      metric_name         = "WriteLatency"
      extended_statistic  = "p90"
      namespace           = "AWS/RDS"
      comparison_operator = "GreaterThanThreshold"
      alarms_tags = {
        "alarm-level" = "CRIT"
      }
    }
  }
  alarms_tmp = merge([
    for rds_name, values in try(var.rds_parameters, []) : {
      for alarm, value in try(local.alarms_default, {}) :
      "${rds_name}-${alarm}" =>
      merge(
        value,
        {
          alarm_name         = "${split("/", value.namespace)[1]}-${alarm}-${local.common_name}-${rds_name}"
          alarm_description  = "Rds[${rds_name}] ${value.description}"
          actions_enabled    = try(values.alarms_overrides[alarm].actions_enabled, true)
          evaluation_periods = try(values.alarms_overrides[alarm].evaluation_periods, 5)
          threshold          = try(values.alarms_overrides[alarm].threshold, value.threshold)
          period             = try(values.alarms_overrides[alarm].period, 60)
          treat_missing_data = try(values.alarms_overrides[alarm].treat_missing_data, "notBreaching")
          dimensions = try(value.dimensions, {
            DBInstanceIdentifier = "${local.common_name}-${rds_name}"
          })
          ok_actions    = try(value.ok_actions, [])
          alarm_actions = try(value.alarm_actions, [])
          alarms_tags   = merge(try(values.alarms_overrides[alarm].alarms_tags, value.alarms_tags), { "alarm-rds-name" = "${local.common_name}-${rds_name}" })
      }) if can(var.rds_parameters) && var.rds_parameters != {} && try(values.enable_alarms, false) && !contains(try(values.alarms_disabled, []), alarm)
    }
  ]...)

  alarms_custom_tmp = merge([
    for rds_name, values in try(var.rds_parameters, []) : {
      for alarm, value in try(values.alarms_custom, {}) :
      "${rds_name}-${alarm}" => merge(
        value,
        {
          alarm_name         = "${split("/", value.namespace)[1]}-${alarm}-${local.common_name}-${rds_name}"
          alarm_description  = "Rds[${rds_name}] ${value.description}"
          actions_enabled    = try(value.actions_enabled, true)
          statistic          = try(value.statistic, null)
          evaluation_periods = try(value.evaluation_periods, 5)
          extended_statistic = try(value.extended_statistic, null)
          threshold          = value.threshold
          period             = value.period
          treat_missing_data = try("${value.treat_missing_data}", "notBreaching")
          dimensions = try(value.dimensions, {
            DBInstanceIdentifier = "${local.common_name}-${rds_name}"
          })
          ok_actions    = try(value.ok_actions, [])
          alarm_actions = try(value.alarm_actions, [])
          alarms_tags   = merge(try(values.alarms_overrides[alarm].alarms_tags, value.alarms_tags), { "alarm-rds-name" = "${local.common_name}-${rds_name}" })
        }
      ) if can(var.rds_parameters) && var.rds_parameters != {} && try(values.enable_alarms, false)
    }
  ]...)

  alarms = merge(
    local.alarms_tmp,
    local.alarms_custom_tmp
  )


}

/*----------------------------------------------------------------------*/
/* SNS Alarms Variables                                                 */
/*----------------------------------------------------------------------*/

locals {
  enable_alarms_notifications = length(local.alarms) > 0 && try(var.rds_defaults.alarms_defaults.enable_alarms_notifications, true) ? 1 : 0
}

data "aws_sns_topic" "alarms_sns_topic_name" {
  count = local.enable_alarms_notifications
  name  = try(var.rds_defaults.alarms_defaults.alarms_sns_topic_name, "${local.default_sns_topic_name}")
}

/*----------------------------------------------------------------------*/
/* CW Alarms Variables                                                  */
/*----------------------------------------------------------------------*/

resource "aws_cloudwatch_metric_alarm" "alarms" {
  for_each = nonsensitive(local.alarms)

  alarm_name          = try(each.value.alarm_name, var.rds_defaults.alarms_defaults.alarm_name)
  alarm_description   = try(each.value.alarm_description, var.rds_defaults.alarms_defaults.alarm_description, null)
  actions_enabled     = try(each.value.actions_enabled, var.rds_defaults.alarms_defaults.actions_enabled, true)
  comparison_operator = try(each.value.comparison_operator, var.rds_defaults.alarms_defaults.comparison_operator, "GreaterThanOrEqualToThreshold")
  evaluation_periods  = try(each.value.evaluation_periods, var.rds_defaults.alarms_defaults.evaluation_period, 5)
  datapoints_to_alarm = try(each.value.datapoints_to_alarm, var.rds_defaults.alarms_defautls.datapoints_to_alarm, 5)
  threshold           = try(each.value.threshold, var.rds_defaults.alarms_defaults.threshold, null)
  period              = try(each.value.period, var.rds_defaults.alarms_defaults.period, 60)
  unit                = try(each.value.unit, var.rds_defaults.alarms_defaults.unit, null)
  namespace           = try(each.value.namespace, var.rds_defaults.alarms_defaults.namespace, null)
  metric_name         = try(each.value.metric_name, var.rds_defaults.alarms_defaults.metric_name, null)
  statistic           = try(each.value.statistic, var.rds_defaults.alarms_defaults.statistic, null)
  extended_statistic  = try(each.value.extended_statistic, var.rds_defaults.alarms_defaults.extended_statistic, null)
  dimensions          = try(each.value.dimensions, var.rds_defaults.alarms_defaults.dimensions, null)
  treat_missing_data  = try(each.value.treat_missing_data, var.rds_defaults.alarms_defaults.treat_missing_data, "notBreaching")

  alarm_actions = try(each.value.alarm_actions, var.rds_defaults.alarms_defaults.alarm_actions, data.aws_sns_topic.alarms_sns_topic_name[0].arn)
  ok_actions    = try(each.value.ok_actions, var.rds_defaults.alarms_defaults.ok_actions, data.aws_sns_topic.alarms_sns_topic_name[0].arn)

  # conflicts with metric_name
  dynamic "metric_query" {
    for_each = try(each.value.metric_query, var.rds_defaults.alarms_defaults.metric_query, [])
    content {
      id          = lookup(metric_query.value, "id")
      account_id  = lookup(metric_query.value, "account_id", null)
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)
      expression  = lookup(metric_query.value, "expression", null)
      period      = lookup(metric_query.value, "period", null)

      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", [])
        content {
          metric_name = lookup(metric.value, "metric_name")
          namespace   = lookup(metric.value, "namespace")
          period      = lookup(metric.value, "period")
          stat        = lookup(metric.value, "stat")
          unit        = lookup(metric.value, "unit", null)
          dimensions  = lookup(metric.value, "dimensions", null)
        }
      }
    }
  }
  threshold_metric_id = try(each.value.threshold_metric_id, var.rds_defaults.alarms_defaults.threshold_metric_id, null)

  tags = merge(try(each.value.tags, {}), local.common_tags, try(each.value.alarms_tags, {}))
}