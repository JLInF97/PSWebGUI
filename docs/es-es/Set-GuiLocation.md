---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Set-GuiLocation

## SINOPSIS
Redirige a una URL pasada por parámetro.

## SINTAXIS
```powershell
Set-GuiLocation [-URL] <string>  [<CommonParameters>]
```

## DESCRIPCIÓN
Redirige, sin la intervención del usuario, a otra ubicación, pasando la URL de destino por parámetro.

## EJEMPLOS

### EJEMPLO 1
```powershell
PS> Set-GuiLocation -URL "/"

<script>window.location.href="/"</script>
```

## PARÁMETROS

### -URL
Especifica la URL de destino donde será redirigido.

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
Este cmdlet admite los parámetros comunes: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction y -WarningVariable. Para obtener más información, vea [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## ENTRADAS
### System.String

## SALIDAS
### System.Object

## NOTASS

## VÍNCULOS RELACIONADOS