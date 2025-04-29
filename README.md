# PSWebGUI
**PSWebGUI** is a PowerShell module that lets you quickly and easily create web-based graphical interfaces using HTML and Bootstrap. It's perfect for users who want to integrate PowerShell scripts into a simple and functional web interface.


## Key Features
- **Built-in web server**: Run a lightweight web server directly from PowerShell.

- **Custom routes**: Define web routes (```/```) and link them to PowerShell functions or scripts.
  
- **HTML + Bootstrap support**: Design attractive, responsive web interfaces effortlessly.
  
- **GET and POST method support**: Easily handle form input via ```$_GET[]``` and ```$_POST[]```.
  
- **Run and display PowerShell scripts**: Execute and show output from scripts or cmdlets in a separate window or in the browser.

## Requirements
- PowerShell must be run as **Administrator**.

- PowerShell version 5.1 or higher.

## Installation

### From PowerShell Gallery:
```powershell
PS> Install-Module -Name PSWebGui
```

### Manually from Github
1. Download the lastest version of the module from this Github repository.
2. Extract the content of the ZIP into ```C:\Program Files\WindowsPowerShell\Modules```

#### Test
Open PowerShell as an Administrator and run the following command:
```powershell
PS> Show-PSWebGUI "Hello World!"
```
This should open a new window with the text "Hello World!".

## Usage

### Launch a simple web UI
```powershell
# Routes definition
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

# Launch the interface
PS> Show-PSWebGui -InputObject $routes
```
A new window should have opened. Or you can open your browser at ```http://localhost``` to view the interface.

### Customize the port and page title
```powershell
PS> Show-PSWebGui -InputObject $routes -Port 9090 -Title "Admin Panel"
```

## Available Commands
### Show-PSWebGUI
Starts the web server and displays the interface defined by the provided routes.

**Common parameters:**

- ```-InputObject```: Defines routes and their associated content.

- ```-Port```: Server port (default is 80).

- ```-Title```: Sets the page title.

- ```-PublicServer```: Makes the server accessible from other devices on the network.

- ```-Display```: Set the behavior of windows: 'NoGUI' to hide the interface, 'NoConsole' to hide the PowerShell console (terminal/command prompt) or 'Systray' to minimize all to the system tray.

- ```-Icon```: Set the icon for both the interface window and in browser favicon.

#### More info
[Visit command documentation for more detailed info](../main/docs/Show-PSWebGUI.md)

### Format-Html
Converts PowerShell output into styled HTML tables or cards using Bootstrap.

#### Example:
```powershell
PS> Get-Process | Select-Object Name, CPU | Format-Html

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

### Hide-PSConsole / Show-PSConsole
Hides / show the PowerShell console window (the terminal). Useful for background scripts.
```powershell
PS> Hide-PSConsole
PS> Show-PSConsole
```

## Example project
Previously there was a built-in function within this module designed to show the posibilities and how this module works.
This function has now been moved, as a standalone script, to a separate project.

[Visit Show-PSWebGUIExample project](https://github.com/JLInF97/PSWebGUIExample)