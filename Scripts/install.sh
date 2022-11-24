#!/bin/bash
#
# SCRIPT RESOLUCION PRACTICA SERVIDORES WEB SEGUROS
#
echo "ACTUALIZAR REPOSITORIOS"
apt update
echo "INSTALAR nano"
apt install nano -y
echo "INSTALAR openssl"
apt install openssl -y
echo "INSTALAR apache2"
apt install apache2 -y
echo "LEVANTAR SERVICIO http"
service apache2 start
echo "HABILITAR MODULO SSL APACHE2"
a2enmod ssl
echo "REINICIAR APACHE2"
service apache2 restart
echo "GENERAR LA INFRAESTRUCTURA DE LA CA"
mkdir -p /home/install 2 > /dev/null
cd /home/install
mkdir -p demoCA 2 > /dev/null
mkdir -p demoCA/certs 2 > /dev/null
mkdir -p demoCA/crl 2 > /dev/null
touch demoCA/index.txt > /dev/null
echo "C000" > demoCA/serial 
mkdir demoCA/newcerts /dev/null
mkdir demoCA/private /dev/null
echo "CREAR LA CLAVE PRIVADA DE LA CA Raiz + CERTIFICADO RAIZ"
openssl req -new -x509 -keyout demoCA/private/cakey.pem -subj "/C=ES/ST=Melilla/L=Melilla/O=Ciber Queipo/OU=FPIC/CN=CA Raiz/emailAddress=fpic@queipo.ies" -passout pass:1234 -out demoCA/cacert.pem
echo "CREAR INFRAESTRUCTURA EMPRESA"
mkdir -p /home/install/empresa 2 > /dev/null
cd /home/install/empresa
echo "CREAR CLAVE PRIVADA EMPRESA"
openssl genrsa -des3 -passout pass:1234 -out user_priv_key.pem 2048
echo "SOLICITAR CERTIFICADO WEB"
openssl req -new -key user_priv_key.pem -passin pass:1234 -subj "/C=ES/ST=Melilla/L=Melilla/O=Ciber Queipo/OU=FPIC/CN=*.queipo.ies/emailAddress=fpic@queipo.ies" -out web_cert.pem
echo "ENVIAR PETICION CERTIFICADO A AC"
mkdir -p /home/install/demoCA/tmp 2 > /dev/null
cd /home/install/demoCA/tmp
mv /home/install/empresa/web_cert.pem .
echo "CREAR FICHERO DE CONFIGURACION CERTIFICACION WEB"
touch config_web.cfg
echo "[ my_extensions ]">config_web.cfg
echo "basicConstraints = critical, CA:FALSE">>config_web.cfg
echo "extendedKeyUsage = critical, serverAuth">>config_web.cfg
echo "FIRMAR PETICION CERTIFICADO WEB SHA512"
openssl x509 -CA ../cacert.pem -CAkey ../private/cakey.pem -passin pass:1234 -req -in ./web_cert.pem -days 3650 -extfile ./config_web.cfg -sha512 -CAserial ../serial -out webCertificate.pem
echo "ENVIAR DE CERTIFICADO FIRMADO A EMPRESA"
mv webCertificate.pem /home/install/empresa
echo "COPIAR CERTIFICADOS A LUGAR ACCESIBLE POR APACHE"
cd /home/install/empresa/
cp webCertificate.pem /etc/ssl/certs/
cp user_priv_key.pem /etc/ssl/private/
echo "MODIFICAR /etc/apache2/sites-availables/default-ssl.conf"
echo "PARA INDICAR DONDE ESTAN LOS CERTIFICADOS"
cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.seg
sed -i '34i SSLCertificateFile	/etc/ssl/certs/webCertificate.pem' /etc/apache2/sites-available/default-ssl.conf
sed -i '35i SSLCertificateKeyFile	/etc/ssl/private/user_priv_key.pem' /etc/apache2/sites-available/default-ssl.conf
sed -i '32d' /etc/apache2/sites-available/default-ssl.conf
sed -i '32d' /etc/apache2/sites-available/default-ssl.conf
echo "CREAR ENLACE SIMBOLICO DE LA PÁGINA SEGURA"
cd /etc/apache2/sites-enabled
ln -s ../sites-available/default-ssl.conf 001-default.conf
echo "REINICIAR APACHE"
cd /home/install 
service apache2 restart
