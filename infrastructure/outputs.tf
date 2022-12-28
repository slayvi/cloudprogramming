# Prints the URL to the command line:
output "load_balancer_ip" {
    description = "The Application can be accessed at the following link in just some minutes:"
    value = aws_lb.default.dns_name
}