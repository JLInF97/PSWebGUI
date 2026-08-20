---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Stop-PSWebGui

## SINOPSIS
Detiene una instancia de PSWebGui.

## SINTAXIS
```powershell
Stop-PSWebGui [-Force] [[-Port] <Int32>] [<CommonParameters>]
```

## DESCRIPCIÓN
Detiene una instancia del servidor del módulo PSWebGui.

Por defecto, intenta detener **unicamente el servidor web** de una instancia del módulo PSWebGui, escuchando en el puerto 80, mediante el envío de la petición ```/stop()```.

Estableciendo el parámetro ```-Force```, tambien intenta cerrar el proceso de PowerShell de la instancia y, con ello, la ventana de interfáz gráfica abierta.

Se puede especificar otro puerto en el que la instancia esté escuchando.

## EJEMPLOS

### EJEMPLO 1
Detiene el servidor web de PSWebGui escuchando en el puerto 80.
```powershell
PS> Stop-PSWebGui
```

### EJEMPLO 2
Detiene el servidor web de PSWebGui escuchando en el puerto 8080.
```powershell
PS> Stop-PSWebGui -Port 8080
```

### EJEMPLO 3
Detiene el servidor web de PSWebGui escuchando en el puerto 8080, mata el proceso de PowerShell y cierra la ventana de interfáz gráfica.
```powershell
PS> Stop-PSWebGui -Force -Port 8080
```

## PARAMETROS

### -Port
Especifica el número de puerto en el que la instancia está escuchando.

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
Establece este parametro para matar el proceso de PowerShell donde la instancia está escuchando.

Utiliza este parámetro cuando la instancia no responda a peticiones ```/stop()```, cuando quieras cerrar la ventana gráfica por comando o cuando necesitas cerrar completamente el proceso de PowerShell.

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
Este cmdlet admite los parámetros comunes: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction y -WarningVariable. Para obtener más información, vea [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## ENTRADAS

## SALIDAS

## NOTAS

## VÍNCULOS RELACIONADOS