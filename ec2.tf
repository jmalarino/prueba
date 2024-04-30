resource "aws_instance" "jmalarinoPri_ec2" {
  ami                    = "ami-0c101f26f147fa7fd" #AMAZON LINUX
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.jmalarino_privada.id
  key_name   = "jmalarino_key"

  tags = {
    Name = "instancia_privada"
  }
}

 # Creación del grupo de seguridad para las instancias públicas
resource "aws_security_group" "public_instances_sg" {
  name        = "public_instances_sg"
  description = "Grupo de seguridad para instancias publicas"

  vpc_id = aws_vpc.jmalarino_vpc.id

  # Regla para permitir el acceso al ping (ICMP)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla para permitir el acceso SSH (puerto 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "jmalarinoPub_ec2" {
  ami                    = "ami-0c101f26f147fa7fd" #AMAZON LINUX
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.jmalarino_publica.id
  associate_public_ip_address = true
  key_name   = "jmalarino_key"

  tags = {
    Name = "instancia_publica"
  }
}

# Asociación del grupo de seguridad a la instancia EC2 pública
resource "aws_security_group_rule" "public_instances_sg_rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.public_instances_sg.id
  cidr_blocks      = ["0.0.0.0/0"]

  # Asociar a la instancia EC2 una vez que esté disponible
  depends_on        = [aws_instance.jmalarinoPub_ec2] #Es para que terraform no intente asociar el SG antes de que exista la instancia porque sino fallaba.
}