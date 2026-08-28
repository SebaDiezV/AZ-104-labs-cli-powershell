##Conectar  a Azure a través del modulo Az de PowerShell
Connect-AzAccount

##Crear grupo de recursos
New-AzResourceGroup -Name az104-rg7 -Location eastus

##Registrar el proveedor de recursos (en caso de que aún no se haya realizado)
Register-AzResourceProvider -ProviderNamespace 'Microsoft.Storage'

##Crear y configurar una cuenta de almacenamiento
New-AzStorageAccount `
    -ResourceGroupName az104-rg7 `
    -Name storageazlab7ps `
    -Location eastus `
    -Sku Standard_RAGRS `
    -Kind StorageV2 `
    -MinimumTlsVersion TLS1_2 `
    -AllowBlobPublicAccess $false

#habilitar acceso Storage Account a la red pública
Set-AzStorageAccount `
    -ResourceGroupName az104-rg7 `
    -Name storageazlab7ps `
    -PublicNetworkAccess Enabled

#cambiar acción a bloquear explícito
Update-AzStorageAccountNetworkRuleSet `
    -ResourceGroupName az104-rg7 `
    -Name storageazlab7ps `
    -DefaultAction Deny

#agregar Ip cliente permitido
Add-AzStorageAccountNetworkRule `
    -ResourceGroupName az104-rg7 `
    -Name storageazlab7ps `
    -IPAddressOrRange <tu_ip>

#crear regla de ciclo de vida
#crear el filtro
$filter = New-AzStorageAccountManagementPolicyFilter -BlobType blockBlob

#crear la acción de mover a cool si no se ha modificado archivo en 30 días
$action = Add-AzStorageAccountManagementPolicyAction -BaseBlobAction TierToCool -DaysAfterModificationGreaterThan 30

#crear la regla
$rule = New-AzStorageAccountManagementPolicyRule -Name MoveToCool -Action $action -Filter $filter

#asignar la directiva a la cuenta de almacenamiento
Set-AzStorageAccountManagementPolicy `
    -ResourceGroupName az104-rg7 `
    -StorageAccountName storageazlab7ps `
    -Rule $rule

##Crear y configurar un almacenamiento seguro de blobs
#obtener contexto de la cuenta de almacenamiento
$storageaccount = Get-AzStorageAccount -ResourceGroupName az104-rg7 -Name storageazlab7ps
$ctx = $storageaccount.Context

#crear Container
New-AzStorageContainer -Name data -Context $ctx

#agregar política de retención basada en tiempo en Container
#crear la política de retención inmutable
Set-AzRmStorageContainerImmutabilityPolicy `
    -ResourceGroupName az104-rg7 `
    -StorageAccountName storageazlab7ps `
    -ContainerName "data" `
    -ImmutabilityPeriod 180

#permitir acceso a la clave de almacenamiento 
Set-AzStorageAccount `
    -ResourceGroupName az104-rg7 `
    -AccountName storageazlab7ps `
    -AllowSharedKeyAccess $true

#otorgar el rol de Colaborador de datos de blobs de almacenamiento a tu propia cuenta
#obtener ID de usuaio
$psMyID = (Get-AzAdUser -SignedIn).Id

#obtener ID de Storage Account
$psSAId =(Get-AzStorageAccount -ResourceGroupName az104-rg7 -Name storageazlab7ps).Id

#asignar rol
New-AzRoleAssignment `
    -ObjectId $psMyID `
    -RoleDefinitionName 'Storage Blob Data Contributor' `
    -Scope $psSAId

#asignar el rol de Colaborador privilegiado de datos de archivo de almacenamiento
New-AzRoleAssignment `
    -ObjectId $psMyID `
    -RoleDefinitionName 'Storage File Data Privileged Contributor' `
    -Scope $psSAId

#subir imagen a contenedor
#obtener el contexto de la cuenta de almacenamiento actualizado
$ctx = (Get-AzStorageAccount -ResourceGroupName az104-rg7 -Name storageazlab7ps).Context

Set-AzStorageBlobContent `
    -Context $ctx `
    -Container data `
    -File test_image.png `
    -Blob securitytest/test_image.png `
    -Properties @{ContentType = "image/png"}

#generar token sas para ver archivo
#definir hora de inicio expiración (24 horas)
$startTime = Get-Date
$expiryTime = $startTime.AddHours(24)

#crear un nuevo contexto para el usuario
$ctxusr = New-AzStorageContext -StorageAccountName storageazlab7ps -UseConnectedAccount

#generar token sas con permisos de escritura
$sasToken = New-AzStorageBlobSASToken `
    -Container data `
    -Blob securitytest/test_image.png `
    -Permission r `
    -StartTime $startTime `
    -ExpiryTime $expiryTime `
    -Context $ctxusr


#obtener URL completa con token sas
#usamos variable creada anteriormente
$blobUrlWithSAS = $storageaccount.Context.BlobEndPoint + 'data' + '/' + 'securitytest/test_image.png' + '?' + $sasToken
Write-Host $blobUrlWithSAS

##Crear y configurar un almacenamiento de archivos de Azure
New-AzRmStorageShare `
    -ResourceGroupName az104-rg7 `
    -StorageAccountName storageazlab7ps `
    -Name share1 `
    -QuotaGiB 100 `
    -AccessTier TransactionOptimized

#restringir el acceso a una cuenta de almacenamiento
$subnet = New-AzVirtualNetworkSubnetConfig -Name default -AddressPrefix 10.0.0.0/24

New-AzVirtualNetwork `
    -ResourceGroupName az104-rg7 `
    -Name vnet1 `
    -Location eastus `
    -AddressPrefix 10.0.0.0/16 `
    -Subnet $subnet

#habilitar Endpoint en VNet
$vnet = Get-AzVirtualNetwork -ResourceGroupName az104-rg7 -Name vnet1

#actualizar subred con la configuración del Endpoint
Set-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name default `
    -AddressPrefix $vnet.Subnets[0].AddressPrefix `
    -ServiceEndpoint Microsoft.Storage

$vnet | Set-AzVirtualNetwork

#restringir el acceso de la cuenta de almacenamiento
Set-AzStorageAccount `
    -ResourceGroupName az104-rg7 `
    -Name storageazlab7ps `
    -PublicNetworkAccess Disabled

#agregar regla para permitir trafico únicamente de la subnet
$subnetId = (Get-AzVirtualNetwork -ResourceGroupName az104-rg7 -Name vnet1 | Get-AzVirtualNetworkSubnetConfig -Name default).Id

Add-AzStorageAccountNetworkRule `
    -ResourceGroupName az104-rg7 `
    -Name storageazlab7ps `
    -VirtualNetworkResourceId $subnetId

#revisar las reglas existentes, debe aparecer tu red publica
Get-AzStorageAccountNetworkRuleSet `
    -ResourceGroupName az104-rg7 `
    -Name storageazlab7ps

#Eliminar la ruta existente, con esto solo se puede acceder a través del service endpoint que se configuró en la VNet
Remove-AzStorageAccountNetworkRule `
    -ResourceGroupName az104-rg7 `
    -Name storageazlab7ps `
    -IPAddressOrRange "<tu_ip>"

##Limpiar recursos
Remove-AzResourceGroup az104-rg7
#Seleccionar Y cuando solicite el prompt