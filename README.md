# PSWebGUI
A fast way to create and display PowerShell graphical interfaces with HTML.

This PowerShell module is a set of tools that allows you to quickly create and display fancy HTML graphical user interfaces. The module allows to interact with PowerShell cmdlets, functions, or scripts and join the result to the graphic design in HTML.

PowerShell acts, in this module, as a web server language, like PHP. You can define custom routes or navigate through your file system.

The HTML is styled with Bootstrap CSS framework to provide better look and responsive content in a fast way.

**Important note!** To use this module, PowerShell must have been **_run as Administrator_**.

[Visit about file for more detailed info](../main/docs/about_PSWebGui.md)


## How to install
This module is in prerelease version, there may be serious bugs and cause stability problems in your computer. The core is frequently modified. Install at your own risk.

### Download from PowerShell Gallery
The module is available in PowerShell Gallery. Use this cmdlet to get the lastest version.
```powershell
PS> Install-Module -Name PSWebGui -AllowPrerelease
```

### Download from Github repository
1. Download the lastest version of the module from this Github repository.
2. Extract the content of the ZIP into ```C:\Program Files\WindowsPowerShell\Modules```


## Main functions
### Show-PSWebGui
#### Syntax
```powershell
Show-PSWebGUI [[-InputObject] <Object>] [-Port <Int32>] [-Title <String>] [-Icon <String>] [-CssUri <String>] [-NoWindow] [-DocumentRoot <String>] [<CommonParameters>]
```

#### Description
Starts a simple web server, listening on localhost, to display the structure and content passed within an object.

The content can be a string, an HTML page, cmdlets, functions or complex powershell scripts. The HTML content will be stylized with Bootstrap CSS framework.
The server can execute and display local HTML or PS1 files. Custom CSS and Javascript are also compatible.
    
POST and GET methods are available and can be accesses by ```$_POST[]``` and ```$_GET[]``` variables, just like within PHP.

#### Example: How to create basic graphic interface
```powershell
PS> $routes = @{
  "/"={
    "<div>
      <h1>Menú</h1>
      <a href='/showProcesses'><h2>Show Running Processes</h2></a>
      <a href='/showServices'><h2>Show Services</h2></a>
    </div>"
    }

    "/showProcesses" = { Get-Process | Select-Object name, cpu | Format-Html }

    "/showServices" = {
		"<div>
		<h1>Services</h1>"
		Get-Service | Format-Html
		"</div>"
    }
}

PS> Show-PSWebGui -InputObject $routes
```

#### More info
```powershell
PS> Get-Help Show-PSWebGui -Full
```

### Format-Html
#### Syntax
```powershell
Format-Html [-InputObject] <PSObject> [-Darktable] [-Darkheader] [-Striped] [-Hover] [<CommonParameters>]

Format-Html [-InputObject] <PSObject> -Cards <Int32> [<CommonParameters>]

Format-Html [-InputObject] <PSObject> -Raw [<CommonParameters>]
```
#### Description
PowerShell cmdlets need to be formated in HTML with Bootstrap style before being displayed. This function converts the output of PowerShell commands, passed by pipeline, to HTML format and adds Bootstrap style classes.
    
Depending on the set of parameters, the output can be converted to table format, card format, or raw. If no parameters are set, by default it is converted to table format.
        
In essence, it is like "ConvertTo-Html -Fragment" PowerShell cmdlet but with Bootstrap styling built-in and another features.

#### Example
Get the name and the CPU usage of all running processes in a table format (Bootstrap style).
```powershell
PS> Get-Process | Select-Object Name, CPU | Sort-Object -Property CPU -Descending | Format-Html

<table class='table'>
<thead>
<tr>
<th>Name</th>
<th>CPU</th>
</tr>
</thead>
<tbody>
<tr>
<td>msedge</td>
<td>2672,9375</td>
</tr>
<tr>
<td>explorer</td>
<td>402,296875</td>
</tr>
...
</tbody>
</table>
```



#### More info
```powershell
PS> Get-Help Format-Html -Full
```

### Show-PSWebGuiExample
#### Description
Displays a basic GUI example to show how this module runs. This funtion returns the object with the structure and content used to display the graphical interface.

#### Example
```powershell
PS> Show-PSWebGuiExample
```
