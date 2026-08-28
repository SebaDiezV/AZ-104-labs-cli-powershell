# AZ-104 Labs - Lab 07: Manage Azure Storage

## Objetivo
Crear, configurar y proteger cuentas de almacenamiento, contenedores y file share.

## Fuente
Basado en [Lab 07: Manage Azure Storage](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_07-Manage_Azure_Storage.html)

## Recursos creados
- Crear un Azure Storage Account y configurar la administración del ciclo de vida de los blobs
- Crear y configurar el almacenamiento seguro de blobs en un Container, configurando la retención basada en tiempo
- Crear y configurar Azure File Storage
- Configurar Service Endpoint de proveedor Microsoft.Storage en VNet
  
## Notas y aprendizaje
Para la configuración de la administración del ciclo de vida de los blobs en un Storage Account, fue necesario utilizar distintas maneras de trabajo dependiendo de la línea de comandos utilizadas, en el caso de Azure CLI fue necesario la creación de un archivo JSON con los parámetros utilizados para la configuración de la política, en cuanto a PowerShell, la política puede ser declarada en variables y ejecutada en un solo comando.

Para la política de retención basada en tiempo y para crear el File Share en PowerShell se trabajo con otro tipo de cmdlets que son los de Plano de Control, AzRm, que son orientados a la administración de la infraestructura y metadatos de los recursos de Azure.

En este momento existen dos versiones de Azure File Share, se trabajó en la clásica que depende del proveedor Microsoft.Storage, por lo que depende de una Storage Account para poder trabajar. A pesar de que no se utilizó en este laboratorio, vale la pena mencionar que la versión nueva trabaja con su propio proveedor, Microsoft.Fileshares, lo que permite crear el recurso de manera independiente.

