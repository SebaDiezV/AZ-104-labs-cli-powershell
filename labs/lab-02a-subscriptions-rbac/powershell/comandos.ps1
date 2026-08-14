##Conectar  a Azure a través del modulo Az de PowerShell
Connect-AzAccount

##Crear Management Group
New-AzManagementGroup -GroupName 'PSaz104-mg1' -DisplayName 'PSaz104-mg1'

##Crear grupo Helpdesk
#Conectar a Entra ID con MgGraph y el scope Group.ReadWrite.All y RoleManagement.ReadWrite.Directory
Connect-MgGraph -tenantId $tenantId -Scopes "Group.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

#Crear el grupo Helpdesk
New-MgGroup -DisplayName 'PS Helpdesk' -MailEnabled:$false -MailNickname 'ps-helpdesk' -SecurityEnabled

##Asignar un rol RBAC al grupo
#Obtener id del grupo creado y guardarlo en una variable
$pshelpdesk_id = (Get-MgGroup -Filter "DisplayName eq 'PS Helpdesk'").id

#Obtener ID del nuevo Management Group y guardarlo en un variable
$PSaz104_Id = (Get-AzManagementGroup -GroupId 'PSaz104-mg1').Id

#Asignar el rol al grupo helpdesk con scope el Management Group PSaz104-mg1
New-AzRoleAssignment -ObjectId $pshelpdesk_id -RoleDefinitionName 'Virtual Machine Contributor' -Scope $PSaz104_Id

#Comprobar la asignación del rol y el scope
Get-AzRoleAssignment -ObjectId $pshelpdesk_id -Scope $PSaz104_Id

##Crear un rol de RBAC personalizado
#Se tomará de base un rol integrado para personalizarlo
#Obtener la lista de operaciones del proveedor de recursos Microsoft.Support
Get-AzProviderOperation 'Microsoft.Support/*' | Format-Table Operation, Description -AutoSize

#Obtener el rol de lector en formato JSON y dejar el archivo en la ruta del proyecto
Get-AzRoleDefinition -Name 'Reader' | ConvertTo-Json | Out-File <Tu Ruta>\ReaderSupportRole.json

#Se Deja Archivo JSON editado con la información necesaria

#Crear rol personalizado
New-AzRoleDefinition -InputFile '<Tu ruta>\ReaderSupportRole.json'

##Supervisar las asignaciones de roles con el registro de actividad, reutilizar la variable que contiene el id del ManagementGroup
Get-AzLog -StartTime (Get-Date).AddDays(-7) | Where-Object {$_.Authorization.Action -like 'Microsoft.Authorization/roleAssignments/*'}