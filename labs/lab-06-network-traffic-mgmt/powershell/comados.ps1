##Conectar  a Azure a través del modulo Az de PowerShell
Connect-AzAccount

##Crear grupo de recursos
New-AzResourceGroup -Name az104-rg6 -Location eastus

##Utilizar una plantilla para aprovisionar una infraestructura
#descargar Templates y Parameters de archivos de los laboratorios, editar el tamaño de VM's por alguno disponible
#implementar Template
#crear variables para Templates y Parameters
$psInfraTemplate = 'C:\<tu_ruta>\az104-06-vms-template.json'
$psInfraParameters = 'C:\<tu_ruta>\az104-06-vms-parameters.json'

#implementar infrestructura
#crear variable con contraseña, convertirla en SecureString y pasarlo como parámetro aparte
$AZ104_VM_PASSWORD = '<tu_contraseña>'
$securePassword = ConvertTo-SecureString $AZ104_VM_PASSWORD -AsPlainText -Force

New-AzResourceGroupDeployment `
    -ResourceGroupName az104-rg6 `
    -TemplateFile $psInfraTemplate `
    -TemplateParameterFile $psInfraParameters `
    -adminPassword $securePassword

##Configurar un balanceador de carga de Azure
#crear dirección IP Pública
$ip = @{
    Name = 'az104-lbip'
    ResourceGroupName = 'az104-rg6'
    Location = 'eastus'
    Sku = 'Standard'
    AllocationMethod = 'Static'
    IpAddressVersion = 'IPv4'
    Zone = 1
}

New-AzPublicIpAddress @ip

#crear el Load Balancer
#guardar IP creada en una variable
$pip =@{
    Name = 'az104-lbip'
    ResourceGroupName = 'az104-rg6'
}
$publicIp = Get-AzPublicIpAddress @pip

#configurar Frontend del Load Balancer  y guardarlo en una variable
$fip = @{
    Name = 'az104-fe'
    PublicIpAddress = $publicIp
}
$feip = New-AzLoadBalancerFrontendIpConfig @fip

#crear backend pool y guardarlo en una variable
$bepool = New-AzLoadBalancerBackendAddressPoolConfig -Name az104-be

#crear Health Probe y guardarlo en una variable
$probe = @{
    Name = 'az104-hp'
    Protocol = 'tcp'
    Port = '80'
    IntervalInSeconds = '360'
    ProbeCount = '4'
}
$healthprobe = New-AzLoadBalancerProbeConfig @probe

#crear Rule de Load Balancer y guardarla en una variable
$lbrule = @{
    Name = 'az104-lbrule'
    Protocol = 'tcp'
    FrontendPort = '80'
    BackendPort = '80'
    IdleTimeoutInMinutes = '4'
    FrontendIpConfiguration = $feip
    BackendAddressPool = $bepool
}
$rule = New-AzLoadBalancerRuleConfig @lbrule

#crear Load Balancer
$loadbalancer = @{
    ResourceGroupName = 'az104-rg6'
    Name = 'az104-lb'
    Location = 'eastus'
    Sku = 'Standard'
    FrontendIpConfiguration = $feip
    BackendAddressPool = $bepool
    LoadBalancingRule = $rule
    Probe = $healthprobe
}
New-AzLoadBalancer @loadbalancer

#agregar VM's a Backend pool
#obtener Backend y Loadbalancer y guardarlos en variables
$lb = Get-AzLoadBalancer -ResourceGroupName az104-rg6 -Name az104-lb
$backendPool = Get-AzLoadBalancerBackendAddressPoolConfig -Name az104-be -LoadBalancer $lb

#Obtener NIC's de las VM's
$nic0 =  Get-AzNetworkInterface -ResourceGroupName az104-rg6 -Name az104-06-nic0
$nic1 =  Get-AzNetworkInterface -ResourceGroupName az104-rg6 -Name az104-06-nic1

#asignar el Backend pool a la configuración ip de la NIC
$nic0.IpConfigurations[0].LoadBalancerBackendAddressPools = $backendPool
$nic1.IpConfigurations[0].LoadBalancerBackendAddressPools = $backendPool

