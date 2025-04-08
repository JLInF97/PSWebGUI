# Load assembly to show/hide the powershell console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

$global:console_display=1


#.ExternalHelp en-us\PSWebGui-help.xml
Function Show-PSWebGUI
{

    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$false,Position=0,ValueFromPipeline=$true)][Alias("Routes","Input")]$InputObject="",
    [Parameter(Mandatory=$false)][int]$Port=80,
    [Parameter(Mandatory=$false)][string]$Title="PoweShell Web GUI",
    [Parameter(Mandatory=$false)][string]$Icon,
    [Parameter(Mandatory=$false)][Alias("Root")][string]$DocumentRoot=$PWD.path,
    [Parameter(Mandatory=$false)][ValidateSet("NoGUI", "NoConsole", "Systray")][string]$Display,
    [Parameter(Mandatory=$false)][switch]$NoHeadTags,
    [Parameter(Mandatory=$false)][switch][Alias("Public")]$PublicServer,
    [Parameter(Mandatory=$false)][string]$Page404,
    [Parameter(Mandatory=$false)][switch]$AsJob

    )

    # Start the server in a background job. Calling the function itself in background and break the execution in foreground
    if ($AsJob){
        $parameters=$PSBoundParameters
        $parameters.AsJob=$false

        Start-Job -ScriptBlock {
            $parameters=$using:parameters
            Show-PSWebGUI @parameters
        }

        break # Avoid to continue normal execution in foreground
    }

    # Hide the PS console if parameter -Display "NoConsole" is set
    if ($Display -eq "NoConsole"){
        Hide-PSConsole
    }

    # URL + PORT to use
    if ($PublicServer){
        $url="http://+:$port/"
    }else{
        $url="http://localhost:$port/"
    }

    # Create virtual drive in root directory
    $fileserver=New-PSDrive -Name FileServer -PSProvider FileSystem -Root $DocumentRoot

    # Scriptblock to execute when closing server
    $global:_CLOSESCRIPT={}

    # Global $_SERVER variables
    $global:_SERVER=@{
        "PORT"=$port
        "Document_Root"=$DocumentRoot
        "PID"=$PID
        "URL"=$url
    }


    # Save PID and Port for this instance in a temp file
    $instance_properties=[PSCustomObject]@{
        "PID"="$PID"
        "Port"="$port"
        "URL"="$url"
        "Start time"=Get-Date -Format "yyyy-MM-dd hh:mm:ss"
    }

    $instance_properties | ConvertTo-Json | Out-File -FilePath "$env:temp\pswebgui_$port.tmp"
    Write-Verbose "Instance properties saved in $env:temp\pswebgui_$port.tmp"




    #region Path cleaning
    <#
    ===================================================================
                  INPUTOBJECT VALIDATION AND PATH CLEANING
    ===================================================================
     
     Validates $InputObject.
     Clean paths in $InputObject. Remove duplicated "/", dots and last "/"

    #>

    # If $InputObject is null, throw an error and stop execution
    if ($InputObject -eq $null){
        Write-Error -Message "Input object is null" -Category InvalidArgument -CategoryTargetName "-InputObject" -CategoryTargetType "Null" -RecommendedAction "Do not set -InputObject if you don't want to pass any value"
        break
    }

    # If $InputObject is not string or hashtable, throw an error and stop execution
    if (!($InputObject -is [hashtable]) -and !($InputObject -is [string])){
        Write-Error -Message "Object type not valid for InputObject. Only [String] or [hashtable] accepted" -Category InvalidType -CategoryTargetName "-InputObject" -CategoryTargetType "InvalidObjectType"
        break
    }
    
    # If $InputObject is a hashtable (not a string)
    if ($InputObject -is [hashtable]){
        
        # If $InputObject does not contain index key "/", throw an error and stops execution
        If (!$InputObject.ContainsKey("/")){
            Write-Error -Message "Index path ('/') not found in input object" -Category InvalidData -CategoryTargetName "'/'" -CategoryTargetType "Not found"
            break
        }

        # Get keys
        $keys=$($InputObject.Keys)

        # Foreach key
        $keys | foreach {
            $oldkey=$_

            # If there are /exit() or /stop() urls, trow an error
            if (($_ -eq "/exit()") -or ($_ -eq "/stop()")){
                Write-Error -Message "$_ url is reserved" -Category InvalidData -CategoryTargetName "$_" -CategoryTargetType "Omited"
            }
        
            # If key length > 1 (ignore root "/")
            if ($oldkey.length -gt 1){
            
                # Remove last "/". This not generate error
                $oldkey=$oldkey -replace '\/+$',''

                # Remove dots at the end and betwen "/" and whitespaces
                $newkey=$oldkey -replace '\/*\.+\/*$|\.+(?=\/)|\s'

                # Replace many "/" with just one of them
                $newkey=$newkey -replace '\/{2,}','/'

                # If a modifictaion has made. (Removed last "/" doesnt count)
                if ($newkey -ne $oldkey){
                    # Send a warning
                    Write-Warning -Message "URL is not well formed. URL: $oldkey -> $newkey"

                    # Create clean key with old content (value)
                    $InputObject[$newkey]=$InputObject[$oldkey]

                    # Remove old key
                    $InputObject.Remove($oldkey)
                }
            }

        }
    }
    #endregion




    #region Favicon
    <#
    ===================================================================
                            FAVICON PROCESSING
    ===================================================================

    Vars:
        - $icon: string function parameter
        - $iconpath: Full absolute icon path used in WPF
        - $favicon: Relative icon path to $DocumentRoot, used in HTML (favicon)

    #>

    # First, test if icon path has been passed (as parameter)
    if ($icon -ne ""){
        
        # If icon path exists as an absolute path (absolute path passed)
        if (Test-Path $icon){
            
            # $iconpath is icon path itself
            $iconpath=$icon

            # $favicon is empty for now
            $favicon=""

            # If icon is inside $DocumentRoot, get relative path for favicon
            if ($icon.Contains($DocumentRoot)){
                $favicon=$icon.Substring($DocumentRoot.Length,$icon.Length-$DocumentRoot.Length).Replace("\","/")
            }
        

        # If icon path exists as relative to root (relative path passed)
        }elseif (Test-Path "$DocumentRoot/$icon"){
            
            # Get the absolute path for WPF
            $iconitem=get-item "$DocumentRoot/$icon"
            $iconpath=$iconitem.FullName

            # $favicon is icon relative path itself
            $favicon=$icon
        }
    }

    #endregion


    #region Page 404 processing
    <#
    ===================================================================
                            PAGE 404 PROCESSING
    ===================================================================
    #>

    if ($page404){
        if (Test-Path $page404 -PathType Leaf -Include "*.html","*.htm","*.txt","*.xhtml"){
            $page404HTML=Get-Content $page404
        }
        else{
            Write-Error -Message "Page404 parameter must be a file with one of these extensions: html, hmt, xhtml, txt" -Category InvalidData -CategoryTargetName "$page404" -CategoryTargetType "Invalid file"
        }
    }

    #endregion



    #region Starting server
    <#
    ===================================================================
                               STARTING SERVER
    ===================================================================
    #>

    # Create HttpListener Object
    $SimpleServer = New-Object Net.HttpListener

    # Tell the HttpListener what port to listen on
    $SimpleServer.Prefixes.Add($url)

    # Start up the server
    $SimpleServer.Start()

    # Load bootstrap
    $bootstrapContent=Get-Content "$PSScriptRoot\Assets\bootstrap.min.css"

    Write-Host "GUI started" -ForegroundColor Green

    #endregion


     #region Graphic interface
    <#
    ===================================================================
                          GRAPHIC INTERFACE (GUI)
    ===================================================================
    #>

    # If -Display NoGUI, dont create an internal WebBrowser
    if ($Display -ne "NoGUI"){

        # Create a scriptblock that waits for the server to launch and then opens a web browser control
        $UserWindow = {
            
            param ($port,$title,$iconpath,$display)

                # XAML
                [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
                [xml]$XAML = @'
                <Window
                    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
                    Title="PoweShell Web GUI" WindowStartupLocation="CenterScreen">

                    <Window.TaskbarItemInfo>
                        <TaskbarItemInfo/>
                    </Window.TaskbarItemInfo>

                        <WebBrowser Name="WebBrowser"></WebBrowser>

                </Window>
'@

                #Read XAML
                $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
                $Form=[Windows.Markup.XamlReader]::Load( $reader )

                # Set title and icon
                $Form.Title=$title               
                $Form.Icon=$iconpath # Icon for window title bar
                $Form.TaskbarItemInfo.Overlay=$iconpath # Icon for taskbar

                # URL for GUI
                $guiURL="http://localhost:$port/"
                $exiturl=$guiURL+"exit()"

                # WebBrowser navigate to localhost
                $WebBrowser = $Form.FindName("WebBrowser")
                $WebBrowser.Navigate($guiURL)

                if ($Display -eq "Systray"){
                    Show-SystrayMenu
                }
                else{
                    # Show GUI
                    $Form.ShowDialog()
                    Start-Sleep -Seconds 1

                    # Once the end user closes out of the browser we send the exit url to tell the server to shut down.
                    (New-Object System.Net.WebClient).DownloadString($exiturl);
                }
        }
 
        # Prepare the initial session state for runspace. Pass the Show-SystrayMenu function definition
        $ShowSystrayMenu_function_definition = Get-Content Function:\Show-SystrayMenu
        $SessionStateFunction = New-Object System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList 'Show-SystrayMenu', $ShowSystrayMenu_function_definition
        $InitialSessionState= [InitialSessionState]::CreateDefault()
        $InitialSessionState.Commands.Add($SessionStateFunction)

        # Create runspace for GUI
        $RunspacePool = [RunspaceFactory]::CreateRunspacePool($InitialSessionState)
        $RunspacePool.ApartmentState = "STA"
        $RunspacePool.Open()
        $Jobs = @()
 
        # Create job and add to runspace
        $Job = [powershell]::Create().AddScript($UserWindow).AddArgument($port).AddArgument($title).AddArgument($iconpath).AddArgument($display)#.AddArgument($_)
        $Job.RunspacePool = $RunspacePool
        $Jobs += New-Object PSObject -Property @{
            RunNum = $_
            Pipe = $Job
            Result = $Job.BeginInvoke()
        }


    }

    #endregion


    #region Server requests
    <#
    ===================================================================
                            SERVER REQUETS
    ===================================================================

    Vars:
        - $Context.Request: Contains details about the request
        - $Context.Response: Is basically a template of what can be sent back to the browser
        - $Context.User: Contains information about the user who sent the request. This is useful in situations where authentication is necessary

    #>
    while($SimpleServer.IsListening)
    {
        Write-Verbose "Listening for request"

        # Tell the server to wait for a request to come in on that port.
        $Context = $SimpleServer.GetContext()

        #Once a request has been captured the details of the request and the template for the response are created in our $context variable
        Write-Verbose "Context has been captured"


        # Sometimes the browser will request the favicon.ico which we don't care about. We just drop that request and go to the next one.
        if($Context.Request.Url.LocalPath -eq "/favicon.ico")
        {
            do
            {

                $Context.Response.Close()
                $Context = $SimpleServer.GetContext()

            }while ($Context.Request.Url.LocalPath -eq "/favicon.ico")
        }


        <#
            SERVER EXIT
        #>

        # Creating a friendly way to shutdown the server
        if($Context.Request.Url.LocalPath -eq "/stop()" -or $Context.Request.Url.LocalPath -eq "/exit()")
        {
            
            # Invoke scriptblock before stop server
            $_CLOSESCRIPT.Invoke()

            # Write instance properties file again, in case it was deleted
            $instance_properties | ConvertTo-Json | Out-File -FilePath "$env:temp\pswebgui_$port.tmp"
            Write-Verbose "Instance properties saved in $env:temp\pswebgui_$port.tmp"

            # Send a text to inform about the server stopped. Send different message dependig if -Display NoGUI was set
            if ($Display -ne "NoGUI"){
                $result="<script>document.title='Server stopped. Bye!'</script>Server stopped. Please, close the GUI window. Bye!"
            }
            # -Display NoGUI set
            else{
                $result="<script>document.title='Server stopped. Bye!'</script>Server stopped. Bye!"
            }

            $buffer = [System.Text.Encoding]::UTF8.GetBytes($result)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)


            # Close response and stop the server
            $Context.Response.Close()
            $SimpleServer.Stop()
            Write-Verbose "Server stopped"

            # -Display NoGUI or Systray, dont close a non-existent Window
            if ($Display -ne "NoGUI" -and $Display -ne "Systray"){
                $RunspacePool.Close()
                Write-Verbose "GUI closed"
     
            }

            # Remove properties file
            Remove-Item "$env:temp\pswebgui_$port.tmp" -Force

            break

        }


        
    
        #region Handly URLs
        <#
        ===================================================================
                                HANDLY URLS
        ===================================================================
        #>

        #region Header tags
        # If -NoHeadTags is set, do not display html header tags
        If ($NoHeadTags -eq $false){

            # Make html head template
            $htmlhead=(Get-Content -Path "$PSScriptRoot\Assets\htmlHeadTemplate.html" -Encoding UTF8).Replace("@@favicon",$favicon).Replace("@@style",$bootstrapContent).Replace("@@title",$title)

            # Style can't be applied with a <link href=''> tag because the browsers security restriction to access system local paths. For this reason, the style must be applied in
            # raw format right between a <style> tag.

            # Closing tags
            $htmlclosing="`n</body>`n</html>"
        }
        #endregion
            
            #region Method processing

            # POST processing
            if ($Context.Request.HasEntityBody){
                    
                $global:_SERVER["REQUEST_METHOD"]="POST"
                $request = $Context.Request
                $length = $request.contentlength64
                $buffer = new-object "byte[]" $length

                [void]$request.inputstream.read($buffer, 0, $length)
                $body = [system.text.encoding]::ascii.getstring($buffer)
                                    
                # Split post data
                $global:_POST = @{}
                $body.split('&') | ForEach-Object {
                    $part = $_.split('=')

                    # POST variable name
                    $post_name=$part[0]

                    # Decode POST variable value
                    $post_value=[System.Web.HttpUtility]::UrlDecode($part[1])
                    
                    # If post variable name is already in $_POST collection, add new value to array
                    if ($global:_POST.ContainsKey($post_name)){
                        [array]$global:_POST[$post_name]+=$post_value
                    }
                    else{
                        $global:_POST.add($post_name, $post_value)
                    }
                }


            # GET processing
            }else{
                
                $global:_SERVER["REQUEST_METHOD"]="GET"
                $global:_GET = [System.Web.HttpUtility]::ParseQueryString($Context.Request.Url.Query)
            }

            #endregion

                
            #region URL content processing

            # $localpath is the relative URL (/home, /user/support)
            $localpath=$Context.Request.Url.LocalPath
            $global:_SERVER["REQUEST_URI"]=$localpath

            # Remove last / in URL, if URL is */
            if ($localpath.Length -gt 1){
                $localpath=$localpath -replace '\/+$',''
            } 

            # If $localpath is not a custom defined path in $InputObject, means it can be a filesystem path or a string
            if ($InputObject[$LocalPath] -eq $null){
                    
                # $localpath is a file
                if (Test-Path "FileServer:$localpath" -PathType Leaf){
                    
                    $getContentParams=@{
                        Path="FileServer:$localpath"
                        ReadCount=0
                    }

                    # Compatibility with newest and older PS Version for Get-Content command
                    if ($PSVersionTable.PSVersion.Major -gt 6){
                        $getContentParams.AsByteStream=$true
                    }
                    else{
                        $getContentParams.Encoding="Byte"
                    }

                    # Convert the file content to bytes from path
                    $buffer = Get-Content @getContentParams

                    
                # $InputObject is a string and $localpath is in /
                }elseif (($InputObject -is [string]) -and ($localpath -eq '/')){
                        
                    Write-Verbose "A [string] object was returned."
                    $result="$htmlhead $InputObject $htmlclosing"

                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($result)
                    $context.Response.ContentLength64 = $buffer.Length
                }
                    
                # $localpath is neither a file nor a defined route but is representing a path that its not found
                else{
                    
                    if ($page404HTML){
                        $result=$page404HTML
                    }else{
                        $result="<html>`n<head>`n<title>404 Not found</title>`n<body>`n<h1>404 Not found</h1>`n</body>`n</html>"
                    }
                    
                    $Context.Response.StatusCode=404

                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($result)
                    $context.Response.ContentLength64 = $buffer.Length
                }


            # $localpath is defined in $InputObject, so is not a filesystem path
            }else{
    
                # Get the content or script defined for this path
                $routecontent=$InputObject[$LocalPath]

                # Get the current title
                $originaltitle=$title

                # Execute the scriptblock
                $result="$htmlhead $(.$routecontent)"

                # Add closing html tags
                $result+="$htmlclosing"

                # Convert the result to bytes from UTF8 encoded text
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($Result)

                # Let the browser know how many bytes we are going to be sending
                $context.Response.ContentLength64 = $buffer.Length
            }

            #endregion
                

        #endregion


        #region Send response and close
        Write-Verbose "Sending response of $Result"

        # Send the response back to the browser
        $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)

        # Close the response to let the browser know we are done sending the response
        $Context.Response.Close()

        # Clear POST and GET variables before read another request
        Clear-Variable -Name "_POST","_GET" -Scope Global -ErrorAction SilentlyContinue
        $global:_SERVER.Remove("REQUEST_METHOD")

        Write-verbose $Context.Response
        
        #endregion
    }

    #endregion

}


