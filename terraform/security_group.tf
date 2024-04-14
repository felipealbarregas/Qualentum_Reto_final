resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.my_vpc.id

  # Reglas de seguridad para permitir acceso a SSH (puerto 22) y Jenkins (puerto 8080)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Regla de egress por defecto para permitir todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Instance-Security-Group"
  }
}
