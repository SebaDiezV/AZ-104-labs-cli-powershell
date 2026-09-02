##Conectar a Azure
Connect-AzAccount

##Crear grupo de recursos
New-AzResourceGroup -Name az104-rg9c -Location eastus

##Crear y configurar una aplicación y un entorno de contenedores de Azure
#actualizar a la versión más reciente del módulo Az
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

#instalar y actualizar el módulo Az.app
Install-Module -Name Az.App
Update-Module -Name Az.App

#registrar el proveedor de espacio de nombres de Azure Container Apps
Register-AzResourceProvider -ProviderNamespace Microsoft.App

#registrar el proveedor del área de trabajo de log analytics
Register-AzResourceProvider -ProviderNamespace Microsoft.OperationalInsights

#crear entorno de container apps
az containerapp env create `
    --name my-environment `
    --resource-group az104-rg9c `
    --location eastus

#crear una aplicación de contenedor de Azure usan CLI en PowerShell
az containerapp create `
    --name my-app `
    --resource-group az104-rg9c `
    --environment my-environment `
    --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest `
    --target-port 80 `
    --ingress external

##Probar y verificar la implementación de la aplicación de contenedores de Azure
$containerApp = Get-AzContainerApp -ResourceGroupName az104-rg9c -Name my-app
$url = "https://$($containerApp.Configuration.IngressFqdn)"
$url
#copiar url y probarla en un navegador web para verificar que la aplicación de contenedores de Azure se haya implementado correctamente.

##Limpieza de recursos
az group delete --resource-group az104-rg9c --yes