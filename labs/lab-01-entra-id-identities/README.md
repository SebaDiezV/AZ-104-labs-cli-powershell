# AZ-104 Labs - Lab 01: Manage Microsoft Entra ID Identities

## Objetivo
Aprender como crear usuarios y grupos de Entra ID con Azure CLI y PowerShell (MgGraph), administrarlos y conocer las diferencias al utilizar las distintas líneas de comando.

## Fuente
Basado en [Lab 01 - Manage Entra ID Identities](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_01-Manage_Entra_ID_Identities.html#job-skills)

## Recursos creados
- Usuario interno (CLI y PowerShell)
- Usuario externo invitado (CLI y PowerShell)
- Grupo de seguridad con miembros y owner

## Notas y aprendizaje
Hay una diferencia sustancial entre trabajar con Azure CLI y PowerShell, este último es mas directo, en el caso de crear los usuarios con CLI, solo se crea el objeto con parámetros básicos (nombre, password, UPN), az ad user create no soporta otros parámetros más específicos, estos deben ser agregados luego utilizando el método PATCH la API REST de Azure, con los que se puede agregar los parámetros como JobTitle, Department, etc.

La API REST también debe ser utilizada para invitar a los usuarios externos con el método POST.

PowerShell no estuvo exento de dificultades, el parámetro PasswordProfile falla al utilizarlo como parámetro individual, por lo que fue necesario crear una variable para pasar todos los parámetros como un objeto JSON y pasarlos como un solo parámetro al crear el usuario utilizando el parámetro -BodyParameter

En el usuario invitado, también se debe crear una variable JSON para mayor facilidad y poder enviar el mensaje de bienvenida y luego agregar los parámetros adicionales con el comando Update-MgUser.

## Problemas encontrados y solución
- PowerShell: las comillas simples `'...'` no interpolan variables (`$env:VAR`), a diferencia de las comillas dobles `"..."`.
- PowerShell: `-PasswordProfile` como Hashtable individual falla en el SDK 2.35.1 de Microsoft Graph; se resolvió usando `-BodyParameter` con el objeto completo.
- Azure CLI: los nombres de parámetros no siempre son intuitivos (`--enabled` no existe; el correcto es `--account-enabled`), y varían entre subcomandos (`create` vs `update`).