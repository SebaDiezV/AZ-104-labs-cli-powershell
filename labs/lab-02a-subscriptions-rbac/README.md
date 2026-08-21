# AZ-104 Labs - Lab 02a: Manage Subscriptions and RBAC

## Objetivo
Crear Management Group, asignar roles de RBAC a grupos, crear un rol de RBAC personalizado y supervisar el registro de actividad.

## Fuente
Basado en [Lab 02 - Manage Subscriptions and RBAC](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_02a_Manage_Subscriptions_and_RBAC_Entra.html)

## Recursos creados
- Management Groups
- Grupos de Seguridad
- JSON para rol RBAC personalizado
- Rol RBAC personalizado

## Notas y aprendizaje
Se realiza el laboratorio con ambas líneas de comandos, en esta ocasión, tanto en Azure CLI como en PowerShell fue mas directo realizar los comandos, aunque fue un poco confuso en PowerShell pasar del módulo Az a MgGraph, sin embargo, trabajando de manera estructurada no presenta mayor dificultad.

PowerShell sigue siendo mucho mas fácil trabajar, hay una gran diferencia en como obtener los ID tanto del grupo de seguridad como del Management Group, igual que asignar el rol al grupo de seguridad.

Mientras que para Azure CLI tuve que crear el archivo JSON de forma manual y copiar y pegar la información que va adentro para poder crear el rol RBAC personalizado, en PowerShell pude crear el JSON desde la mima línea de comando copiando el rol de reader y luego editar el Scope.

En cuanto al comando para la revisión de logs, es mas sencillo y mas fácil de recordar el comando de PowerShell.

## Problemas encontrados y solución
- Un problema que encontré fue el uso de la ruta absoluta para llamar al archivo JSON al crear el rol RBAC personalizado, si bien funcionó, CLI debiese poder llamar al archivo con @nombre_archivo.json, esto debido a un Quoting Issue que es un problema especifico entre Azure CLI + PowerShell + JSON, a pesar de estar documentado por Microsoft, no pude realizar esa mejora.