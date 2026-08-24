##Conectar  a Azure a través del modulo Az de PowerShell
Connect-AzAccount

##Crear un grupo de recursos
New-AzResourceGroup -Name az104-rg5 -Location eastus

##Crear una máquina virtual y una red virtual para los servicios principales
#crear las variables con la información para crear la VNet y la subnet
$vnetName ='CoreServicesVnet'
$vnetAddressPrefix = '10.0.0.0/16'
$subnetName = 'Core'
$subnetPrefix = '10.0.0.0/24'

#crear la configuración de subnet
$subnet = New-AzVirtualNetworkSubnetConfig `
    -Name $subnetName `
    -AddressPrefix $subnetPrefix

#crear la VNet
New-AzVirtualNetwork `
    -Name $vnetName `
    -ResourceGroupName az104-rg5 `
    -Location eastus `
    -AddressPrefix $vnetAddressPrefix `
    -Subnet $subnet

#revisar sku's de tamaños de VM disponibles
Get-AzComputeResourceSku -Location eastus | Where-Object { $_.ResourceType -eq "virtualMachines" }

#crear la VM en la subnet Core
$credential = Get-Credential
New-AzVm `
    -ResourceGroupName az104-rg5 `
    -Name CoreServicesVM `
    -Location eastus `
    -Image MicrosoftWindowsServer:windowsserver2022:2022-datacenter-g2:latest `
    -VirtualNetworkName CoreServicesVnet `
    -SubnetName Core `
    -Size Standard_D2s_v7 `
    -Credential $credential `
    -SecurityType TrustedLaunch

##Crear una máquina virtual en una red virtual diferente
#crear las variables con la información para crear la VNet y la subnet
$vnet2Name ='ManufacturingVnet'
$vnet2AddressPrefix = '172.16.0.0/16'
$subnet2Name = 'Manufacturing'
$subnet2Prefix = '172.16.0.0/24'

#crear la configuración de subnet
$subnet2 = New-AzVirtualNetworkSubnetConfig `
    -Name $subnet2Name `
    -AddressPrefix $subnet2Prefix

#crear la VNet
New-AzVirtualNetwork `
    -Name $vnet2Name `
    -ResourceGroupName az104-rg5 `
    -Location eastus `
    -AddressPrefix $vnet2AddressPrefix `
    -Subnet $subnet2

#crear la VM en la subred Manufacturing, se usaran las mismas credenciales usadas anteriormente, por lo que no se necesario volver a ejecutar Get-Credential
New-AzVm `
    -ResourceGroupName az104-rg5 `
    -Name ManufacturingVM `
    -Location eastus `
    -Image MicrosoftWindowsServer:windowsserver2022:2022-datacenter-g2:latest `
    -VirtualNetworkName ManufacturingVnet `
    -SubnetName Manufacturing `
    -Size Standard_D2s_v7 `
    -Credential $credential `
    -SecurityType TrustedLaunch

##Utilice Network Watcher para probar la conexión entre máquinas virtuales
#obtener recurso de NetworkWatcher y la VM de origen y guardarlos en variables
$nw = Get-AzNetworkWatcher -ResourceGroupName NetworkWatcherRG -Name NetworkWatcher_eastus
$sourceVM = Get-AzVm -ResourceGroupName az104-rg5 -Name CoreServicesVM
$destVM = Get-AzVm -ResourceGroupName az104-rg5 -Name ManufacturingVM


#ejecutar prueba de conexión, el resultado sera error
$connectivityStatus = Test-AzNetworkWatcherConnectivity `
    -NetworkWatcher $nw `
    -SourceId $sourceVM.Id `
    -DestinationId $destVM.Id `
    -DestinationPort 3389

$connectivityStatus | Format-List ConnectionStatus, AvgLatencyInMs, ProbesSent, ProbesFailed
#Resultado de la prueba:
#ConnectionStatus : Unreachable
#AvgLatencyInMs   : 
#ProbesSent       : 316
#ProbesFailed     : 316

## Configurar el emparejamiento de redes virtuales entre redes virtuales
#obtener referencias de ambas VNet y dejarlas en variables
$vnet1 = Get-AzVirtualNetwork -ResourceGroupName az104-rg5 -Name $vnetName
$vnet2 = Get-AzVirtualNetwork -ResourceGroupName az104-rg5 -Name $vnet2Name

#configurar el emparejamiento
Add-AzVirtualNetworkPeering `
    -Name ManufacturingVnet-to-CoreServicesVnet `
    -VirtualNetwork $vnet2 `
    -RemoteVirtualNetworkId $vnet1.Id

Add-AzVirtualNetworkPeering `
    -Name CoreServicesVnet-to-ManufacturingVnet `
    -VirtualNetwork $vnet1 `
    -RemoteVirtualNetworkId $vnet2.Id

#Volver a probar la conexión con Network Watcher
#Resultado de la prueba
#ConnectionStatus : Reachable
#AvgLatencyInMs   : 
#ProbesSent       : 316
#ProbesFailed     : 0

##Utilice Azure PowerShell para probar la conexión entre máquinas virtuales
Invoke-AzVMRunCommand `
    -ResourceGroupName az104-rg5 `
    -VMName CoreServicesVM `
    -CommandId RunPowerShellScript `
    -ScriptString 'Enable-NetFirewallRule -DisplayGroup "Remote Desktop"'

#obtener ip de VM CoreServicesVM
$nic = Get-AzNetworkInterface -ResourceGroupName az104-rg5 -Name CoreServicesVM

$coreVmIp =$nic.IpConfigurations.PrivateIpAddress

#ejecutar script e PowerShell desde ManufacturingVM
Invoke-AzVMRunCommand `
    -ResourceGroupName az104-rg5 `
    -VMName ManufacturingVM `
    -CommandId RunPowerShellScript `
    -ScriptString "Test-NetConnection $coreVmIp -port 3389"

##Crear una ruta personalizada
#crear nueva subred en CoreServicesVnet, se utilizaran variables creadas anteriormente
Add-AzVirtualNetworkSubnetConfig `
    -Name perimeter `
    -AddressPrefix 10.0.1.0/24 `
    -VirtualNetwork $vnet1

Set-AzVirtualNetwork -VirtualNetwork $vnet1

#Crear la tabla de rutas
$route = New-AzRouteConfig `
    -Name rt-CoreServices `
    -AddressPrefix 10.0.0.0/16 `
    -NextHopType VirtualAppliance `
    -NextHopIpAddress 10.0.1.7

$routeTable = New-AzRouteTable `
    -ResourceGroupName az104-rg5 `
    -Location eastus `
    -Name PerimetertoCore `
    -Route $route

#Asociar la tabla de rutas
Set-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet1 `
    -Name perimeter `
    -AddressPrefix 10.0.1.0/24 `
    -RouteTable $routeTable

Set-AzVirtualNetwork -VirtualNetwork $vnet1

##Limpiar recursos
Remove-AzResourceGroup az104-rg5
#Seleccionar Y cuando solicite el prompt