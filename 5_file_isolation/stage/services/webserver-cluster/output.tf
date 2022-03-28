output "loadbalancer_dns_name" {
    value = aws_lb.loadbalancer_example.dns_name
    description = "The public dns name for the loadbalancer"
}