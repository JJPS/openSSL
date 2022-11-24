#!/bin/bash
#
# SCRIPT AUTENTICAR CLIENTE CONTRA WEB SEGURA
#
echo "SOLICITAR CERTIFICADO CLIENTE AUTENTICACIÓN CONTRA WEB"
echo "---------------Se configura /CN=<nombre alumno>"
echo "ENVIAR PETICION A CA"

echo "GENERAR FICHERO DE CONFIGURACIÓN"

echo "FIRMAR CERTIFICADO"

echo "CONVERTIR CERTIFICADO A FORMATO PKCS12"

echo "ENVIAR AMBOS CERTIFICADOS A CLIENTE"

echo "MODIFICAR FICHERO /etc/apache2/sites-available/defalul-ssl.conf "
echo " - AGREGAR LA VERIFICACION SSL DEL CLIENTE"
echo "--------------descomentar línea SSLVerifyClient require"
echo " - AGREGAR CLAVE PUBLICA DE LA CA"
echo "--------------copiar cacert.pem al directorio adecuado"
echo "--------------SSLCACertificateFile /etc/apache2/ssl.crt/cacert.pem"
echo "REINICIAR APACHE"

echo "AGREGAR CERTIFICADO CLIENTE A NAVEGADOR"
echo "ACCEDER A LA WEB SEGURA"
