output "load_balancer_dns" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.web_alb.dns_name
}