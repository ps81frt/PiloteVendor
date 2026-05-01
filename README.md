# Execution Rapide

## Copier coller dans le Terminal PowerShell Administrateur.

```powershell
cd $env:USERPROFILE\Downloads
Invoke-WebRequest https://raw.githubusercontent.com/ps81frt/PiloteVendor/refs/heads/main/PilotesVendor.ps1 -OutFile PilotesVendor.ps1
Unblock-File .\PilotesVendor.ps1
.\PilotesVendor.ps1
```
