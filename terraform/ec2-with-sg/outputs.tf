output "IPv4Address" {
  description = "Public IP of created EC2"
  value       = aws_instance.ec2-demo_tf.public_ip
}
