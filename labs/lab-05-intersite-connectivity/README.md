# AZ-104 Labs - Lab 05: Implement Intersite Connectivity

## Objetivo
Aprender los fundamentos de las redes virtuales y subneting, proteger la red con NSG y ASG, registros y zonas DNS 

## Fuente
Basado en [Lab 05: Implement Intersite Connectivity](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_05-Implement_Intersite_Connectivity.html)

## Recursos creados
- Crear máquinas virtuales en dos redes diferentes
- Utilizar Network Watcher para probar la conexión entre máquinas virtuales
- Configurar emparejamiento de redes virtuales
- Probar la conexión entre las maquinas virtuales a través de Azure PowerShell
- Crear una ruta personalizada

## Notas y aprendizaje
Si bien el laboratorio indica un tipo de imagen y tamaño de hardware para la VM, se debe revisar que estos se encuentren disponibles en la región en la cual se esta trabajando, además hay que considerar la compatibilidad de generación del hipervisor de las imágenes y tamaño de hardware, no se pueden mezclar, esto es de espacial cuidado ya que las nuevas familias de computo, como la familia v7, eliminaron el soporte heredado para la generación 1 y son estrictamente generación 2. Azure asume de forma predeterminada que se va a trabajar con una maquina de generación 1 a menos que se le pasen parámetros de seguridad avanzada, es por eso que se pasó el tipo de seguridad como Trusted Launch, lo que obligó a Azure a activar el entorno seguro UEFI, desbloqueando la compatibilidad con el tamaño de hardware v7.

Al trabajar a través de línea de comando, se debe instalar una extensión de Network Watcher en ambas VM's para probar la conectividad.

## Problemas encontrados y solución
- Cambio de imagen de sistema operativo
```Azure CLI
     --image MicrosoftWindowsServer:windowsserver2022:2022-datacenter-g2:latest
``` 
```PowerShell
     -Image MicrosoftWindowsServer:windowsserver2022:2022-datacenter-g2:latest
```
- Cambio de tamaño de hardware
```Azure CLI
     --size Standard_D2s_v7
``` 
```PowerShell
     -Size Standard_D2s_v7
```
- Cambio de tipo de seguridad
```Azure CLI
    --security-type TrustedLaunch
```  
```PowerShell
    -SecurityType TrustedLaunch
```  