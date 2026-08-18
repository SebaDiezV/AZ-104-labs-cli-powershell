# AZ-104 Labs - Lab 02b: Manage Governance via Azure Policy

## Objetivo
Aprender a implementar planes de gobernanza,incluyendo directivas de Azure y etiquetado de recursos.

## Fuente
Basado en [Lab02b - Manage Governance via Azure Policy](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/Instructions/Labs/LAB_02b-Manage_Governance_via_Azure_Policy.html)

## Recursos creados
-Grupo de recursos
-Directiva de etiquetado
-Política de remediación
-Cuenta de almacenamiento
-Bloqueo de grupo de recursos

## Notas y aprendizaje

Tanto en Azure CLI o en PowerShell antes de configurar las directivas o crear la cuenta de almacenamiento, se debe primero habilitar el proveedor de recursos ya que vienen deshabilitados por defecto.

La parte mas compleja de este laboratorio fue la configuración de las directivas, el nombre debe ser exactamente el que se da en el laboratorio para cumplir lo requerido, requerir tag o heredarlo del grupo de recursos. También se debe tener en cuenta los parámetros para habilitar la directiva, inicialmente son similares, pero hay ciertos parámetros que son específicos para la directiva y debe respetarse en la configuración.

Para la directiva para heredar tags del grupo de recurso, al crear un nuevo recurso, paso algo interesante, ya que la directiva agrega el tag en el recurso si no se especifica, se le debe dar una identidad administrada a la directiva para que ejecute el cambio, pero en Azure CLI no fue necesario agregar el parámetro --assign-identity, el sistema lo asumió, por el contrario en PowerShell es necesario agregar el IdentityType como SystemAssigned y además agregarle el rol de Tag Contributor a esta identidad para que pueda agregar el tag a los recursos, volviéndolo mas seguro y estricto a la hora de trabajar.


