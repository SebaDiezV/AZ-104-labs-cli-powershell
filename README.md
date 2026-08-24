# AZ-104 Labs - Microsoft Azure Administrator Associate

> Desarrollo de los laboratorios de Microsoft de la ruta de estudio para la certificación AZ-104: Azure Administrator Associate

## Descripción General

En este repositorio se realizaran los laboratorios propuestos por Microsoft para el estudio de la certificación AZ-104. Para mejorar el estudio de la plataforma Azure, estos laboratorios serán realizados tanto en PowerShell como en Azure CLI.

### Estructura

```
az-104-labs-cli-powershell/
├── README.md
├── labs/
│   ├── lab-01-entra-id-identities/
│   ├── lab-02a-subscriptions-rbac/
│   ├── lab-02b-governance-policy/
│   ├── lab-03-arm-templates/
│   ├── lab-04-virtual-networking/
│   ├── lab-05-intersite-connectivity/
│   ├── lab-06-network-traffic-mgmt/
│   ├── lab-07-storage/
│   ├── lab-08-virtual-machines/
│   ├── lab-09a-web-apps/
│   ├── lab-09b-container-instances/
│   ├── lab-09c-container-apps/
│   ├── lab-10-data-protection/
│   └── lab-11-monitoring/
├── docs/
└── resources/

```
### Prerequisitos

- Cuenta y suscripción activa de Microsoft Azure
- Az PowerShell Module 16.1+
```powershell
     Get-InstalledModule -Name Az
```
- Azure CLI 2.89+
```bash
     az --version
```


### Ambiente de Desarrollo

| Componente | Detalle |
|---|---|
| Editor de código | Visual Studio Code - Versión 1.132.0 |
| Líneas de comandos | PowerShell 7+, Azure CLI |

### Tabla de Progreso

| Lab | CLI | PowerShell | Notas |
|-----|-----|------------|-------|
| 01 - Entra ID Identities | ✅ | ✅ | |
| 02a - Subscriptions & RBAC | ✅ | ✅ | |
| 02b - Gobernanza via Azure | ✅ | ✅ | |
| 03 - ARM Templates | ✅ | ✅ | Se Utiliza Bicep |
| 04 - Virtual Networking | ✅ | ✅ | |
| 05 - Conectividad Intersite | ✅ | ✅ | |
| 06 - Network Traffic Manager | ⬜ | ⬜ | |
| 07 - Azure Storage | ⬜ | ⬜ | |
| 08 - Virtual Machines | ⬜ | ⬜ | |
| 09a - WebApps | ⬜ | ⬜ | |
| 09b - Azure Container Instances | ⬜ | ⬜ | |
| 09c - Container Apps | ⬜ | ⬜ | |
| 10 - Data Protection | ⬜ | ⬜ | |
| 11 - Monitoring | ⬜ | ⬜ | |

## Fuente
   Laboratorios basados en [AZ-104-MicrosoftAzureAdministrator](https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/) (Microsoft Learning).