#.ExternalHelp en-us\PSWebGui-help.xml
function Format-Html {

    [CmdletBinding(DefaultParameterSetName="Table")]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline,Position=0)][psobject]$InputObject,
        
        [Parameter(ParameterSetName="Table",Mandatory=$false)][Alias("Tabledark","Table-dark")][switch]$Darktable,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][Alias("Theaddark","Thead-dark")][switch]$Darkheader,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][switch]$Striped,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][switch]$Hover,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][string]$Id,

        [Parameter(ParameterSetName="Cards",Mandatory=$true)][ValidateRange(1,6)][int]$Cards,

        [Parameter(ParameterSetName="Raw",Mandatory=$true)][switch]$Raw

    )
    
    # Initializes variable that will contain the output of the pipeline command
    Begin{
        $result=@()
    }

    # Store each command output
    Process{
        $result+=$InputObject
    }


    End{
        
        # If -Raw parameter is set, displays the command output directly
        if ($Raw){
            $result


        #region Process and stylize command output
        <#
        ===================================================================
                          Process and stylize command output
        ===================================================================
        #>
        }else{

            # Get all properties of the object passed
            $objs=$result | Select-Object -Property *

            # Get only property names (headers)
            $headers=($objs | Get-Member -MemberType Property,NoteProperty).Name

            #region Process switch parameters
            <#
            ===================================================================
                                  Process switch parameters
            ===================================================================
            #>
            $tableClass="table"

            if ($Darktable){
                $tableClass+=" table-dark"

            }elseif ($Darkheader){
                $theaddark="class='thead-dark'"
            }

            if ($Striped){
                $tableClass+=" table-striped"
            }

            if ($Hover){
                $tableClass+=" table-hover"
            }

            if ($Id){
                $idTag="id='$id'"
            }
            #endregion



            #region Card layout
            <#
            ===================================================================
                                      Card layout
            ===================================================================
            #>
            if (($cards -ge 1) -and ($Cards -le 6)){
                              
                "<div class='row row-cols-$Cards'>"

                # For each row in CSV displays a bootstrap card
                foreach ($obj in $objs){
                    
                    "<div class='card col'>
		                <div class='card-body'>
			                <h5 class='card-title'>"+$obj.($headers[0])+"</h5>
			                <p class='card-text'>"+$obj.($headers[1])+"</p>
		                </div>
		            </div>"  

                }

                "</div>"
                
            }
            #endregion



            #region Table layout
            <#
            ===================================================================
                                      Table layout
            ===================================================================
            #>
            else{
                "<table class='$tableClass' $idTag>"
                "<thead $theaddark>"
                "<tr>"

                # Get all property names for table headers
                foreach ($header in $headers){
                    "<th>"+$header+"</th>"
                }
                "</tr>"
                "</thead>"

                "<tbody>"

                # For each row in CSV add a table row
                foreach ($obj in $objs){
                    "<tr>"

                    # For each CSV property name gets associated value (within a row)
                    foreach ($header in $headers){
                        "<td>"+$obj.$header+"</td>"
                    }
                    "</tr>"

                }
                "</tbody>"
                "</table>"
            }
            #endregion
        }
        #endregion
    }
}


