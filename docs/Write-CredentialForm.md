---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Write-CredentialForm

## SYNOPSIS
Writes and displays a web page with basic form to enter credentials.

## SYNTAX
```powershell
Write-CredentialForm [[-Title] <string>] [[-Description] <string>] [[-Action] <string>] [[-UsernameLabel] <string>] [[-PasswordLabel] <string>] [[-SubmitLabel] <string>]  [<CommonParameters>]
```

## DESCRIPTION
Writes and displays a web page with a basic form to enter credentials. The form has user and password inputs and a submit button.

By default, the function writes the labels for the inputs and the button, form title and description, but this is all customizable using parameters.

Because credentials will be sent with this form, the method is always POST, it can not be modified. The POST variables for the inputs are ```$_POST["userName"]``` and ```$_POST["Password"]```.

This form is the HTML+Bootstrap version of PowerShell ```Get-Credential``` cmdlet.

## EXAMPLES

### EXAMPLE 1
```powershell
PS> Write-CredentialForm -Action "/login"

<script>document.title='Credential input'</script>
<div class='container'>
<h2 class='mt-3'>Credential input</h2>
<p>Enter your credential</p>

<form method='post' action="/login">
<div class='form-group'>
<label for='usernameInput'>Enter your username</label>
<input type='text' class='form-control' id='usernameInput' name='userName' autofocus>
</div>

<div class='form-group'>
<label for='passwordInput'>Enter your pasword</label>
<input type='password' class='form-control' id='passwordInput' name='Password'>
</div>

<button type='submit' class='btn btn-primary'>Submit</button>
</form>
</div>
```

### EXAMPLE 2
```powershell
PS> Write-CredentialForm -Action "/login" -Title "Login form" -Description "Please, enter your credential to log into the system"

<script>document.title='Login form'</script>
<div class='container'>
<h2 class='mt-3'>Login form</h2>
<p>Please, enter your credential to log into the system</p>

<form method='post' action="/login">
<div class='form-group'>
<label for='usernameInput'>Enter your username</label>
<input type='text' class='form-control' id='usernameInput' name='userName' autofocus>
</div>

<div class='form-group'>
<label for='passwordInput'>Enter your pasword</label>
<input type='password' class='form-control' id='passwordInput' name='Password'>
</div>

<button type='submit' class='btn btn-primary'>Submit</button>
</form>
</div>
```

### EXAMPLE 3
```powershell
PS> Write-CredentialForm -Action "/login" -Title "Login form" -Description "Please, enter your credential to log into the system" -UsernameLabel "Enter your computer login username" -PasswordLabel "Enter your computer login password" -SubmitLabel "Login"

<script>document.title='Login form'</script>
<div class='container'>
<h2 class='mt-3'>Login form</h2>
<p>Please, enter your credential to log into the system</p>

<form method='post' action="/login">
<div class='form-group'>
<label for='usernameInput'>Enter your computer login username</label>
<input type='text' class='form-control' id='usernameInput' name='userName' autofocus>
</div>

<div class='form-group'>
<label for='passwordInput'>Enter your computer login pasword</label>
<input type='password' class='form-control' id='passwordInput' name='Password'>
</div>

<button type='submit' class='btn btn-primary'>Login</button>
</form>
</div>
```

## PARAMETERS

### -Action
Specifies the action attribute. This is the URL where the form will send the data.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Specifies a description for the form. This description will appear as ```<p>``` tag at the top of the form.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: Enter your credential
Accept pipeline input: False
Accept wildcard characters: False
```

### -PasswordLabel
Specifies a label for the password input.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: Enter your password
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubmitLabel
Specifies a label for the submit button.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: Submit
Accept pipeline input: False
Accept wildcard characters: False
```

### -Title
Specifies a title for the form. This title will appear as ```<h2>``` tag at the top of the form. The web page title will be modified too.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 0
Default value: Credential input
Accept pipeline input: False
Accept wildcard characters: False
```

### -UsernameLabel
Specifies a label for the username input.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: Enter your username
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS
### System.Object

## NOTES

## RELATED LINKS