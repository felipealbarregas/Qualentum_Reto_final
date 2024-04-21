terraform {
  required_version = ">= 0.13"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"  # Reemplaza con tu región preferida
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"  
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.0.0/24" 
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.1.0/24" 
  availability_zone = "eu-west-1b"
}

resource "aws_subnet" "public_subnet_1c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.2.0/24" 
  availability_zone = "eu-west-1c"
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1b.id,
    aws_subnet.public_subnet_1c.id
  ]
}

resource "aws_db_subnet_group" "my_database_subnet_group" {
  name       = "my-database-subnet-group"
  subnet_ids = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1b.id,
    aws_subnet.public_subnet_1c.id
  ]
}

resource "aws_db_instance" "my_database" {
  identifier            = "my-database"
  engine                = "postgres"
  instance_class        = "db.t2.small"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine_version        = "16.2"
  username              = "admin"
  password              = "password"
  publicly_accessible  = false



  # Conectando la instancia al VPC y subredes existentes
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.my_database_subnet_group.name
  
  # Configuración de la copia de seguridad automatizada
  backup_retention_period = 7
  backup_window           = "22:00-03:00"
}

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

module "eks_cluster_produccion" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"  

  cluster_name    = "produccion"

  vpc_id          = aws_vpc.my_vpc.id
  subnet_ids      = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1b.id,
    aws_subnet.public_subnet_1c.id
  ]

  eks_managed_node_groups = {
    app = {
      name                 = "app"
      instance_types       = ["t2.small"]
      min_size             = 1
      max_size             = 4
      desired_size         = 1

      scaling_config = {
        scale_down = {
          enabled          = true
          evaluation_periods = 3
          cooldown         = 300
          adjustment_type  = "ChangeInCapacity"
          min_adjustment_magnitude = 1
          type             = "cpu"
          value            = 20
        }
        scale_up = {
          enabled          = true
          cooldown         = 300
          adjustment_type  = "ChangeInCapacity"
          min_adjustment_step = 1
          type             = "ChangeInCapacity"
          value            = 1
        }
      }

      # Especificar variables de entorno para el grupo de nodos
      node_group = {
        environment_variables = {
          DATABASE_URL = aws_db_instance.my_database.endpoint
        }
      }
    }
  }
}

resource "kubectl_manifest" "myapp_deployment" {
  yaml_body = <<-EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: fecendrer/reto_final:app
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer  # Cambiar el tipo de Service a LoadBalancer
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: myapp-service
            port:
              number: 80
EOF

  depends_on = [module.eks_cluster_produccion]
}

resource "aws_route53_zone" "my_zone" {
  name = "retofinal.qualentum"
}

resource "aws_route53_record" "example_record" {
  zone_id = aws_route53_zone.my_zone.zone_id
  name    = "app.retofinal.qualentum"
  type    = "A"
  ttl     = "300"
  records = ["data.aws_lb.eks_ingress_lb.dns_name"]  # Reemplaza con el DNS name de tu load balancer o el valor apropiado
}

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

output "db_instance_endpoint" {
  value = aws_db_instance.my_database.endpoint
}