#guardar cambios
Set-AzNetworkInterface -NetworkInterface $nic0
Set-AzNetworkInterface -NetworkInterface $nic1

#obtener IP de Load Balancer, revisar la variable antes creada y revisar por web el resultado 
$publicIp

##Configurar una puerta de enlace de aplicaciones de Azure
#crear una nueva subred para el Application Gateway
#obtener VNet existente
$vnet = Get-AzVirtualNetwork -ResourceGroupName az104-rg6 -Name az104-06-vnet1

Add-AzVirtualNetworkSubnetConfig `
    -Name subnet-appgw `
    -VirtualNetwork $vnet `
    -AddressPrefix 10.60.3.224/27

$vnet | Set-AzVirtualNetwork

##Configurar una puerta de enlace de aplicaciones de Azure
#obtener VNet y Subred directamente (ya creadas)
$vnet = Get-AzVirtualNetwork -ResourceGroupName 'az104-rg6' -Name 'az104-06-vnet1'
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'subnet-appgw'

#crear IP Pública
$ipgw = @{
    Name = 'az104-gwpip'
    ResourceGroupName = 'az104-rg6'
    Location = 'eastus'
    Sku = 'Standard'
    AllocationMethod = 'Static'
    IpAddressVersion = 'IPv4'
    Zone = 2
}
$publicIpGw = New-AzPublicIpAddress @ipgw -Force

#crear componentes del Application Gateway
$gwip = New-AzApplicationGatewayIPConfiguration -Name 'az104-gwipconf' -Subnet $subnet
$gwfe = New-AzApplicationGatewayFrontendIPConfig -Name 'az104-feconf' -PublicIpAddress $publicIpGw
$gwfep = New-AzApplicationGatewayFrontendPort -Name 'az104-feport' -Port 80
$gwbep = New-AzApplicationGatewayBackendAddressPool -Name 'az104-appgwbe'
$gwbes = New-AzApplicationGatewayBackendHttpSetting -Name 'az104-gwbes' -Port 80 -Protocol Http -CookieBasedAffinity Enabled -RequestTimeout 30
$gwl = New-AzApplicationGatewayHttpListener -Name 'az104-listener' -Protocol Http -FrontendIPConfiguration $gwfe -FrontendPort $gwfep
$gwferule = New-AzApplicationGatewayRequestRoutingRule -Name 'az104-gwrule' -RuleType Basic -Priority 10 -HttpListener $gwl -BackendAddressPool $gwbep -BackendHttpSettings $gwbes

#sku y Despliegue con Zona alineada
$sku = New-AzApplicationGatewaySku -Name Standard_v2 -Tier Standard_v2 -Capacity 2

#crear Application Gateway
New-AzApplicationGateway `
    -Name az104-appgw `
    -ResourceGroupName az104-rg6 `
    -Location eastus `
    -Zone 2 `
    -BackendAddressPools $gwbep `
    -BackendHttpSettingsCollection $gwbes `
    -FrontendIPConfigurations $gwfe `
    -GatewayIPConfigurations $gwip `
    -FrontendPorts $gwfep `
    -HttpListeners $gwl `
    -RequestRoutingRules $gwferule `
    -Sku $sku

#agregar Vm's al Backend
#obtener NIC's de las VM
$nic0 = Get-AzNetworkInterface -ResourceGroupName az104-rg6 -Name az104-06-nic0
$nic1 = Get-AzNetworkInterface -ResourceGroupName az104-rg6 -Name az104-06-nic1

#obtener Application Gateway
$appgw = Get-AzApplicationGateway -ResourceGroupName az104-rg6 -Name az104-appgw

#asociar las IP's de las NIC's al Backend Pool
Set-AzApplicationGatewayBackendAddressPool `
    -ApplicationGateway $appgw `
    -Name az104-appgwbe `
    -BackendIpAddresses $nic0.IpConfigurations[0].PrivateIpAddress, $nic1.IpConfigurations[0].PrivateIpAddress

Set-AzApplicationGateway -ApplicationGateway $appGw

