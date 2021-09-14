---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Get-CredentialForm

## SYNOPSIS
Gets credential information from form.

## SYNTAX
```powershell
Get-CredentialForm
```

## DESCRIPTION
Gets the information sent by the form generated by ```Write-CredentialForm``` function.

Returns a PSCredential object with the username and password encrypted. Same as with PowerShell ```Get-Credential``` cmdlet.

## EXAMPLES

### EXAMPLE 1
```powershell
PS> Get-CredentialForm

UserName                             Password
--------                             --------
Administrator    System.Security.SecureString
```

## PARAMETERS

## INPUTS

## OUTPUTS
### System.Object

## NOTES

## RELATED LINKS