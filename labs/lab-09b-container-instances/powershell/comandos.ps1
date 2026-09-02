##Conectar a Azure
Connect-AzAccount

##crear grupo de recursos
New-AzResourceGroup -Name az104-rg9b -Location eastus

##Registrar el proveedor de recursos de contenedores
Register-AzResourceProvider -ProviderNamespace Microsoft.ContainerInstance

##Implementar una instancia de contenedor de Azure utilizando una imagen de Docker
#crear puerto para la instancia de contenedor
$port =New-AzContainerInstancePortObject -Port 80 -Protocol TCP

#crear instancia de contenedor
$containerInstance = New-AzContainerInstanceObject `
    -Name az104-c1 `
    -Image mcr.microsoft.com/azuredocs/aci-helloworld:latest `
    -RequestCpu 1 `
    -RequestMemoryInGb 1 `
    -LimitCpu 1 `
    -LimitMemoryInGb 1 `
    -Port @($port)

#crear grupo de contenedores
$containerGroup = New-AzContainerGroup `
    -ResourceGroup az104-rg9b `
    -Name az104-cg1 `
    -Location eastus `
    -Container $containerInstance `
    -OsType Linux `
    -IpAddressDnsNameLabel az104-lab09-c1 `
    -IpAddressType Public `
    -IpAddressPort @($port)

##Probar y verificar la implementación de una instancia de contenedor de Azure
$containerGroup | Format-Table IPAddressFqdn
#copiar la dirección FQDN y pegarla en el navegador para ver la página de inicio de ACI Hello World, referescar varias veces

#Verificar los registros de la instancia de contenedor de Azure
Get-AzContainerInstanceLog `
    -ResourceGroupName az104-rg9b `
    -ContainerGroupName az104-cg1 `
    -ContainerName az104-c1 `
    -Tail 100 | Select-Object -ExpandProperty Content