#agregar Backed pool para imágenes
Add-AzApplicationGatewayBackendAddressPool `
    -ApplicationGateway $appgw `
    -Name az104-imagebe `
    -BackendIPAddresses $nic0.IpConfigurations[0].PrivateIpAddress

#agregar Backed pool para videos
Add-AzApplicationGatewayBackendAddressPool `
    -ApplicationGateway $appgw `
    -Name az104-videobe `
    -BackendIPAddresses $nic1.IpConfigurations[0].PrivateIpAddress

#crear la configuración HTTP Backend
Add-AzApplicationGatewayBackendHttpSetting `
    -ApplicationGateway $appgw `
    -Name az104-http `
    -Port 80 `
    -Protocol Http `
    -CookieBasedAffinity Disabled `
    -RequestTimeout 30

#Refrescar las variables internas del Gateway
$defaultpool = Get-AzApplicationGatewayBackendAddressPool -ApplicationGateway $appgw -Name 'az104-appgwbe'
$imagepool = Get-AzApplicationGatewayBackendAddressPool -ApplicationGateway $appgw -Name 'az104-imagebe'
$videopool = Get-AzApplicationGatewayBackendAddressPool -ApplicationGateway $appgw -Name 'az104-videobe'
$httpsetting = Get-AzApplicationGatewayBackendHttpSetting -ApplicationGateway $appgw -Name 'az104-http'
$listener = Get-AzApplicationGatewayHttpListener -ApplicationGateway $appgw -Name 'az104-listener'

#crear las reglas basadas en rutas
$imagePathRule = New-AzApplicationGatewayPathRuleConfig `
    -Name 'images' `
    -Paths '/image/*' `
    -BackendAddressPool $imagepool `
    -BackendHttpSettings $httpsetting

$videoPathRule = New-AzApplicationGatewayPathRuleConfig `
    -Name 'videos' `
    -Paths '/video/*' `
    -BackendAddressPool $videopool `
    -BackendHttpSettings $httpsetting

#crear el urlPathMap para agrupar las rutas
Add-AzApplicationGatewayUrlPathMapConfig `
    -ApplicationGateway $appgw `
    -Name 'urlpathmap' `
    -PathRules $imagePathRule, $videoPathRule `
    -DefaultBackendAddressPool $defaultpool `
    -DefaultBackendHttpSettings $httpsetting

$urlPathMap = Get-AzApplicationGatewayUrlPathMapConfig -ApplicationGateway $appgw -Name 'urlpathmap'

#Actualizar la Regla de Enrutamiento existente a tipo PathBasedRouting
Set-AzApplicationGatewayRequestRoutingRule `
    -ApplicationGateway $appgw `
    -Name 'az104-gwrule' `
    -RuleType PathBasedRouting `
    -Priority 10 `
    -HttpListener $listener `
    -UrlPathMap $urlPathMap

#aplicar todos los cambios
$appgw | Set-AzApplicationGateway

#probar estado de aprovisionamiento
$appgw.ProvisioningState

#crear un mensaje que aparezca al ingresar en las rutas de la aplicación
Invoke-AzVMRunCommand `
    -ResourceGroupName az104-rg6 `
    -VMName az104-06-vm1 `
    -CommandId RunPowerShellScript `
    -ScriptString "New-Item -Path 'C:\inetpub\wwwroot\video' -ItemType Directory -Force; Set-Content -Path 'C:\inetpub\wwwroot\video\index.html' -Value '<h1>Hello from VIDEO backend</h1>'"

Invoke-AzVMRunCommand `
    -ResourceGroupName az104-rg6 `
    -VMName az104-06-vm0 `
    -CommandId RunPowerShellScript `
    -ScriptString "New-Item -Path 'C:\inetpub\wwwroot\video' -ItemType Directory -Force; Set-Content -Path 'C:\inetpub\wwwroot\video\index.html' -Value '<h1>Hello from IMAGE backend</h1>'"

#obtener IP de Frontend y luego probar en un navegador con las rutas de video e Image
(Get-AzPublicIpAddress -ResourceGroupName 'az104-rg6' -Name 'az104-gwpip').IpAddress

##Limpiar recursos
Remove-AzResourceGroup az104-rg6
#Seleccionar Y cuando solicite el prompt