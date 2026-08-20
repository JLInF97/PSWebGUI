---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Show-PSWebGUI

## SINOPSIS
Muestra una ventana de interfáz gráfica de usuario (GUI) en PowerShell, con contenido HTML y PowerShell, desde un objeto dado.

## SINTAXIS

```powershell
Show-PSWebGUI [[-InputObject] <Object>] [-Port <Int32>] [-Title <String>] [-Icon <String>] [-DocumentRoot <String>]
 [-Display {NoGUI | NoConsole | Systray}] [-NoHeadTags] [-PublicServer] [-Page404 <String>] [-AsJob] [<CommonParameters>]
```

## DESCRIPCIÓN
Inicia un servidor web simple para mostrar la estructura y contenido pasado en un objeto.

Por defecto, muestra un navegador web muy simple en una ventana WPF para mostrar el contenido pasado por parámetro.

El contenido puede ser una cadena de texto, una página HTML, comandos, funciones o scripts de PowerShell complejos. El contenido HTML es estilizado usando el framework CSS Bootstrap.
El servidor puede ejecutar y mostrar archivos HTML o PS1 locales.
Tambien es compatible con CSS y Javascript personalizados.

Están disponibles los métodos POST y GET y se puede acceder a ellos a través de las variables ```$_POST[]``` y ```$_GET[]```, igual que se haría en PHP.

## EJEMPLOS

### EJEMPLO 1
```powershell
Show-PSWebGUI -InputObject "Hello Wordl!"
```

### EJEMPLO 2
```powershell
Show-PSWebGUI -InputObject $routes -Title "My custom GUI"
```

### EJEMPLO 3
```powershell
Show-PSWebGUI -InputObject $routes -DocumentRoot "C:\myresources" -Icon "/icon.png" -Port 8080 -PublicServer
```

### EJEMPLO 4
```powershell
Show-PSWebGUI -InputObject $routes -Display Systray
```

### EJEMPLO 5
```powershell
Show-PSWebGUI -InputObject $routes -PublicServer -AsJob
```

## PARÁMETROS

### -InputObject
Especifica el objeto que contiene la estructura y el contenido para mostrar en la GUI.

La forma para definir las rutas personalizadas con HTML y PowerShell asociado es a través de una tabla matríz (hashtable) y bloques de script (scriptblock) dentro de ella.
Las tablas matrices estan compuestas por claves y sus valores asociados.
Las claves son rutas relativas personalizadas y siempre deben comenzar con ```"/"```; los valores son cadenas de texto, HTML y scripts PowerShell contenidos en un bloque de script.

Un ejemplo de una estructura de GUI pasado como parámetro de entrada:

```powershell
$routes=@{

    "/"={
        "<div>
            <h1>Menú</h1>
            <a href='/showProcesses'><h2>Mostrar procesos en ejecución</h2></a>
            <a href='/showServices'><h2>Mostrar servicios en ejecución</h2></a>
        </div>"
    }

    "/showProcesses" = { Get-Process | Select-Object name, cpu | Format-Html }

    "/showServices" = {
        "<div>
            <h1>Servicios</h1>"
            Get-Service | Select-Object Name, Status | Where-Object Status -eq "Running" | Format-Html
        "</div>"
    }

}
```

```yaml
Type: Object
Parameter Sets: (All)
Aliases: Routes, Input

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Port
Especifica el número de puerto TCP para escuchar.
Por defecto el 80.

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

### -Title
Especifica el título de la ventana y de la página HTML.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: PoweShell Web GUI
Accept pipeline input: False
Accept wildcard characters: False
```

### -Icon
Especifica la ruta del icono que se usará en la ventana y en la página HTML.
Esta ruta puede ser absoluta o relativa a la raíz del servidor.
Si la ruta no está dentro del directorio raíz del servidor, el icono solo se mostrará en la ventana.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DocumentRoot
Especifica el directorio raíz de los archivos a los que accederá el servidor.
No pongas la barra final (/).
Por defecto es el valor de $PWD

```yaml
Type: String
Parameter Sets: (All)
Aliases: Root

Required: False
Position: Named
Default value: $PWD.path
Accept pipeline input: False
Accept wildcard characters: False
```

### -Display
This parameter specifies how the GUI and console are displayed.
The acceptable values for this parameter are:
- NoGUI: Set this value to not display the WPF GUI window. The content can only be viewed within a third-party web browser. The PowerShell console is still visible.
- NoConsole: Hide the PowerShell console but keeps the main WPF GUI visible.
- Systray: Minimize the GUI and PowerShell console to the system tray. The system tray icon will be the same as the window icon and a menu will be added to the system tray icon. The menu contains these options:
	- Show GUI: Displays the GUI window. Use close (X) button on the GUI itself to hide the GUI again.
	- Show/Hide PS console: Show or hide the PowerShell console. Use this option to show or hide the console, do not use the buttons on the console itself.
	- Exit: Close the GUI, PowerShell console, stop the server and close PowerShell process.

Este parámetro especifica cómo se muestran la interfaz gráfica (GUI) y la consola de PowerShell.
Los valores aceptados para este parámetro son:
- NoGUI: Establece que no se muestre la ventana de la GUI. El contenido solo puede verse desde un navegador web de terceros. La consola de PowerShell sigue siendo visible.
- NoConsole: Oculta la consola de PowerShell pero mantiene visible la ventana principal de la GUI.
- Systray: Minimiza la GUI y la consola de PowerShell a la bandeja del sistema. El icono de la bandeja será el mismo que el icono de la ventana y se añadirá un menú contextual al icono de la bandeja. El menú contiene estas opciones:
    - Show GUI: Muestra la ventana de la GUI. Usa el botón de cerrar (X) de la propia GUI para volver a ocultarla.
    - Show/Hide PS console: Muestra u oculta la consola de PowerShell. Usa esta opción para mostrar u ocultar la consola; no uses los botones de la propia consola.
    - Exit: Cierra la GUI, la consola de PowerShell, detiene el servidor y cierra el proceso de PowerShell.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Accepted values: NoGUI, NoConsole, Systray
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoHeadTags
Establece este parámetro para que el servidor no añada las etiquetas por defecto: ```<html>```, ```<head>```, ```<meta>```, ```<link>```, ```<style>``` y ```<body>```.
Con esta opción, el contenido no se formateará de forma predeterminada. El usuario tendrá que agregar sus propia estructura HTML y CSS.

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

### -PublicServer
Usa este parámetro para establecer que el servidor escuche en todas las interfaces red del equipo, haciendo que el servidor sea visible desde cualquier dirección.
Si no se especifica, el servidor solo escucha en localhost.

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

### -Page404
Usa este parámetro para definir un **archivo HTML** como página de error 404.

Este parámetro debe ser una ruta, absoluta o relativa, a un archivo HTML. El contenido del archivo se mostrará cuando el servidor no puede encontrar una ruta (código de respuesta 404).

Extensiones de archivo válidas:
- .html
- .xhtml
- .htm
- .txt

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsJob
Establece este parámetro para iniciar el servidor en un job en segundo plano. El prompt se libera para que continues trabajando en la consola.

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
### System.String
### System.Object

## SALIDAS
### System.String
### Debug and Verbose modes write request and response information to the console.

## NOTAS

## VÍNCULOS RELACIONADOS
