---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Get-CredentialForm

## SINOPSIS
Obtiene la información de credenciales del formulario.

## SINTAXIS
```powershell
Get-CredentialForm
```

## DESCRIPCIÓN
Obtiene la información enviada por el formulario generado por la función ```Write-CredentialForm```.

Devuelve un objeto PSCredential con el nombre de usuario y la contraseña cifrada. Igual que el comando de PowerShell ```Get-Credential```.

## EJEMPLOS

### EJEMPLO 1
```powershell
PS> Get-CredentialForm

UserName                             Password
--------                             --------
Administrator    System.Security.SecureString
```

## PARÁMETROS

## ENTRADAS

## SALIDAS
### System.Object

## NOTAS

## VÍNCULOS RELACIONADOS