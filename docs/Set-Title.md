---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Set-Title

## SYNOPSIS
Set the web page title.

## SYNTAX
```powershell
Set-Title [-Title] <string>  [<CommonParameters>]
```

## DESCRIPTION
Set the web page title. Override the current title for this page (set in Show-PSWebGui function).
Only for web page title, not for window title.

## EXAMPLES

### EXAMPLE 1
```powershell
Set-Title -Title "Page title"
```

## PARAMETERS

### -Title
Specifies the title to set.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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