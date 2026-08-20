---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Set-Title

## SINOPSIS
Establece el título de la página.

## SINTAXIS
```powershell
Set-Title [-Title] <string>  [<CommonParameters>]
```

## DESCRIPCIÓN
Establece el título de la página web. Sobrescribe el título la página actual (establecido con la función Show-PSWebGui).
Solo actualiza el título de la página web, no cambia el título de la ventana.

## EJEMPLOS

### EJEMPLO 1
```powershell
PS> Set-Title -Title "Page title"

<script>document.title='Page title'</script>
```

## PARÁMETROS

### -Title
Especifica el título a establecer.

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
Este cmdlet admite los parámetros comunes: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction y -WarningVariable. Para obtener más información, vea [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## ENTRADAS
### System.String

## SALIDAS
### System.Object

## NOTAS

## VÍNCULOS RELACIONADOS