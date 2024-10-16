﻿# PSWebGui
## about_PSWebGui


# SHORT DESCRIPTION
A fast way to create and display PowerShell graphical interfaces using HTML


# LONG DESCRIPTION
This PowerShell module is a set of tools that allows you to quickly create and display fancy HTML graphical user interfaces. The module allows to interact with PowerShell cmdlets, functions, or scripts and join the result to the graphic design in HTML.

PowerShell acts, in this module, as a web server language, like PHP. You can define custom routes or navigate through your file system.

The HTML is styled with Bootstrap CSS framework to provide better look and responsive content in a fast way.

**Important note!** To use this module, you must **_run PowerShell as an Administrator_**.

# CREATING A GRAPHIC INTERFACE
To display a graphic interface, the structure and content needs to be created first, saved into a variable (hashtable) and then, passed to the main funtion `Show-PSWebGui`.

This is a basic structure:
```powershell
$routes = @{

	"/" = {
		"
		<h1>Index</h1>
		<a href='/getdate'>Show date</a>
		"
	}
	
	"/getdate" = {
		"<h1>Date</h1>"
		"Today is:" Get-Date
	}
}
```

```$routes``` is a PowerShell hastable object (```@{}```) where all the content will be saved.

Inside the main hashtable, the different urls for the pages are defined as hashtable keys. The associated values ​​will be the HTML and PowerShell code, always between braces ```{}```.
HTML code must be between quotes.

Once the structure and content has been created, the main function ```Show-PSWebGui``` must be invoked with the defined object passed as parameter.
```powershell
PS> Show-PSWebGui -InputObject $routes
```

# $_GET AND $_POST VARIABLES
The module has ```$_GET[]``` and ```$_POST[]``` variables defined in global scope to store HTTP GET and POST request methods. The data are stored in these variables when you submit a form or specify the data within the URL (GET method only).

These variables work the same as in PHP, they are hashtables and you can access the stored values by specifing their names in brackets.

You have this form in HTML:
```html
<form method="post">
<input type="text" name="username">
<input type="password" name="password">
</form>
```

Once the form is sent, this is the way to access the data in PowerShell:
```powershell
$_POST["username"]
$_POST["password"]
```

# $_SERVER VARIABLE
```$_SERVER[]``` is a hashtable variable defined in global scope to store information about server environment and execution.

List of ```$_SERVER[]``` index:

- **PORT**: The port number that is using by the server.
- **DOCUMENT_ROOT**: The document root directory under which the server is executing.
- **PID**: Process ID number of the PowerShell server.
- **URL**: URL and port on wich the server is listening.
- **REQUEST_METHOD**: Which request method was used to access the page; 'GET' or 'POST'.
- **REQUEST_URI**: The URI which was given in order to access this page; for instance, '/services/get'.

# STOPPING SERVER
When you execute the ```Show-PSWebGui```function, a simple web server starts and a GUI window appears displaying the content.
There are some ways to stop the server and close the GUI:

- Closing GUI window clicking X button: This action will close the GUI window and oderly stop the server. This is the recomended way to stop the server when the GUI is displaying.
- Sending ```/stop()``` or ```/exit()``` to the server: This will stop the web server, but will not close the GUI window. This is the recomended way to stop the server when the GUI is not displaying.
- Executing ```Stop-PsWebGui``` function in another PowerShell process: This will stop the web server, but will not close the GUI window. This way is usefull when the GUI window is not displaying and you do not have access to any web browser.
- Executing ```Stop-PsWebGui -Force``` function in another PowerShell process: This function will try to orderly stop the server and kill the PowerShell process. This way is usefull when you need to completely close an unresponsive instance or an open GUI window in a non-inteactive enviorement.
- Killing PowerShell process: This is not a recomended action because the server will not stop correctly, the changes made may not be saved and another thread may still be running in background.

## $_CLOSESCRIPT VARIABLE
```$_CLOSESCRIPT``` is an empty scriptblock, defined in global scope, that will be invoked just before the web server is closed.
If you need some code to be executed just when the server stops, put the code inside this scriptblock and, if it loads during runtime, it will invoked just before the server stops.

Having this structure:
```powershell
$routes = @{

	"/" = {
		"
		<h1>Index</h1>
		<a href='/getdate'>Show date</a>
		"
	}
	
	"/getdate" = {
		"<h1>Date</h1>"
		"Today is:" Get-Date
		$_CLOSESCRIPT={
			Write-Host "Saying this before server stops"
		}
	}
}
```
the code inside ```$_CLOSESCRIPT``` will only be invoked if you send ```/getdate``` to the server before stopping it.

# ISE SNIPPETS
This module has some snippets for using them with **PowerShell ISE**.

To import the snippets in this session, enter the following cmdlet in *PowerShell ISE*:
```powershell
PS> Import-IseSnippet -Module PSWebGui -ListAvailable
```

Or copy them from ```Snippets``` module folder to ```%userprofile%\Documents\WindowsPowerShell\Snippets``` if you want them to be imported every time you open PowerShell ISE

# HIDE AND SHOW CONSOLE
This module brings two functions for hidding and showing the current PowerShell console window.

Get more information about these functions.

```powershell
PS> Get-Help Show-PSConsole
PS> Get-Help Hide-PSConsole
```

# SYTEM TRAY
From version 0.19.0, it is posible to minimize the GUI and PowerShell windows to the system tray to continue working in the background and restore them when need it.

To do that run:

```powershell
PS> Show-PSWebGUI -Display Systray [...]
```

The function will display the same icon as the GUI window on the system tray and add a context menu to it. The context menu, by default, will have these options:
- Show GUI: Displays the GUI window. Use close (X) button on the GUI itself to hide the GUI again.
- Show/Hide PS console: Show or hide the PowerShell console. Use this option to show or hide the console, do not use the buttons on the console itself.
- Exit: Close the GUI, PowerShell console, stop the server and close PowerShell process.

![Screenshot of the icon and menu in the system tray.](images/pswebgui_systray.png)

# SEE ALSO
Reading main function help is recomended.
```powershell
PS> Get-Help Show-PSWebGui -Full
```