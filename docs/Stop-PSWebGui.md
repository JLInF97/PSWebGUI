---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Stop-PSWebGui

## SYNOPSIS
Stops a PSWebGui instance.

## SYNTAX
```powershell
Stop-PSWebGui [-Force] [[-Port] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Stops a Powershell server instance of the PSWebGui module.

By default, it tries to **stop only the web server** of an instance of the PSWebGui module, listening on port 80, by sending ```/stop()``` request.

Setting ```-Force``` parameter, it also tries to close the Powershell process of the instance and, whit that, the opened GUI window.

You can specify any other port where the instance is listening.

## EXAMPLES

### EXAMPLE 1
Stops the PSWebGui web server listening on port 80.
```powershell
PS> Stop-PSWebGui
```

### EXAMPLE 2
Stops the PSWebGui web server listening on port 8080.
```powershell
PS> Stop-PSWebGui -Port 8080
```

### EXAMPLE 3
Stops the PSWebGui web server listening on port 8080, kills that powershell process and closes the GUI window.
```powershell
PS> Stop-PSWebGui -Force -Port 8080
```

## PARAMETERS

### -Port
Specifie the port number where the instance is listening.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 80
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Set this parameter to kill the powershell process where the instance is listening.

Use this parameter when the instance is not responding to ```/stop()``` requests, when you want to close the GUI window by command line or when you need to completely close powershell process.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS