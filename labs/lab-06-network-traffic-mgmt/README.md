# AZ-104 Labs - Lab 06: Implement Network Traffic Management

## Objetivo
Aprender la configuración y probar el funcionamiento de un Load Balancer Público y un Application Gateway

## Fuente
Basado en [Lab 06: Implement Network Traffic Management](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_06-Implement_Network_Traffic_Management.html)

## Recursos creados
- Implementar infraestructura (VNet's, Subnets y VM's) con ARM Templates
- Crear y configurar un Load Balancer público con su Frontend y Backends
- Crear y configurar un Application Gateway con su Frontend y Backends

## Notas y aprendizaje
el ARM Template proporcionado por Microsoft debe ser editada para poder crear VM's disponibles en la región, por lo que se deb tomar en consideración lo explicado en el laboratorio pasado, se debe agregar el espacio de código para el SecurityProfile en el template y eliminar la redundancia de parámetros de vmSize y adminUserName que trae el archivo Parameters ya que viene hardcodeado en la plantilla de Templates.

Las cuentas de prueba de Azure traen un límite preestablecido de cuantos vCPU se pueden utilizar, siendo un máximo de 4 vCPU's, por lo tanto solo se pueden habilitar dos VM's al mismo tiempo ya que las imágenes disponibles traen como mínimo 2 vCPU's , lo que no alcanza para las 3 VM's que exige el laboratorio, por lo que tuve que eliminar del Template la tercera VM junto con sus dependencias y reutilizar las creadas para la parte de Application Gateway.

Al crear el Application Gateway con Azure CLI, por defecto se crea un Listener en el puerto HTTP el cual no se pudo eliminar por lo que debí actualizarlo con la configuración del ejercicio, al contrario que trabajando en PowerShell, pude configurar todo en variables antes de ejecutar el comando para la creación del Application Gateway. 

Al finalizar el ejercicio de Application Gateway, agregué un mensaje en el index para poder identificar cuando se ingresaba a los Backends de video e imágenes.



## Problemas encontrados y solución

- Agregar porción de SecurityProfile en Template
```
                    "securityProfile": {
                        "securityType": "TrustedLaunch",
                       "uefiSettings": {
                        "secureBootEnabled": true,
                        "vTpmEnabled": true
                }
                },
```

