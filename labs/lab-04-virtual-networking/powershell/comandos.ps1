##Conectar  a Azure a través del modulo Az de PowerShell
Connect-AzAccount

##Crear un grupo de recursos
New-AzResourceGroup -Name az104-rg4 -Location eastus

##Crear una VNet con sus subredes
#crear las variables con la información
$vnetName = 'CoreServicesVnet'
$vnetAddressPrefix = '10.20.0.0/16'
$subnet1Name = 'SharedServicesSubnet'
$subnet1Prefix = '10.20.10.0/24'
$subnet2Name = 'DatabaseSubnet'
$subnet2Prefix = '10.20.20.0/24'

#crear las configuraciones de las subnets
$subnet1 = New-AzVirtualNetworkSubnetConfig -name $subnet1Name -AddressPrefix $subnet1Prefix
$subnet2 = New-AzVirtualNetworkSubnetConfig -name $subnet2Name -AddressPrefix $subnet2Prefix

#crear la VNet con ambas subredes
New-AzVirtualNetwork `
    -Name $vnetName `
    -ResourceGroupName az104-rg4 `
    -Location eastus `
    -AddressPrefix $vnetAddressPrefix `
    -Subnet $subnet1, $subnet2

##Descargar Template y Parameters de VNet desde portal, editarlos para crear la nueva VNet según laboratorio
##Implementar Template de VNet
#crear variables con Template y Parameters
$PsTemplate = 'C:\<tu_ruta>\template.json'
$PsParameters = 'C:\<tu_ruta>\parameters.json'

#implementar VNet
New-AzResourceGroupDeployment `
    -ResourceGroupName az104-rg4 `
    -TemplateFile $PsTemplate `
    -TemplateParameterFile $PsParameters

##Crear y configurar la comunicación entre un Grupo de seguridad de aplicaciones y un Grupo de seguridad de red
#crear Application Security Group ASG
New-AzApplicationSecurityGroup `
    -ResourceGroupName az104-rg4 `
    -Name asg-web `
    -Location eastus

#Crear Network Security Group NSG
New-AzNetworkSecurityGroup `
    -ResourceGroupName az104-rg4 `
    -Name  myNSGSecure `
    -Location eastus

#asociar NSG a subnet
#guardar en variables la VNet y NSG
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName az104-rg4 -Name myNSGSecure
$vnet = Get-AzVirtualNetwork -ResourceGroupName az104-rg4 -Name CoreServicesVnet

#configurar la subred al nsg - reutilizar variables ya creadas
Set-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name $subnet1Name `
    -AddressPrefix $subnet1Prefix `
    -NetworkSecurityGroup $nsg

#guardar los cambios en la VNet
Set-AzVirtualNetwork -VirtualNetwork $vnet

#crear regla para permitir tráfico Inbound de ASG
#obtener ASG y guardarlo en una variable
$asg = Get-AzApplicationSecurityGroup -ResourceGroupName az104-rg4 -Nam asg-web

$nsg | Add-AzNetworkSecurityRuleConfig `
    -Name AllowASG `
    -Access Allow `
    -protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceApplicationSecurityGroup $asg `
    -SourcePortRange '*' `
    -DestinationAddressPrefix '*' `
    -DestinationPortRange @('443', '80') | Set-AzNetworkSecurityGroup

#configurar regla NSG de salida que deniegue el acceso a Internet
$nsg | Add-AzNetworkSecurityRuleConfig `
    -Name 'DenyInternetOutbound' `
    -Access Deny `
    -Protocol * `
    -Direction Outbound `
    -Priority 4096 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix Internet `
    -DestinationPortRange * | Set-AzNetworkSecurityGroup

##Configurar las zonas DNS públicas y privadas de Azure
#DNS Público
New-AzDnsZone -Name 'az104test.xyz' -ResourceGroupName az104-rg4

#agregar registro A
New-AzDnsRecordSet `
    -ResourceGroupName az104-rg4 `
    -ZoneName 'az104test.xyz' `
    -Name 'www' `
    -RecordType 'A' `
    -Ttl 1 `
    -DnsRecord (New-AzDnsRecordConfig -Ipv4Address 10.1.1.4)

#DNS privado
New-AzPrivateDnsZone -Name 'private.az104test.xyz' -ResourceGroupName az104-rg4

#Guardar VNet ManufacturingVnet en una variable
$vnetManufactoring = Get-AzVirtualNetwork -ResourceGroupName az104-rg4 -Name ManufacturingVnet

#vincular Zona DNS privada a una red virtual
New-AzPrivateDnsVirtualNetworkLink `
    -ResourceGroupName az104-rg4 `
    -ZoneName 'private.az104test.xyz' `
    -Name 'manufacturing-link' `
    -VirtualNetworkId $vnetManufactoring.Id

#agregar registro A a Zona DNS privada
New-AzPrivateDnsRecordSet `
    -Name 'sensorvm' `
    -RecordType 'A' `
    -ZoneName 'private.az104test.xyz' `
    -ResourceGroupName az104-rg4 `
    -Ttl 1 `
    -PrivateDnsRecord (New-AzPrivateDnsRecordConfig -Ipv4Address '10.1.1.4')

##Limpiar recursos
Remove-AzResourceGroup az104-rg4
#Seleccionar Y cuando solicite el prompt