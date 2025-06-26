output "alb_arn" {
  value       = aws_lb.app.arn
  description = "ALB ARN"
}
