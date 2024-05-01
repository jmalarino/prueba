# AWS - TERRAFORM

El codigo cuenta con diferentes archivos .tf que se encargan de la generacion de los diferentes recursos.

El objetivo final del mismo es la creacion de una vpc con dos subredes (una publica y una privada), en cada una de esas subredes debemos poner una instancia de EC2, la instancia que este en la subred publica debe ser accesible por SSH desde nuestra maquina local y la que se encuentre en la red privada debe ser accesible desde la instancia EC2 que esta en la red publica tambien por SSH.

Se genera un internet gateway para permitir la entrada y salida desde y hacia internet desde nuestra subred publica y un nat gateway para permitir que nuestra red privada tenga salida a internet.

A su vez se generan 2 buckets S3, uno publico y uno privado con sus respectivos permisos que serviran para alojar archivos, el publico debe poder ser consumido desde nuestra pc y debemos poder compartir archivos entre buckets, los mismos deben ser accesibles para usarlos desde nuestras instancias EC2.

Tambien desplegaremos una registry para poder alojar y administrar imagenes dockerizadas.
 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
main.tf : En este archivo declare el provider y la region que voy a utilizar.

vpc.tf : En este archivo creo la VPC y declaro el espacio de direcciones de red que voy a utilizar.

Luego genero las subredes publicas y privadas, el nat gateway para brindarle salida a internet a la subred privada (lo asocio a la publica para que pueda salir pero luego en la tabla de rutas de la subred privada defino su utilizacion) y el internet gateway para dar entrada y salida a internet a mi subred publica.

Genero las tablas de ruta publica y privada y las asocio a esas subredes respectivamente, en la tabla de rutas publica defino la utilizacion del internet gateway y en la tabla de rutas privada defino la utilizacion del nat gateway.


ec2.tf: En este archivo genero dos instancias ec2, una la asocio a la subred publica y la otra a la subred privada.

Defino la utilizacion de las llaves para cada instancia (en este caso la llave la cree por entorno grafico previamente y en este codigo solamente la asigno para su uso).

Luego creo el security group que oficia como firewall para el acceso al puerto SSH (TCP 22) y permito el protocolo ICMP para poder hacer ping. Lo asigno a la instancia publica (de todos modos hay que revisar el codigo porque la asignacion no esta funcionando y lo resolvi haciendo la asignacion manual del security group por entorno grafico haciendo clic en cada instancia, seguridad y cambiar grupos de seguridad).

*s3.tf*: En este archivo genero los buckets publico y privado y les asocio politicas que permiten todas las acciones sobre ellos y asocio ambos recursos para permitir que compartan archivos entre ellos.

*ecr.tf*: Aqui creo la registry que servira para alojar y administrar mis imagenes dockerizadas y le asocio la politica con los permisos requeridos para poder llevar adelante las acciones de 	administracion de las mismas.

*GetDownloadUrlForLayer*: Obtiene una URL de descarga para una capa específica de una imagen en un repositorio de ECR.

*BatchGetImage*: Obtiene información sobre varias imágenes almacenadas en un repositorio de ECR, como sus metadatos y detalles de la capa.

*BatchCheckLayerAvailability*: Comprueba la disponibilidad de múltiples capas de imagen en un repositorio de ECR.

*PutImage*: Almacena una imagen en un repositorio de ECR. Esto implica cargar la imagen y sus capas asociadas al repositorio.

*InitiateLayerUpload*: Inicia la subida de una nueva capa de imagen al repositorio de ECR.

*UploadLayerPart*: Sube partes de una capa de imagen al repositorio de ECR durante un proceso de carga.

*CompleteLayerUpload*: Finaliza el proceso de carga de una capa de imagen al repositorio de ECR después de que todas las partes hayan sido subidas.