#.ExternalHelp en-us\PSWebGui-help.xml
function Set-Title {
    
    param (
    [Parameter(Mandatory=$true)][string]$Title
    )

    # Write javascript to inmdiately change page title. Only in web browser
    "<script>document.title='$Title'</script>"

}


#.ExternalHelp en-us\PSWebGui-help.xml
function Set-GuiLocation{

    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [ValidatePattern("^\/(([A-z0-9\-\%]+\/)*[A-z0-9\-\%]+$)?")]
        [Alias("Location","Path")]
        [string]$URL
    )

    '<script>window.location.href="'+$URL+'"</script>'
}



#.ExternalHelp en-us\PSWebGui-help.xml
function Write-CredentialForm {
    
    param(
        [Parameter(Mandatory=$false)][string]$Title="Credential input",
        [Parameter(Mandatory=$false)][string]$Description="Enter your credential",
        [Parameter(Mandatory=$false)][ValidatePattern("^\/(([A-z0-9\-\%]+\/)*[A-z0-9\-\%]+$)?")][string]$Action,
        [Parameter(Mandatory=$false)][string]$UsernameLabel="Enter your username",
        [Parameter(Mandatory=$false)][string]$PasswordLabel="Enter your pasword",
        [Parameter(Mandatory=$false)][string]$SubmitLabel="Submit"
    )

    Set-Title -Title $Title

    "
    <div class='container'>
        <h2 class='mt-3'>$Title</h2>
        <p>$Description</p>

        <form method='post' action=$action>
            <div class='form-group'>
                <label for='usernameInput'>$UsernameLabel</label>
                <input type='text' class='form-control' id='usernameInput' name='userName' autofocus>
            </div>

            <div class='form-group'>
                <label for='passwordInput'>$PasswordLabel</label>
                <input type='password' class='form-control' id='passwordInput' name='Password'>
            </div>

            <button type='submit' class='btn btn-primary'>$SubmitLabel</button>
        </form>
    </div>
    "
}


#.ExternalHelp en-us\PSWebGui-help.xml
function Get-CredentialForm {
    
    # Get username and password from form
    $username=$_POST["userName"]
    $password=ConvertTo-SecureString $_POST["Password"] -AsPlainText -Force

    # Create the credential psobject
    $credential= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password

    return $credential

}


#.ExternalHelp en-us\PSWebGui-help.xml
function Show-PSConsole
{
    $global:console_display=1
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [void][Console.Window]::ShowWindow($consolePtr, 4)
}

#.ExternalHelp en-us\PSWebGui-help.xml
function Hide-PSConsole
{
    $global:console_display=0
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [void][Console.Window]::ShowWindow($consolePtr, 0)
}


#.ExternalHelp en-us\PSWebGui-help.xml
function Show-PSWebGUIExample{

$routes=@{

    "/showProcesses" = {
        Set-Title -Title "Processes"
        "<div class='container-fluid'>
            <a href='/'>Main Menu</a>
            <form action='/filterProcesses'>Filter:<input Name='Name'></input></form>"
            Get-Process | Select-Object cpu,name | Format-Html -Striped -Darkheader -Hover
        "</div>"
    }

    "/filterProcesses" = {
        "<a href='/'>Main Menu</a>
        <form action='/filterProcesses'>Filter:<input Name='Name'></input></form>"
        Get-Process $_GET["Name"] | Select-Object cpu, name | Format-Html
     }

    "/showServices" = {
        "<a href='/'>Main Menu</a>
        <form action='/filterServices' method='post'>Filter:<input Name='Name'></input></form>"
        Get-Service | Select-Object Name,Status | Format-Html -Cards 6
    }

    "/filterServices" = {
        "<a href='/'>Main Menu</a>
        <form action='/filterServices' method='post'>Filter:<input Name='Name'></input></form>"
        Get-Service $_POST["Name"] | Select-Object Status,Name,DisplayName | Format-Html    
    }

    "/showDate" = {"<a href='/'>Main Menu</a><br/>$(Get-Date | Format-Html -Raw)"}


    "/loginform"={
        Write-CredentialForm -FormTitle "Login" -Action "/login"
    }

    "/login"={
        $creds=Get-CredentialForm

        "<a href='/'>Main Menu</a>"
        $creds | Format-Html
    }


    "/" = {
        $title="Index"
        "<div class='container-fluid'>
            <h1>My Simple Task Manager</h1>
            <a href='showProcesses'><h2>Show Running Processes</h2></a>
            <a href='/showServices'><h2>Show Running Services</h2></a>
            <a href='/showDate'><h2>Show current datetime</h2></a>
            <a href='/loginform'><h2>Login</h2></a>
        </div>"
    }


}


Show-PSWebGUI -InputObject $routes -Icon "/panel.png" -Root "$PSScriptRoot\Assets"

return $routes

[System.GC]::Collect()

}


#.ExternalHelp en-us\PSWebGui-help.xml
function Stop-PSWebGui {
    param(
        [Parameter(Mandatory=$false)][switch]$Force,
        [Parameter(Mandatory=$false)][int]$Port=80
    )
    
    $url="http://localhost:$port"
    $uri="$url/stop()"

    if ($Force){
        
        # Check for server properties file
        if (Test-Path -Path "$env:tmp\pswebgui_$port.tmp"){
            
            # Get Powershell server PID from temp file
            $srvpid=(Get-Content -Path "$env:tmp\pswebgui_$port.tmp" | ConvertFrom-Json).PID

            # Request a server stop in background job
            $job=Start-Job -ScriptBlock {Invoke-WebRequest -Uri $args[0]} -ArgumentList $uri | Wait-Job -Timeout 5

            # Close Powershell process
            Stop-Process -Id $srvpid -Force

            # Remove properties file
            Remove-Item "$env:tmp\pswebgui_$port.tmp" -Force -ErrorAction SilentlyContinue
        }
        else{
            Write-Error -Message "Unknown process ID. Server properties file not found" -Category ObjectNotFound -CategoryTargetName "$env:tmp\pswebgui_$port.tmp" -CategoryTargetType "File not found"
            Write-Host "Trying to stop server..."

            # Request a server stop
            $n=Invoke-WebRequest -Uri $uri
        }

        # If job gets stuck, stop it
        if ($job.State -eq "Running"){
            Stop-Job -Job $job
        }



    }
    else{
        # Request a server stop
        $n=Invoke-WebRequest -Uri $uri
    }
}

