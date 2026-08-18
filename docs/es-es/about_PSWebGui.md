# PSWebGui
## about_PSWebGui


# SHORT DESCRIPTION
Una forma rápida de crear y mostrar interfaces gráficas en PowerShell usando HTML.


# LONG DESCRIPTION
Este módulo de PowerShell contiene un conjunto de herramientas que te van a permitir crear y mostrar rapidamente interfaces gráficas de usuario (GUI) amigables usando lenguaje HTML. El módulo permite interactuar con comandos (cmdlets), funciones o scripts de PowerShell y mostrar el resultado con el diseño gráfico en HTML.

PowerShell actua en este módulo como un lenguaje de servidor web, parecido a PHP. Puedes definir rutas personalizadas o navegar a través de tu sistema de archivos.

El HTML es presentado con el framework de CSS 'Boootstrap' para proporcionar un diseño mejorado y adaptable de forma rápida.

**Nota importante!** Para usar este módulo, tienes que **_ejecutar PowerShell como Administrador_**.

# CREANDO UNA INTERFAZ GRÁFICA
Para mostrar una interfaz gráfica, primero tiene que ser creada la estructura y el contenido, guardarlo en una variable tipo tabla (hastable) y, finalmente, pasar la variable como argumento de la función `Show-PSWebGui`.

Esta es una estructura básica:
```powershell
$routes = @{

	"/" = {
		"
		<h1>Indice</h1>
		<a href='/getdate'>Mostrar fecha</a>
		"
	}
	
	"/getdate" = {
		"<h1>Fecha</h1>"
		"Hoy es:" Get-Date
	}
}
```

```$routes``` es un objeto hastable de PowerShell (```@{}```) donde se guardará todo el contenido para mostrar.

Dentro de la hastable, se definen, como claves, las diferentes direcciones (URLs) para las páginas que se van a mostrar. El valor asociado a cada clave será el código HTML y PowerShell, en forma de bloque de script ```{}```. Dentro de los corchetes, el código HTML se escribe entre comillas.

Una vez que la estructura y el contenido se han creado, se llama a la función principal ```Show-PSWebGui``` con el objeto pasado por parámetro.
```powershell
PS> Show-PSWebGui -InputObject $routes
```

# VARIABLES $_GET Y $_POST
El módulo define ```$_GET[]``` y ```$_POST[]``` como variables globales para almanecar las peticiones GET y POST de HTTP. La información se almacena en estas variables cuando envías un formulario o cuando defines los datos en la URL (solo para el método GET).

Estas variables funcionan igual que en PHP, son diccionarios y puedes acceder a los valores almacenados especificando, entre corchetes, el nombre de su clave.

Tienes este formulario en HTML:
```html
<form method="post">
<input type="text" name="username">
<input type="password" name="password">
</form>
```

Cuando el formulario se envía, la manera de acceder a los datos en PowerShell es esta:
```powershell
$_POST["username"]
$_POST["password"]
```

# VARIABLE $_SERVER
```$_SERVER[]``` es una variable de diccionario, definida en el ámbito global, para almacenar información relativa al entorno y ejecución del servidor.

Lista del índice de ```$_SERVER[]```:

- **PORT**: El número de puerto que está usando el servidor.
- **DOCUMENT_ROOT**: El directorio raíz debajo del cual el servidor se está ejecutando.
- **PID**: Número ID del proceso de servidor PowerShell.
- **URL**: URL y puerto en el que está escuchando el servidor.
- **REQUEST_METHOD**: Qué método ha sido usado para acceder a la página; 'GET' o 'POST'.
- **REQUEST_URI**: La URI de acceso a esta página. Por ejemplo, '/services/get'.

# PARAR EL SERVIDOR
Cuando ejecutas la función ```Show-PSWebGui```, arranca un servidor web simple y una ventana de interfáz gráfica aparece mostrando el contenido.
Hay varias formas de parar el servidor y cerrar la ventana:

