---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# GoTo-Location

## SYNOPSIS
Redirects to another URL passed by parameter.

## SYNTAX
```powershell
GoTo-Location [-URL] <string>  [<CommonParameters>]
```

## DESCRIPTION
Redirects, without user intervention, to another location, passing the URL by parameter.

## EXAMPLES

### EXAMPLE 1
```powershell
PS> GoTo-Location -URL "/"

<script>window.location.href="/"</script>
```

## PARAMETERS

### -URL
Specifies the URL to be redirected to.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Location, Path

Required: True
Position: 0
Default value: None
Accept pipeline input: False
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