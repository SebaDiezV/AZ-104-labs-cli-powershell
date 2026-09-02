# AZ-104 Labs - Lab 09b: Implement Azure Container Instances

## Objetivo
Implementar y desplegar Instancias de contenedores de Azure

## Fuente
Basado en [Lab 09b: Implement Azure Container Instances](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_09b-Implement_Azure_Container_Instances.html)

## Recursos creados
- Container Instance con imagen Docker
  
## Notas y aprendizaje
Para poder realizar este laboratorio es necesario registrar el proveedor de recursos de instancias de contenedores Microsoft.ContainerInstance, en los scripts se deja el comando para el registro en ambas líneas de comandos.

A través de CLI la configuración de la instancia de contenedor tiene un solo paso con el comando az container create, mientras que en PowerShell la tarea se subdivide en tres pasos antes de lograr la creación de la instancia.