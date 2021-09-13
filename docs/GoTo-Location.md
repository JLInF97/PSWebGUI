---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# GoTo-Location

## SYNOPSIS
Redirect to another URL passed by parameter.

## SYNTAX

### Table (Default)
```powershell
GoTo-Location [-Location] <string>  [<CommonParameters>]
```

## DESCRIPTION
Redirect, without user intervention, to another location, passing the URL by parameter.

## EXAMPLES

### EXAMPLE 1
```powershell
GoTo-Location -Location "/"
```

## PARAMETERS

### -Location
Specifies the URL to be redirected to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS
### System.String

## OUTPUTS
### System.Object

## NOTES

## RELATED LINKS