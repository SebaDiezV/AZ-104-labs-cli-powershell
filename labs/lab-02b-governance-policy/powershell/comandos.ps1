##Conectar  a Azure a través del modulo Az de PowerShell
Connect-AzAccount

##Crear un grupo de recursos con tags asignados
New-AzResourceGroup -Name PSaz104-rg2 -Location 'eastus' -Tag @{CostCenter="000"}

##Requerir tags mediante una directiva
#guardar información del grupo de recursos en una variable
$PSrg = Get-AzResourceGroup -Name 'PSaz104-rg2'
#guardar nombre e id de directiva 'Require a tag and its value on resources' en una variable
$PSPolicy = Get-AzPolicyDefinition | Where-Object {$_.DisplayNAme -eq 'Require a tag and its value on resources'}

#habilitar Resource Provider para PolicyInsights si no esta activado
Register-AzResourceProvider -ProviderNamespace 'Microsoft.PolicyInsights'

#asignar la directiva al grupo de recursos
$PSPolicyParams =@{
    Name = 'Require Cost Center tag and its value on resources'
    DisplayNAme = 'Require Cost Center tag and its value on resources'
    Scope = $PSrg.ResourceId
    PolicyDefinition = $PSPolicy
    Description = 'Require Cost Center tag and its value on all resources in the resource group'
    PolicyParameterObject = @{
        TagName = 'CostCenter'
        TagValue = '000'
    }
}

New-AzPolicyAssignment @PSPolicyParams

#habilitar Resource Provider para Storage
Register-AzResourceProvider -ProviderNamespace 'Microsoft.Storage'

#Crear Storage Account para que falle al no tener tags
New-AzStorageAccount -ResourceGroupName 'PSaz104-rg2' `
    -Name psteststorageacouttag `
    -location 'eastus' `
    -SkuName Standard_LRS
#Error recibido: New-AzStorageAccount: Operation returned an invalid status code 'Forbidden'
#Para validar que la directiva esta en correcto funcionamiento, se puede crear el Storage Account agregando el parámetro -Tag @{CostCenter='000'}

##Aplicar el etiquetado mediante una directiva de Azure
#eliminar directiva que requiere tag
Remove-AzPolicyAssignment -Name 'Require Cost Center tag and its value on resources'-Scope $PSrg.ResourceId

#guardar nombre e id de directiva 'Inherit a tag from the resource group if missing en una variable
$PSPolicyInherit = Get-AzPolicyDefinition | Where-Object {$_.DisplayNAme -eq 'Inherit a tag from the resource group if missing'}

#crear la política para heredar tag
$PSPolicyParamsInherit = @{
    Name = 'Inherit_Env_tag'
    DisplayName = 'Inherit the Cost Center tag and its value 000 from the resource group if missing'
    Scope = $PSrg.ResourceId
    PolicyDefinition = $PSPolicyInherit
    Description = 'Inherit the Cost Center tag and its value 000 from the resource group if missing'
    Location = 'eastus'
    IdentityType = 'SystemAssigned'
    PolicyParameter = '{"TagName": {"value": "CostCenter"}}'
}

$assignment = New-AzPolicyAssignment @PsPolicyParamsInherit

#asignar rol de 'Tag Contributor' a identidad creada por sistema
New-AzRoleAssignment `
    -ObjectId $assignment.IdentityPrincipalId `
    -RoleDefinitionName 'Tag Contributor' `
    -Scope $PSrg.ResourceId

#crear acción de remediación para corregir tags en recursos creados antes de la ejecución de la política para heredar tags
$Remediation =  Get-AzPolicyAssignment -Name 'Inherit_Env_tag' -Scope $PSrg.ResourceId

Start-AzPolicyRemediation -Name 'Remediate-tag-missing' -Scope $PSrg.ResourceId -PolicyAssignmentId $Remediation.Id

#crear Storage Account para que herede tag del grupo de recursos
New-AzStorageAccount -ResourceGroupName 'PSaz104-rg2' `
    -Name psteststorageacouttag `
    -location 'eastus' `
    -SkuName Standard_LRS

##Configurar y probar los bloqueos de recursos
New-AzResourceLock -LockName PSrglock -LockLevel CanNotDelete -ResourceGroupName PSaz104-rg2
#seleccionar 'y' para que se efectué el lock

#realizar eliminación de grupo de recursos para que se active el lock
Remove-AzResourceGroup -Name PSaz104-rg2

#Error por lock
#Remove-AzResourceGroup: The scope '/subscriptions/<Tu suscripción>/resourcegroups/PSaz104-rg2' cannot perform delete operation because following scope(s) are locked: '/subscriptions/<Tu suscripción>/resourceGroups/PSaz104-rg2'. Please remove the lock and try again.
#StatusCode: 409

##Limpieza de recursos
#quitar lock
$LockId = (Get-AzResourceLock -ResourceGroupName PSaz104-rg2).LockId
Remove-AzResourceLock -LockId $LockId
#seleccionar 'y' para confirmar remover lock

#remover remediación de la política
Remove-AzPolicyRemediation -Name 'Remediate-tag-missing' -Scope $PSrg.ResourceId

#remover asignación de la política
Remove-AzPolicyAssignment -Name 'Inherit_Env_tag'-Scope $PSrg.ResourceId

#remover la asignación del rol
Remove-AzRoleAssignment -ObjectId $assignment.IdentityPrincipalId -RoleDefinitionName 'Tag Contributor' -Scope $PSrg.ResourceId

#eliminar Storage Account
Remove-AzStorageAccount -Name 'psteststorageacouttag' -ResourceGroupName PSaz104-rg2

#eliminar grupo de recursos
Remove-AzResourceGroup -Name PSaz104-rg2