# Internal function. Do not export
function Show-SystrayMenu{
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
    [void][System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration')

    <#
    ===================================================================
                             ICON PROCESSING
    ===================================================================
    #>

    # If icon was set by parameter, convert to ico file
    if ($iconpath){
        $bitmap = New-Object Drawing.Bitmap $iconpath 
        $bitmap.SetResolution(72, 72); 
        $systray_icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon());
    }
    # If icon was not set by parameter, use powershell icon
    else{
        $systray_icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSHOME\powershell.exe")
    }


    <#
    ===================================================================
                      MENU & ITEMS OBJECTS CREATION
    ===================================================================
    #>

    # Main system tray menu creation
    $Systray_Menu = New-Object System.Windows.Forms.NotifyIcon
    $Systray_Menu.Text = $title
    $Systray_Menu.Icon = $systray_icon
    $Systray_Menu.Visible = $true

    # Menu item to show the GUI creation
    $Menu_ShowGUI = New-Object System.Windows.Forms.MenuItem
    $Menu_ShowGUI.Text = "Show GUI"

    # Menu item to show the Powershell console creation
    $Menu_ShowConsole = New-Object System.Windows.Forms.MenuItem
    $Menu_ShowConsole.Text = "Show PS console"

    # Menu item to hide the Powershell console creation
    $Menu_HideConsole = New-Object System.Windows.Forms.MenuItem
    $Menu_HideConsole.Visible = $false
    $Menu_HideConsole.Text = "Hide PS console"

    # Menu item to exit creation
    $Menu_Exit = New-Object System.Windows.Forms.MenuItem
    $Menu_Exit.Text = "Exit"

    # Context menu creation and menu items adition
    $contextmenu = New-Object System.Windows.Forms.ContextMenu
    $Systray_Menu.ContextMenu = $contextmenu
    $Systray_Menu.contextMenu.MenuItems.AddRange($Menu_ShowGUI)
    $Systray_Menu.contextMenu.MenuItems.AddRange($Menu_ShowConsole)
    $Systray_Menu.contextMenu.MenuItems.AddRange($Menu_HideConsole)
    $Systray_Menu.contextMenu.MenuItems.AddRange($Menu_Exit)


    <#
    ===================================================================
                          ACTIONS FOR THE MENU ITEMS
    ===================================================================
    #>

    # Systray double click opens GUI
    $Systray_Menu.Add_DoubleClick({
        $Form.ShowDialog()
        $Form.Activate()
    })
 
    # Show GUI action
    $Menu_ShowGUI.add_Click({
        $Menu_ShowGUI.Visible=$false
        $Form.ShowDialog()
        $Form.Activate()
    })

    # Show PS console action
    $Menu_ShowConsole.add_Click({
        Show-PSConsole
        $Menu_ShowConsole.Visible=$false
        $Menu_HideConsole.Visible=$true
    })

    # Hide PS console action
    $Menu_HideConsole.add_Click({
        Hide-PSConsole
        $Menu_ShowConsole.Visible=$true
        $Menu_HideConsole.Visible=$false
    })

    # Exit action
    $Menu_Exit.add_Click({
        Invoke-WebRequest -Uri "http://localhost/exit()" | Out-Null
        Stop-Process $pid
    })

    # Hide GUI instead of closing it when close button (X) clicked
    $Form.Add_Closing({
        $_.Cancel = $true
        $Menu_ShowGUI.Visible=$true
        $Form.Hide()
    })

    <#
    ===================================================================
                          RUN THE APPLICATION
    ===================================================================
    #>

    # Hide PS console
    Hide-PSConsole

    # GC
    [System.GC]::Collect()

    # Run the windows form application
    $appContext = New-Object System.Windows.Forms.ApplicationContext
    [void][System.Windows.Forms.Application]::Run($appContext)
}

#region Function alias
Set-Alias -Name Start-PSGUI -Value Show-PSWebGUI
Set-Alias -Name Show-PSGUI -Value Show-PSWebGUI
Set-Alias -Name Show-WebGUI -Value Show-PSWebGUI
Set-Alias -Name Start-WebGUI -Value Show-PSWebGUI
Set-Alias -Name FH -Value Format-Html
Set-Alias -Name SGL -Value Set-GuiLocation
#endregion


Export-ModuleMember -Function * -Alias *
