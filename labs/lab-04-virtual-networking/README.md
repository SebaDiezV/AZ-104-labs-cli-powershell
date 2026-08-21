# AZ-104 Labs - Lab 04: Implement Virtual Networking

## Objetivo
Aprender los fundamentos de las redes virtuales y subneting, proteger la red con NSG y ASG, registros y zonas DNS 

## Fuente
Basado en [Lab 04: Implement Virtual Networking](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_04-Implement_Virtual_Networking.html)

## Recursos creados
- Resource Group
- VNet y dos subnets
- VNet y dos subnets con ARM Templates
- Network Security Group
- Application Security Group
- Registros DNS público y privado

## Notas y aprendizaje
Al trabajar en VNets con ambas lineas de comando, me llamo la atención que en Azure CLI se pueda crear una VNet con solo una subnet con el comando az network vnet create  y la segunda subnet deb crearse aparte, al contrario de PowerShell, que puedes crear las dos subnets en el mismo comando donde creas la VNet.

En ambas líneas, una vez creados el NSG y el ASG, se debe actualizar las VNet's para asignarlas, no se pueden asignar en el mismo comando.

Mientras que Azure CLI basta con crear las reglas de Inbound y Outbound directo en el NSG, en PowerShell es necesario pasarlo a través de pipes para agregar las reglas y luego actualizar el NSG.

