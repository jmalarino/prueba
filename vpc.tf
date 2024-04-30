# Creación de la VPC (Virtual Private Cloud)
resource "aws_vpc" "jmalarino_vpc" {
  cidr_block       = "10.0.0.0/16" 
  instance_tenancy = "default"      
 
  # Etiquetas para identificar la VPC
  tags = {
    Name = "jmalarino_vpc"
  }
}

# Creación de la subred pública
resource "aws_subnet" "jmalarino_publica" {
  vpc_id            = aws_vpc.jmalarino_vpc.id
  cidr_block        = "10.0.1.0/24"       
  availability_zone = "us-east-1a" 
 
  # Etiqueta para identificar la subred pública
  tags = {
    Name = "red_publica"
  }
}

# Creación de la subred privada
resource "aws_subnet" "jmalarino_privada" {
  vpc_id            = aws_vpc.jmalarino_vpc.id  
  cidr_block        = "10.0.2.0/24"       
  availability_zone = "us-east-1b" 
 
  # Etiqueta para identificar la subred privada
  tags = {
    Name = "red_privada"
  }
}

# Creación de la puerta de enlace de Internet
resource "aws_internet_gateway" "jmalarino_igw" {
  vpc_id = aws_vpc.jmalarino_vpc.id 
}

# Creación de la dirección IP elástica (Elastic IP)
resource "aws_eip" "jmalarino_eip" {
  vpc = true  
}

# Creación de la puerta de enlace NAT (Network Address Translation)
resource "aws_nat_gateway" "jmalarino_nat_gateway" {
  allocation_id = aws_eip.jmalarino_eip.id
  subnet_id     = aws_subnet.jmalarino_publica.id
}

# Creación de la tabla de ruteo para la subred pública
resource "aws_route_table" "jmalarino-publica-rt" {
    vpc_id = aws_vpc.jmalarino_vpc.id

      tags = {
    Name = "tabla_publica"
  }
}

# Creación de la tabla de ruteo para la subred privada
resource "aws_route_table" "jmalarino-privada-rt" {
  vpc_id = aws_vpc.jmalarino_vpc.id

        tags = {
    Name = "tabla_privada"
  }
}

# Creación de la ruta para la subred pública hacia Internet
resource "aws_route" "jmalarino_internet_acceso" {
  route_table_id         = aws_route_table.jmalarino-publica-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.jmalarino_igw.id
}

# Creación de la ruta para la subred privada hacia Internet a través de la puerta de enlace NAT
resource "aws_route" "jmalarino_internet_salida" {
  route_table_id         = aws_route_table.jmalarino-privada-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.jmalarino_nat_gateway.id
}

# Asociación de la tabla de ruteo de la subred pública a la subred pública
resource "aws_route_table_association" "jmalarino_publica_association" {
  subnet_id      = aws_subnet.jmalarino_publica.id
  route_table_id = aws_route_table.jmalarino-publica-rt.id
}

# Asociación de la tabla de ruteo de la subred privada a la subred privada
resource "aws_route_table_association" "jmalarino_privada_association" {
  subnet_id      = aws_subnet.jmalarino_privada.id
  route_table_id = aws_route_table.jmalarino-privada-rt.id
}