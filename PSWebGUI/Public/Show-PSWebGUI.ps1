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
    $bootstrapContent=Get-Content "$PSScriptRoot\..\Assets\bootstrap.min.css"

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
            $htmlhead=(Get-Content -Path "$PSScriptRoot\..\Assets\htmlHeadTemplate.html" -Encoding UTF8).Replace("@@favicon",$favicon).Replace("@@style",$bootstrapContent).Replace("@@title",$title)

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