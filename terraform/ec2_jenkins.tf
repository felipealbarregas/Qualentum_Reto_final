resource "aws_instance" "jenkins_instance" {
  ami                           = "ami-0c5789c17ae99a2fa" 
  instance_type                 = "t2.micro"               
  subnet_id                     = aws_subnet.public_subnet_1a.id
  associate_public_ip_address   = true 
  security_groups               = [aws_security_group.instance_jenkins.id]  

  tags = {
    Name = "Jenkins-Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y  # Actualiza el sistema operativo
              sudo yum install -y java-1.8.0-openjdk-devel  # Instala Java JDK
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo  # Agrega el repositorio de Jenkins
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key  # Importa la clave GPG de Jenkins
              sudo yum install -y jenkins  # Instala Jenkins
              sudo systemctl daemon-reload  # Recarga systemd
              sudo systemctl enable jenkins  # Habilita el servicio de Jenkins para que se inicie automáticamente en el arranque
              sudo systemctl start jenkins  # Inicia el servicio de Jenkins
              EOF
}

resource "aws_security_group" "instance_jenkins" {
  vpc_id = aws_vpc.my_vpc.id

  # Reglas de seguridad para permitir acceso a SSH (puerto 22) y Jenkins (puerto 8080)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "Instance-Security-Group-jenkins"
  }
}
