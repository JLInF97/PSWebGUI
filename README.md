# PSWebGUI
A fast way to create and display PowewrShell graphical interfaces with HTML.

This PowerShell module allows you to quickly display stylish HTML content and PowerShell commands in a window and a web browser. You can display any HTML content and interact with PowerShell cmdlets, functions or scripts. You can define custom routes or navigate through your file system.

## Show-PSWebGui
### Syntax
```powershell
Show-PSWebGUI [[-InputObject] <Object>] [-Port <Int32>] [-Title <String>] [-Icon <String>] [-CssUri <String>] [-NoWindow] [-DocumentRoot <String>] [<CommonParameters>]
```

### Description
Starts a simple web server, listening on localhost, to display content in HTML format with integrated Bootstrap style.

The content can be a string, an HTML page, cmdlets, functions or complex powershell scripts.
The server can execute and display local HTML or PS1 files. Custom CSS and Javascript are also compatible.
    
POST and GET method are available and can be accesses by ``$_POST`` and ``$_GET`` variables, just like within PHP.

### Example
```powershell
Import-Module PSWebGUI

PS C:\> $routes = @{
  "/"={
    "<div>
      <h1>Menú</h1>
      <a href='/showProcesses'><h2>Show Running Processes</h2></a>
      <a href='/showServices'><h2>Show Services</h2></a>
    </div>"
    }

    "/showProcesses" = { Get-Process | Select-Object name, cpu | Format-Html }

    "/showServices" = {
    <div>
      <h1>Services</h1>
      Get-Service | Format-Html
    </div>
    }
}

PS C:\> Show-PSWebGui -InputObject $routes
```

### More info
```powershell
PS C:\> Get-Help Show-PSWebGui -Full
```

## Format-Html
### Syntax
```powershell
Format-Html [-InputObject] <PSObject> [-Darktable] [-Darkheader] [-Striped] [-Hover] [<CommonParameters>]

Format-Html [-InputObject] <PSObject> -Cards <Int32> [<CommonParameters>]

Format-Html [-InputObject] <PSObject> -Raw [<CommonParameters>]
```
### Description
PowerShell cmdlets need to be formated in HTML with Bootstrap style before being displayed. This function converts the output of PowerShell commands, passed by pipeline, to HTML format and adds Bootstrap style classes.
    
Depending on the set of parameters, the output can be converted to table format, card format, or raw. If no parameters are set, by default it is converted to table format.
        
In essence, it is like "ConvertTo-Html -Fragment" PowerShell cmdlet but with Bootstrap styling built-in and another features.

### Example
Get the name and the CPU usage of all running processes in a table format (Bootstrap style).
```powershell
PS C:\> Get-Process | Select-Object Name, CPU | Sort-Object -Property CPU -Descending | Format-Html

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

### Example
Get the name and the status of the first three services in a card format (Bootstrap style) with 3 cards per row.
```powershell
PS C:\> Get-Service | Select-Object Name, Status -First 3 | Format-Html -Cards 3

<div class='row row-cols-3'>
<div class='card col'>
<div class='card-body'>
<h5 class='card-title'>AarSvc_91cd8</h5>
<p class='card-text'>Stopped</p>
</div>
</div>
<div class='card col'>
<div class='card-body'>
<h5 class='card-title'>AdobeARMservice</h5>
<p class='card-text'>Running</p>
</div>
</div>
<div class='card col'>
<div class='card-body'>
<h5 class='card-title'>AJRouter</h5>
<p class='card-text'>Stopped</p>
</div>
</div>
</div>
```

### More info
```powershell
PS C:\> Get-Help Format-Html -Full
```

## Show-PSWebGuiExample
### Description
Displays a basic example GUI to show how this module works.

### Example
```powershell
PS C:\> Show-PSWebGuiExample
```
