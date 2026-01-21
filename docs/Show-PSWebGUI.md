---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Show-PSWebGUI

## SYNOPSIS
Displays a styled graphical user interface (GUI) for PowerShell from an object passed with HTML and PowerShell content.

## SYNTAX

```powershell
Show-PSWebGUI [[-InputObject] <Object>] [-Port <Int32>] [-Title <String>] [-Icon <String>] [-DocumentRoot <String>]
 [-Display {NoGUI | NoConsole | Systray}] [-NoHeadTags] [-PublicServer] [-Page404 <String>] [-AsJob] [<CommonParameters>]
```

## DESCRIPTION
Starts a simple web server to display the structure and content passed within an object.

By default, it shows up a very simple web browser in a WPF window to display the content passed by parameter.

The content can be a string, an HTML page, cmdlets, functions or complex powershell scripts. The HTML content will be stylized with Bootstrap CSS framework.
The server can execute and display local HTML or PS1 files.
Custom CSS and Javascript are also compatible.

POST and GET methods are available and can be accesses by ```$_POST[]``` and ```$_GET[]``` variables, just like within PHP.

## EXAMPLES

### EXAMPLE 1
```powershell
Show-PSWebGUI -InputObject "Hello Wordl!"
```

### EXAMPLE 2
```powershell
Show-PSWebGUI -InputObject $routes -Title "My custom GUI"
```

### EXAMPLE 3
```powershell
Show-PSWebGUI -InputObject $routes -DocumentRoot "C:\myresources" -Icon "/icon.png" -Port 8080 -PublicServer
```

### EXAMPLE 4
```powershell
Show-PSWebGUI -InputObject $routes -Display Systray
```

### EXAMPLE 5
```powershell
Show-PSWebGUI -InputObject $routes -PublicServer -AsJob
```

## PARAMETERS

### -InputObject
Specifies the object with the structure and content to display in the GUI.

The way to define custom routes with associated HTML and PowerShell content is through a hash table and scriptblocks whitin it.
The hash table are made up of keys and their associated values.
Keys are custom defined relative paths, and must always start with ```"/"```; values are strings, HTML and PowerShell scripts enclosed within a scriptblock.

This is an example of a GUI structure passed as an input object:

```powershell
$routes=@{

    "/"={
        "<div>
            <h1>Menú</h1>
            <a href='/showProcesses'><h2>Show Running Processes</h2></a>
            <a href='/showServices'><h2>Show Running Services</h2></a>
        </div>"
    }

    "/showProcesses" = { Get-Process | Select-Object name, cpu | Format-Html }

    "/showServices" = {
        "<div>
            <h1>Services</h1>"
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
Specifies TCP port number to listen to.
Default 80.

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
Specifies the window title and the HTML page title.

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
Specifies the path for the icon used on the window and on the HTML page.
This path can be absolute or relative to the document root.
If the path is not within the document root, it will only be displayed on window.

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
Specifies the root path for the files that the server will access.
Do not put final slash.
Default $PWD

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
Set this parameter to not display ```<html>```, ```<head>```, ```<meta>```, ```<link>```, ```<style>``` and ```<body>``` tags.
With this option, the content will not be formated.

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
Use this parameter to set the server to listen on all interfaces, making the server reachable from any address. Otherwise the server will only listen on localhost.

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
Use this parameter to set an **HTML file** as the 404 error page.

This parameter must be an absolute or relative path to an HTML file. The content of the file will be displayed when the server cannot find the path (response code 404).

Valid file extensions:
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
Use this parameter to start the server in a PowerShell background job. The prompt will be released to continue working.

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

### System.String
### System.Object

## OUTPUTS

### System.String
### Debug and Verbose modes write request and response information to the console.
## NOTES

## RELATED LINKS
