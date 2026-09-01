##Conectar  a Azure a través del modulo Az de PowerShell
Connect-AzAccount

##Crear grupo de recursos
New-AzResourceGroup -Name az104-rg8 -Location eastus

##Implementar máquinas virtuales de Azure resistentes a zonas
$credential = Get-Credential
New-AzVm `
    -ResourceGroupName az104-rg8 `
    -Name az104-vm1 `
    -Location eastus `
    -Image MicrosoftWindowsServer:windowsserver2022:2022-datacenter-g2:latest `
    -Size Standard_D2s_v7 `
    -SecurityType TrustedLaunch `
    -Credential $credential `
    -Zone 1

New-AzVm `
    -ResourceGroupName az104-rg8 `
    -Name az104-vm2 `
    -Location eastus `
    -Image MicrosoftWindowsServer:windowsserver2022:2022-datacenter-g2:latest `
    -Size Standard_D2s_v7 `
    -SecurityType TrustedLaunch `
    -Credential $credential `
    -Zone 2

##Gestionar el escalado de computación y almacenamiento para máquinas virtuales
#detener VM
Stop-AzVm -ResourceGroupName az104-rg8 -Name az104-vm1

#obtener la VM en una variable
$vm = Get-AzVm -ResourceGroupName az104-rg8 -Name az104-vm1

#asignar nuevo tamaño en la propiedad del hardware
$vm.HardwareProfile.VmSize = 'Standard_D2ds_v7'

#actualizar VM
Update-AzVm -VM $vm -ResourceGroupName az104-rg8

#crear nuevo disco de datos y agregarlo a vm detenida
#crear las variables necesarias
$vmName = 'az104-vm1'
$diskName = 'vm-disk1'

#crear configuración del disco de datos
$diskConfig = New-AzDiskConfig `
    -Location eastus `
    -CreateOption Empty `
    -DiskSizeGB 32 `
    -SkuName Standard_LRS `
    -Zone 1

$disk = New-AzDisk `
    -ResourceGroupName az104-rg8 `
    -DiskName $diskName `
    -Disk $diskConfig


#Actualizar la variable de la VM y agregar el disco de datos
$vm = Get-AzVm -ResourceGroupName az104-rg8 -Name $vmName
$vm = Add-AzVMDataDisk `
    -VM $vm `
    -Name $diskName `
    -CreateOption Attach `
    -ManagedDiskId $disk.Id `
    -Lun 1

#Actualizar VM
Update-AzVm -VM $vm -ResourceGroupName az104-rg8

##Limpiar los recursos
Remove-AzResourceGroup az104-rg8