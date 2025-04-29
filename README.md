# PSWebGUI
A fast way to create and display PowerShell graphical interfaces using HTML.

This PowerShell module is a set of tools that allows you to quickly create and display fancy HTML graphical user interfaces. The module allows you to interact with PowerShell cmdlets, functions, or scripts and combine the result with HTML to create graphical interfaces.

PowerShell acts, in this module, as a web server language, in a similar way to PHP. You can define custom routes or navigate through your file system.

The HTML is styled, by default, with Bootstrap v4.6 CSS framework to provide better look and responsive content quickly.

**Important note!** To use this module, you must **_run PowerShell as an Administrator_**.

[Visit about file for more detailed info](../main/docs/about_PSWebGui.md)


## Installation

- Install from the PowerShell Gallery:
```powershell
PS> Install-Module -Name PSWebGui
```
or
- Download from Github repository
1. Download the lastest version of the module from this Github repository.
2. Extract the content of the ZIP into ```C:\Program Files\WindowsPowerShell\Modules```

#### Test
Open PowerShell as an Administrator and run the following command. This should open a new window with the text "Hello World!".
```powershell
PS> Show-PSWebGUI "Hello World!"
```

## Usage

### Show-PSWebGui function
#### Syntax
```powershell
Show-PSWebGUI [[-InputObject] <Object>] [-Port <Int32>] [-Title <String>] [-Icon <String>] [-DocumentRoot <String>] [-Display {NoGUI | NoConsole | Systray}] [-NoHeadTags] [-PublicServer] [-Page404 <String>] [-AsJob] [<CommonParameters>]
```

#### Description
This is the main function. This function starts a simple web server to display the structure and content passed within an object.

The content can be a string, an HTML page, cmdlets, functions or complex powershell scripts. The HTML content will be stylized with Bootstrap v4.6 CSS framework.
The server can execute and display local HTML or PS1 files. Custom CSS and Javascript are also compatible.
    
POST and GET methods are available and can be accesses by ```$_POST[]``` and ```$_GET[]``` variables, just like within PHP.

#### Example: Create basic graphic interface
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
[Visit command documentation for more detailed info](../main/docs/Show-PSWebGUI.md)

### Format-Html function
#### Syntax
```powershell
Format-Html [-InputObject] <PSObject> [-Darktable] [-Darkheader] [-Striped] [-Hover] [-Id <String>] [<CommonParameters>]

Format-Html [-InputObject] <PSObject> -Cards <Int32> [<CommonParameters>]

Format-Html [-InputObject] <PSObject> -Raw [<CommonParameters>]
```
#### Description
PowerShell cmdlets need to be formated in HTML before being displayed. This function converts the output of PowerShell commands, passed by pipeline, to HTML format and adds Bootstrap style classes.
    
Depending on the set of parameters, the output can be converted to table format, card format, or raw (no style). If no parameters are set, by default it is converted to table format.

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
...
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
[Visit command documentation for more detailed info](../main/docs/Format-Html.md)


### Hide-PSConsole \ Show-PSConsole functions
#### Description
Hide or show the current PowerShell console window.
Usefull for any script that needs to hide the console.

#### Example
```powershell
PS> Hide-PSConsole
PS> Show-PSConsole
```

## Example project
Previously there was a built-in function within this module designed to show the posibilities and how this module works.
This function has now been moved, as a standalone script, to a separate project.

[Visit Show-PSWebGUIExample project](https://github.com/JLInF97/PSWebGUIExample)