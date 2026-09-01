# AZ-104 Labs - Lab 08: Manage Virtual Machines

## Objetivo
crear y comparar máquinas virtuales con conjuntos de escalado de máquinas virtuales. Crear, configurar y redimensionar una sola máquina virtual. Aprenderás a crear un conjunto de escalado de máquinas virtuales y a configurar el autoescalado.

## Fuente
Basado en [Lab 08: Manage Virtual Machines](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_08-Manage_Virtual_Machines.html)

## Recursos creados
- Crear Máquinas Virtuales
- Escalar tamaño de Máquina Virtual
- Escalar tamaño de almacenamiento de Máquinas Virtuales
- Crear y configurar un conjunto de escalado de Máquinas Virtuales
- Configurar autoescalamiento de un conjunto de escalado de Máquinas Virtuales
  
## Notas y aprendizaje
Debido a la dificultad de trabajar con VMSS con Windows Server con la opción de Trusted Launch en PowerShell, se opta por solo dejar realizada la primera parte del laboratio, en cuanto a CLI se logra realizar el laboratorio de manera integra.

Debido a que se esta utilizando una cuenta de prueba de Azure, el uso de vCPU y de IP Pública es limitado, por lo que se recomienda terminadas las partes de VMs del laboratorio eliminar el grupo de recursos para poder realizar la parte de VMSS sin dificultad.
