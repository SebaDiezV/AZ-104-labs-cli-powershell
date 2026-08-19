# AZ-104 Labs - Lab 03: Manage Azure resources by using Azure Resource Manager Templates

## Objetivo
Automatizar la implementación de recursos utilizando ARM Templates y Bicep

## Fuente
Basado en [Lab 03 - Manage Azure resources by using Azure Resource Manager Templates](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_03b-Manage_Azure_Resources_by_Using_ARM_Templates.html)

## Recursos creados
- Disco duro administrado
- Archivo Template
- Archivo Parameters
- Disco duro administrado con ARM Template a través de Azure CLI
- Disco duro administrado con ARM Template a través de PowerShell
- Disco duro administrado con Bicep Template a través de Azure CLI
- Disco duro administrado con Bicep Template a través de PowerShell

## Notas y aprendizaje

Para este laboratorio se trabajó la primera parte en el portal de Azure, siguiendo los pasos indicados para generar las ARM Templates, el resto de pasos fue realizado en VSCode, instalando la extensión de Bicep, se trabaja con un set distinto de archivos JSON de parameters y template ARM para cada línea de comando y el archivo Bicep se trabajo en una ubicación centralizada con ambas líneas de comando.

## Problemas encontrados y solución

- Para poder utilizar la plantilla Bicep en PowerShell fue necesario realizar adicionalmente la instalación de herramientas Bicep a través de Winget
```powershell
     winget install -e --id Microsoft.Bicep
``` 