- Cerrar la ventana pinchando en el botón X: Esta acción cierra la ventana de interfáz gráfica y detiene el servidor de forma ordenada. Esta es la opción recomendada para detener el servidor cuando está mostrando la interfáz gráfica.
- Enviar ```/stop()``` o ```/exit()``` al servidor: Esto detiene el servidor web, pero no cierra la ventana de interfáz gráfica. Esta es la opción recomendada para detener el servidor cuando no se está mostrando la interfáz gráfica.
- Ejecutar la función ```Stop-PsWebGui``` en otro proceso de PowerShell: Esto detiene el servidor web, pero no cierra la ventana de interfáz gráfica. Esta vía es útil cuando no se está mostrando la ventana de interfáz gráfica y no tienes acceso a ningún navegador web.
- Ejecutar la función ```Stop-PsWebGui -Force``` en otro proceso de PowerShell: Esta función intentará detener el servidor web de forma ordenada y matar el proceso de PowerShell. Esta opción es útil cuando necesitas cerrar completamente una instancia que no responde o una ventana de interfáz gráfica abierta en un entorno no interactivo.
- Killing PowerShell process: This is not a recomended action because the server will not stop correctly, the changes made may not be saved and another thread may still be running in background.
- Terminar el proceso de PowerShell: Esta acción no es recomendable ya que el servidor web no se detiene correctamente, los cambios no guardados podrían perderse y pueden quedar procesos corriendo en segundo plano.

## VARIABLE $_CLOSESCRIPT
La variable ```$_CLOSESCRIPT``` es un bloque de script, definido en el ámbito global, que se ejecutará justo antes de que el servidor web se cierre.
Si necesitas que algún código se ejecute justo antes de que el servidor se detenga, escríbelo dentro de esta variable de bloque de código.

Teniendo esta estructura:
```powershell
$routes = @{

	"/" = {
		"
		<h1>Indice</h1>
		<a href='/getdate'>Mostrar fecha</a>
		"
	}
	
	"/getdate" = {
		"<h1>Fecha</h1>"
		"Hoy es:" Get-Date
		$_CLOSESCRIPT={
			Write-Host "Diciendo esto antes de que el servidor se cierre."
		}
	}
}
```
el código dentro de ```$_CLOSESCRIPT``` solo se ejecutará si primero lo cargas enviando la petición ```/getdate```.

# FRAGMENTOS DE CÓDIGO DEL ISE
Este módulo incluye algunos fragmentos de código para usarlos en el editor **PowerShell ISE**.

Para importar los fragmentos de código en la sesión, introduce el siguiente comando en **PowerShell ISE**:
```powershell
PS> Import-IseSnippet -Module PSWebGui -ListAvailable
```

o copialos desde la carpeta ```Snippets``` del módulo a ```%userprofile%\Documents\WindowsPowerShell\Snippets``` si quieres que se importen cada vez que abres PowerShell ISE.

# MOSTRAR Y OCULTAR LA CONSOLA
Este módulo tiene dos funciones para ocultar y mostrar la ventana de consola de PowerShell actual.

Obten más información sobre estas funciones.

```powershell
PS> Get-Help Show-PSConsole
PS> Get-Help Hide-PSConsole
```

# BANDEJA DEL SISTEMA
Desde la versión 0.19.0, es posible minimizar la ventana de la interfáz gráfica y de PowerShell en la bandeja del sistema para que continuen trabajando en segundo plano y restaurarlas de nuevo cuando se necesiten.

Para hacerlo, ejecuta:

```powershell
PS> Show-PSWebGUI -Display Systray [...]
```

La función mostrará, en la bandeja del sistema, el mismo icono que la ventana de interfáz gráfica y le añadirá un menú contextual. El menú contextual, por defecto, tendrá estas opciones:
- Show GUI: Muestra la ventana de interfáz gráfica. Usa el botón de cerrar la ventana (X) para volver a ocultarla.
- Show/Hide PS console: Muestra u oculta la consola de PowerShell. Usa este botón para ocultar la ventana de consola de PowerShell, no uses los botones de la ventana de la consola.
- Exit: Cierra la ventana de interfáz gráfica, la consola de PowerShell, detiene el servidor web y cierra el proceso de PowerShell.

![Screenshot of the icon and menu in the system tray.](images/pswebgui_systray.png)

# CONSULTE TAMBIÉN
Se recomienda leer la ayuda de la función principal.
```powershell
PS> Get-Help Show-PSWebGui -Full
```