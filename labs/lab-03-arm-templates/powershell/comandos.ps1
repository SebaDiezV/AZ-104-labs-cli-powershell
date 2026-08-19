##Conectar  a Azure a través del modulo Az de PowerShell
Connect-AzAccount

##Editar los archivos JSON de plantilla y parámetros según lo planteado en el ejercicio
##Implementar plantillas en el grupo de recursos creados para el ejercicio
#guardar rutas de archivos Template y Parameters para un mejor uso
$PsTemplate = 'C:\<tu_ruta>\template.json'
$PsParameters = 'C:\<tu_ruta>\parameters.json'
New-AzResourceGroupDeployment -ResourceGroupName az104-rg3 -TemplateFile $PsTemplate -TemplateParameterFile $PsParameters

#Confirmar la creación del nuevo disco
Get-AzDisk | ft Name, ResourceGroupName, Location, DiskSizeGB, ProvisioningState

##Implementar plantilla a través de Bicep
#guardar ruta de archivo Bicep en una variable
$PsBicep = 'C:\<tu_ruta>\azuredeploydisk.bicep'
New-AzResourceGroupDeployment -ResourceGroupName az104-rg3 -TemplateFile $PsBicep