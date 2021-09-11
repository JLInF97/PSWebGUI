# PSWebGui
## about_PSWebGui


# SHORT DESCRIPTION
A fast way to create and display PowerShell graphical interfaces with HTML


# LONG DESCRIPTION
This PowerShell module is a set of tools that allows you to quickly create and display fancy HTML graphical user interfaces. The module allows to interact with PowerShell cmdlets, functions, or scripts and join the result to the graphic design in HTML.

PowerShell acts, in this module, as a web server language, like PHP. You can define custom routes or navigate through your file system.

The HTML is styled with Bootstrap CSS framework to provide better look and responsive content in a fast way.

**Important note!** To use this module, PowerShell must have been **_run as Administrator_**.

# CREATING A GRAPHIC INTERFACE
To display a graphic interface, the structure and content needs to be created first, saved into a variable (hashtable) and then, passed to the main funtion `Show-PSWebGui`.

This is the basic structure:
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

Inside the main hashtable, the different urls for the pages are defined as hashtable keys. The associated values ​​will be the HTML and PowerShell code, always between braces ```{}```
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

# See also
Reading main function help is recomended
```powershell
PS> Get-Help Show-PSWebGui -Detailed
```