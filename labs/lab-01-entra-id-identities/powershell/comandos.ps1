##Conectando a Microsoft Graph a través de PowerShell con los Scopes requeridos para las tareas
Connect-MgGraph -tenantId $tenantId -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "User.Invite.All"

##Importar el módulo de Microsoft Graph Users
Import-Module Microsoft.Graph.Users

##Crear usuario en Microsoft Entra ID
#Crear variable $params para pasar todos los parámetros como un objeto JSON
$params = @{
    accountEnabled = $true
    displayName = "az104-PSUser1"
    mailNickName = "az104-PSUser1"
    userPrincipalName = "az104-PSUser1@sdiezaz104labshotmail.onmicrosoft.com"
    jobTitle = "IT Lab Administrator"
    department = "IT"
    usageLocation = "US"
    passwordProfile = @{
        forceChangePasswordNextSignIn = $true
        password = $psUser1_password
    }
}

New-MgUser -BodyParameter $params

# Nota: -PasswordProfile como parámetro individual falla con Hashtable en SDK 2.35.1
# ("A positional parameter cannot be found that accepts argument 'True'")
# Se usa -BodyParameter con un solo hashtable completo como workaround

##Invitar a usuario externo utilizando variable para pasar los parámetros como unJSON

Import-Module Microsoft.Graph.Identity.SignIns

$params_invite = @{
    invitedUserDisplayName = "PSexternal-user"
    invitedUserEmailAddress = "PSexternal-user@company.com"
    inviteRedirectUrl = "https://aka.ms/azureadinviteme"
    sendInvitationMessage = $true
    invitedUserMessageInfo = @{
        customizedMessageBody = "Welcome to Azure and our group project"
        ccRecipients = @(
            @{
                emailAddress = @{
                    address = "az104-PSUser1@sdiezaz104labshotmail.onmicrosoft.com"
                } 
            }
        )  
    }
}

New-MgInvitation -BodyParameter $params_invite

#Actualizar parámetros de usuario invitado
#Obtener id de usuarios invitado
$ext_user_id = (Get-MgUser -UserId "PSexternal-user_company.com#EXT#@sdiezaz104labshotmail.onmicrosoft.com").Id

#Actualizar
Update-MgUser -UserId $ext_user_id -JobTitle "IT Lab Administrator" -Department "IT" -UsageLocation "US"

##Crear grupo y agregar miembros
#Crear grupo
New-MgGroup -DisplayName 'PS IT Lab Administrators' -MailEnabled:$false -MailNickname 'ps-it-lab-administrators' -SecurityEnabled

#Agregar usuarios a grupo
#Guardar id de grupo en variable, lo mismo con los otros usuarios, Id de usuario externo se guardó en paso anterior para reutilizar
$group_id =  (Get-MgGroup -Filter "DisplayName eq 'PS IT Lab Administrators'").Id
$user_id = (Get-MgUser -UserId "az104-PSUser1@sdiezaz104labshotmail.onmicrosoft.com").Id

#Agregar usuarios a grupo
New-MgGroupMember -GroupId $group_id -DirectoryObjectId $user_id
New-MgGroupMember -GroupId $group_id -DirectoryObjectId $ext_user_id

##PASO EXTRA: Agregar owner al grupo de seguridad
#Utilizar las variables declaradas en el paso anterior
New-MgGroupOwner -GroupId $group_id -DirectoryObjectId $user_id
