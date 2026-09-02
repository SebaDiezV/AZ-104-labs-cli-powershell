# AZ-104 Labs - Lab 09c: Implement Azure Container Apps

## Objetivo
Implementar y desplegar aplicaciones de contenedores de Azure

## Fuente
Basado en [Lab 09c: Implement Azure Container Apps](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_09c-Implement-Azure-Container-Apps.html)

## Recursos creados
- Crear y configurar una aplicación y un entorno de contenedores de Azure
  
## Notas y aprendizaje
Para poder realizar este laboratorio es necesario registrar el proveedor Azure Container Apps Microsoft.App y el de área de trabajo de log analytics Microsoft.OperationalInsights, en los scripts se deja el comando para el registro en ambas líneas de comandos.

Para Azure CLI es necesario también instalar la extensión de Azure Container Apps.

PowerShell no posee cmdlets propios para trabajar con container apps, por lo que se debe instalar el modulo Az.App para utilizar Azure CLI en PowerShell.