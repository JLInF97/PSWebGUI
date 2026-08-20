---
external help file: PSWebGui-help.xml
Module Name: PSWebGui
online version:
schema: 2.0.0
---

# Write-CredentialForm

## SINOPSIS
Muestra una página web con un formulario básico para intriducir credenciales.

## SINTAXIS
```powershell
Write-CredentialForm [[-Title] <string>] [[-Description] <string>] [[-Action] <string>] [[-UsernameLabel] <string>] [[-PasswordLabel] <string>] [[-SubmitLabel] <string>]  [<CommonParameters>]
```

## DESCRIPCIÓN
Muestra una página web con un formulario básico para intriducir credenciales. El formulario tiene campos para introducir usuario, contraseña y un botón para enviar.

Por defecto, la función escribe las etiqeutas de los campos y del botón, el título del formulario y su descripción, pero esto es personalizable usando parámetros.

Puesto que con este formualrio se envían credenciales, el método de envío será siempre POST, no se puede modificar. Las variables POST para acceder los campos de entrada son ```$_POST["userName"]``` y ```$_POST["Password"]```.

Este formulario es la versión HTML+Bootstrap del comando ```Get-Credential``` de PowerShell.

## EJEMPLOS

### EJEMPLO 1
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

### EJEMPLO 2
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

### EJEMPLO 3
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

## PARÁMETROSS

### -Action
Especifica el atributo "action" del formulario. Es la URL donde el formulario enviará la información.

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
Especifica una descripción para el formulario. Esta descripsión aparecera en una etiqueta <p> al principio del formulario.

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
Especifica una etiqueta para el campo contraseña.

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
Especifica una etiqueta para el botón de enviar.

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
Especifica un título para el formualrio. El título aparecerá en una etiqueta <h2> al principio del formulario. También se modificará el título de la página web.

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
Especifica una etiqueta para el campo nombre de usuario.

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
Este cmdlet admite los parámetros comunes: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction y -WarningVariable. Para obtener más información, vea [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## ENTRADAS

## SALIDAS
### System.Object

## NOTAS

## VÍNCULOS RELACIONADOS