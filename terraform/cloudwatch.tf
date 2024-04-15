resource "aws_cloudwatch_metric_alarm" "request_count_alarm" {
  alarm_name          = "Production_Request_Count_Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "peticiones"  
  namespace           = "MyApp/Metrics" 
  period              = 60
  statistic           = "Sum"
  threshold           = 10  # Umbral para activar la alarma, ajusta según sea necesario
  alarm_description   = "This alarm is triggered when the request count exceeds 10 in production environment."
  
  dimensions = {
    ApplicationName = "app"  
    Environment     = "production"
  }
  
  alarm_actions = ["arn:aws:sns:us-west-2:123456789012:ScaleUpTopic"]  # Acción a tomar cuando se active la alarma
}
