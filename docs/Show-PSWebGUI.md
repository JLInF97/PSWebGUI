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
Show-PSWebGUI [[-InputObject] <Object>] [-Port <Int32>] [-Title <String>] [-Icon <String>] [-CssUri <String>]
 [-DocumentRoot <String>] [-Display <String>] [-NoHeadTags] [-Page404 <String>] [<CommonParameters>]
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
Show-PSWebGUI -InputObject $routes -Title "My custom GUI" -Port 8080 -CssUri "C:\myresources\style.css" -Icon "C:\myresources\icon.png"
```

### EXAMPLE 4
```powershell
Show-PSWebGUI -InputObject $routes -CssUri "C:\myresources\style.css" -DocumentRoot "C:\myresources" -Icon "/icon.png"
```

### EXAMPLE 5
```powershell
Show-PSWebGUI -InputObject $routes -PublicServer
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

### -CssUri
Specifies the CSS URI to use in addition to Bootstrap.
It can be a local file or an Internet URL.
It can not be relative path, must be absolute.

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
This parameter accepts two values:
- NoGUI: Set this value to not display the GUI WPF window. The content can only be viewed within a third-party web browser.
- NoConsole: Hide the powershell console.

```yaml
Type: String
Parameter Sets: (All)
Aliases: NoConsole, Silent, Hidden

Required: False
Position: Named
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
