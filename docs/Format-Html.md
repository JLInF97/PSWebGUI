---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Format-Html

## SYNOPSIS
Formats and stylizes PowerShell commands output using HTML and Bootstrap.

## SYNTAX

### Table (Default)
```powershell
Format-Html [-InputObject] <PSObject> [-Darktable] [-Darkheader] [-Striped] [-Hover] [<CommonParameters>]
```

### Cards
```powershell
Format-Html [-InputObject] <PSObject> -Cards <Int32> [<CommonParameters>]
```

### Raw
```powershell
Format-Html [-InputObject] <PSObject> [-Raw] [<CommonParameters>]
```

## DESCRIPTION
Converts the output of PowerShell commands, passed by pipeline, to HTML format and adds Bootstrap style classes.

Depending on the set of parameters, the output can be converted to table format, card format, or raw (no style).
If no parameters are set, by default it is converted to table format.
    
In essence, it is like ```ConverTo-Html -Fragment``` PowerShell cmdlet but with Bootstrap styling built-in and another features.

## EXAMPLES

### EXAMPLE 1
```powershell
PS> Get-Service | Format-Html

<table class='table'>
<thead>
<tr>
<th>Name</th>
<th>RequiredServices</th>
<th>CanPauseAndContinue</th>
...
</tr>
</thead>
<tbody>
<tr>
<td>AJRouter</td>
<td>System.ServiceProcess.ServiceController[]</td>
<td>False</td>
...
</tr>
<tr>
<td>ALG</td>
<td>System.ServiceProcess.ServiceController[]</td>
<td>False</td>
...
</tr>
...
</tbody>
</table>
```

### EXAMPLE 2
```powershell
PS> Get-Process | Select-Object Cpu, Name | Format-Html -Darkheader -Striped -Hover


<table class='table table-striped table-hover'>
<thead class='thead-dark'>
<tr>
<th>CPU</th>
<th>Name</th>
</tr>
</thead>
<tbody>
<tr>
<td>1475,09375</td>
<td>msedge.exe</td>
</tr>
<tr>
<td>0,671875</td>
<td>explorer.exe</td>
</tr>
...
</tbody>
</table>
```

### EXAMPLE 3
```powershell
PS> Get-Service | Select-Object Status, DisplayName | Format-Html -Cards 3

<div class='row row-cols-3'>
<div class='card col'>
<div class='card-body'>
<h5 class='card-title'>Stopped</h5>
<p class='card-text'>AJRouter</p>
</div>
</div>
<div class='card col'>
<div class='card-body'>
<h5 class='card-title'>Running</h5>
<p class='card-text'>ALG</p>
</div>
</div>
...
</div>
```

### EXAMPLE 4
```powershell
PS> Get-Date | Format-Html -Raw

Tuesday, June 25, 2019 14:53:32
```

## PARAMETERS

### -InputObject
Command or object to be formated in HTML, passed by pipeline.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Darktable
Set this parameter to display a dark table.

```html
<table class="table table-dark">...</table>
```

```yaml
Type: SwitchParameter
Parameter Sets: Table
Aliases: Tabledark, Table-dark

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Darkheader
Set this parameter to display a table with dark header.

```html
<table class="table">
    <thead class="thead-dark">...</thead>
</table>
```

```yaml
Type: SwitchParameter
Parameter Sets: Table
Aliases: Theaddark, Thead-dark

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Striped
Set this parameter to display a striped table.

```html
<table class="table table-striped">...</table>
```

```yaml
Type: SwitchParameter
Parameter Sets: Table
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hover
Set this parameter to display a hoverable rows table.

```html
<table class="table table-hover">...</table>
```

```yaml
Type: SwitchParameter
Parameter Sets: Table
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Cards
Specifies a number, between 1 and 6, to display the command output in Bootstrap card style.
The number specified is the number of cards displayed per row.

This parameter only displays the first two properties of the object passed.
The first one will be dipslayed as the card title, the second will be the card text.
(See the cards section of the Bootstrap v4.6 documentation for more info about card layout)

```yaml
Type: Int32
Parameter Sets: Cards
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Raw
Set this parameter to display output in HTML format but without style.

```yaml
Type: SwitchParameter
Parameter Sets: Raw
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Object
## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
