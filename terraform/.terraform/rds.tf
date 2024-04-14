resource "aws_db_subnet_group" "my_database_subnet_group" {
  name        = "my-database-subnet-group"
  subnet_ids  = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id]
}

resource "aws_db_instance" "my_database" {
  identifier            = "my-database"
  engine                = "postgres"
  instance_class        = "db.t2.small"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine_version        = "12.7"
  username              = "admin"
  password              = "password"
  publicly_accessible  = false

  # Conectando la instancia al VPC y subredes existentes
  vpc_security_group_ids = [aws_security_group.my_database_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.my_database_subnet_group.name
  
  # Configuración de la copia de seguridad automatizada
  backup_retention_period = 7
  backup_window           = "22:00-03:00"
}
