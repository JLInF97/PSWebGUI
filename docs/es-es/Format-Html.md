---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Format-Html

## SINOPSIS
Formatea y estiliza la salida de los comandos de PowerShell usando HTML y Bootstrap.

## SINTAXIS

### Table (Default)
```powershell
Format-Html [-InputObject] <PSObject> [-Darktable] [-Darkheader] [-Striped] [-Hover] [-Id <String>] [-Class <array>] [<CommonParameters>]
```

### Cards
```powershell
Format-Html [-InputObject] <PSObject> -Cards <Int32> [-Id <String>] [-Class <array>] [<CommonParameters>]
```

### Raw
```powershell
Format-Html [-InputObject] <PSObject> [-Raw] [<CommonParameters>]
```

## DESCRIPCIÓN
Convierte la salida de los comandos de PowerShell, pasados por la tubería, a formato HTML y añade clases del estilo de Bootstrap.

Dependiendo del conjunto de parámetros, la salida se puede convertir a formato tabla, formato cartas o sin formato.
Si no se especifica ningún parametro, por defecto se convierte a formato tabla.
    
En esencia, es como el comando ```ConverTo-Html -Fragment``` pero con estilos de Bootstrap añadidos y otras características.

## EJEMPLOS

### EJEMPLO 1
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

### EJEMPLO 2
```powershell
PS> Get-Process | Select-Object Cpu, Name | Format-Html -Darkheader -Striped -Hover -Id "myTable" -Class "myClass","yourClass"


<table class='table table-striped table-hover myClass yourClass' id='myTable'>
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

### EJEMPLO 3
```powershell
PS> Get-Service | Select-Object Status, DisplayName | Format-Html -Cards 3

<div class='row row-cols-3'>
<div class='col mb-1'>
<div class='card h-100'>
<div class='card-body'>
<h5 class='card-title'>Stopped</h5>
<p class='card-text'>AJRouter</p>
</div>
</div>
</div>
<div class='col mb-1'>
<div class='card h-100'>
<div class='card-body'>
<h5 class='card-title'>Running</h5>
<p class='card-text'>ALG</p>
</div>
</div>
</div>
...
</div>
```

### EJEMPLO 4
```powershell
PS> Get-Date | Format-Html -Raw

Martes, 25 de junio de 2019 14:53:32
```

## PARÁMETROS

### -InputObject
Comando u objeto para ser formateado en HTML, pasado por tubería.

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
Establece este parámetro para mostrar una tabla oscura.

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
Establece este parámetro para mostrar una tabla con la cabecera oscura.

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
Establece este parámetro para mostrar una tabla con franjas de colores alternos.

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
Establece este parámetro para mostrar una tabla en la que las filas resaltan al pasar el cursor por encima.

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

### -Id
Usa este parámetro para establecer el atributo id.

```html
<table id="table1">...</table>
```

```yaml
Type: String
Parameter Sets: Cards, Table
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Cards
Especifica un número, entre 1 y 6, para mostrar la salida del comando con el estilo de tarjetas de Bootstrap.
El número indicado es la cantidad de tarjetas mostradas por fila.

Este parámetro solo muestra las primeras dos propiedades del objeto pasado.
La primera propiedad se mostrará como el título de la tarjeta, la segunda se mostrará como el texto de la tarjeta.
(Visita la sección de tarjetas de la documentación de Bootstrap v4.6 para más información sobre la disposición de tarjetas)

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

### -Class
Usa este parámetro para establecer una matriz de las clases para la tabla o las tarjetas.

```html
<table clas="table myClass">...</table>
```
```html
<div class="row-cols-3 myClass" >...</div>
```

```yaml
Type: Array
Parameter Sets: Cards, Table
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Raw
Establece este parámetro para mostar el la salida en formato HTML pero sin estilo.

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
Este cmdlet admite los parámetros comunes: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction y -WarningVariable. Para obtener más información, vea [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## ENTRADAS

### System.String
### System.Object
## SALIDAS

### System.String
## NOTAS

## VÍNCULOS RELACIONADOS
