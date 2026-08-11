resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "dvn-ecs-service-cpu-alarm-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2 # Should be more slower than up alarm, to avoid scaling down too fast
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 10
  statistic           = "Average"
  threshold           = 55
  insufficient_data_actions = []
  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_description = "This metric monitors ECS service CPU utilization"
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "dvn-ecs-service-cpu-alarm-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 10
  statistic           = "Average"
  threshold           = 60
  insufficient_data_actions = []
  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.this.name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_description = "This metric monitors ECS service CPU utilization"
}