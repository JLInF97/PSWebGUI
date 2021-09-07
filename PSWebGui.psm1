#.ExternalHelp en-us\PSWebGui-help.xml
Function Show-PSWebGUI
{

    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$false,Position=0,ValueFromPipeline=$true)][Alias("Routes","Input")]$InputObject="",
    [Parameter(Mandatory=$false)][int]$Port=80,
    [Parameter(Mandatory=$false)][string]$Title="PoweShell Web GUI",
    [Parameter(Mandatory=$false)][string]$Icon,
    [Parameter(Mandatory=$false)][string]$CssUri,
    [Parameter(Mandatory=$false)][Alias("Root")][string]$DocumentRoot=$PWD.path,
    [Parameter(Mandatory=$false)][Alias("WebGui","Silent","Hidden")][switch]$NoWindow,
    [Parameter(Mandatory=$false)][switch]$NoHeadTags

    )


    # URL + PORT to use
    $url="http://localhost:$port/"

    # Create virtual drive in root directory
    $fileserver=New-PSDrive -Name FileServer -PSProvider FileSystem -Root $DocumentRoot



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
        
        # If icon path exists as absolute path (absolute path passed)
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



    #region Graphic interface
    <#
    ===================================================================
                          GRAPHIC INTERFACE (GUI)
    ===================================================================
    #>

    # If -NoWindow, dont create an internal WebBrowser
    if ($NoWindow -eq $false){

        # Create a scriptblock that waits for the server to launch and then opens a web browser control
        $UserWindow = {
            
            param ($url,$title,$iconpath)

                # Wait-ServerLaunch will continually repeatedly attempt to get a response from the URL before continuing
                function Wait-ServerLaunch
                {

                    try {
                        $Test = New-Object System.Net.WebClient
                        $Test.DownloadString($url);
                    }
                    catch
                    { start-sleep -Milliseconds 500; Wait-ServerLaunch }
 
                }

                Wait-ServerLaunch

                # XAML
                [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
                [xml]$XAML = @'
                <Window
                    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
                    Title="PoweShell Web GUI" WindowStartupLocation="CenterScreen">

                        <WebBrowser Name="WebBrowser"></WebBrowser>

                </Window>
'@

                #Read XAML
                $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
                $Form=[Windows.Markup.XamlReader]::Load( $reader )

                # Set title and icon
                $Form.Title=$title               
                $Form.Icon=$iconpath


                # WebBrowser navigate to localhost
                $WebBrowser = $Form.FindName("WebBrowser")
                $WebBrowser.Navigate($url)

                # Show GUI
                $Form.ShowDialog()
                Start-Sleep -Seconds 1

                # Once the end user closes out of the browser we send the exit url to tell the server to shut down.
                $exiturl=$url+"exit"
                (New-Object System.Net.WebClient).DownloadString($exiturl);
        }
 
        
        # Create runspace for GUI
        $RunspacePool = [RunspaceFactory]::CreateRunspacePool()
        $RunspacePool.ApartmentState = "STA"
        $RunspacePool.Open()
        $Jobs = @()
 
        # Create job and add to runspace
        $Job = [powershell]::Create().AddScript($UserWindow).AddArgument($url).AddArgument($title).AddArgument($iconpath)#.AddArgument($_)
        $Job.RunspacePool = $RunspacePool
        $Jobs += New-Object PSObject -Property @{
            RunNum = $_
            Pipe = $Job
            Result = $Job.BeginInvoke()
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
    $bootstrap=Get-Content "$PSScriptRoot\Assets\bootstrap.min.css"

    #Load CSS
    if ($CssUri -ne ""){
        $css=Get-Content $CssUri
    }

    Write-Host "GUI started" -ForegroundColor Green

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

            }while($Context.Request.Url.LocalPath -eq "/favicon.ico")
        }


        # Creating a friendly way to shutdown the server
        if($Context.Request.Url.LocalPath -eq "/exit")
        {

            $Context.Response.Close()
            $SimpleServer.Stop()

            # If -NoWindow, dont close a non-existent Window
            if ($NoWindow -eq $false){
                $RunspacePool.Close()
            }

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

            # Defining some meta tags
            $charset='<meta charset="utf-8">'
            $httpequiv='<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">'
            $style="<style>"+$bootstrap+$css+"</style>"
            $viewport='<meta name="viewport" content="width=device-width, initial-scale=1">'
            $faviconlink="<link rel='shortcut icon' href='$favicon'>"

            # Make html head template
            $htmlhead="<!Doctype html>`n<html>`n<head>`n$charset`n$httpequiv`n$viewport`n$faviconlink`n<title>$title</title>`n$style`n</head>`n<body>`n"

            # Closing tags
            $htmlclosing="`n</body>`n</html>"
        }
        #endregion
            
            #region Method processing

            # POST processing
            if ($Context.Request.HasEntityBody){
                    
                $request = $Context.Request
                $length = $request.contentlength64
                $buffer = new-object "byte[]" $length

                [void]$request.inputstream.read($buffer, 0, $length)
                $body = [system.text.encoding]::ascii.getstring($buffer)
                    
                # Split post data
                $global:_POST = @{}
                $body.split('&') | ForEach-Object {
                    $part = $_.split('=')
                    $global:_POST.add($part[0], $part[1])
                }


            # GET processing
            }else{

                $global:_GET = $Context.Request.QueryString
            }

            #endregion

                
            #region URL content processing

            # $localpath is the relative URL (/home, /user/support)
            $localpath=$Context.Request.Url.LocalPath


            # If $localpath is not a custom defined path in $InputObject, means it can be a filesystem path or a string
            if ($InputObject[$LocalPath] -eq $null){
                    
                # $localpath is a file
                if (Test-Path "FileServer:$localpath" -PathType Leaf){
                        
                    # Add type for [System.Web.MimeMapping] method
                    Add-Type -AssemblyName "System.Web"

                    # Convert the file content to bytes from path
                    $buffer = Get-Content -Encoding Byte -Path "FileServer:$localpath" -ReadCount 0

                    # Let the browser know the MIME type of content
                    $Context.Response.ContentType = [System.Web.MimeMapping]::GetMimeMapping($localpath)

                    
                # $InputObject is a string and $localpath is in /
                }elseif (($InputObject -is [string]) -and ($localpath -eq '/')){
                        
                    Write-Verbose "A [string] object was returned."
                    $result="$htmlhead $InputObject $htmlclosing"

                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($result)
                    $context.Response.ContentLength64 = $buffer.Length
                }
                    
                # $localpath is neither a file nor a defined route but is representing a path that its not found
                else{
                    $result="<html>`n<head>`n<title>404 Not found</title>`n<body>`n<h1>404 Not found</h1>`n</body>`n</html>"
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

                # If $title is present in the scriptblock, write javascript to inmdiately change it. Only in web browser
                if ($title -ne $originaltitle){
                    $result+="<script>document.title='$title'</script>"
                }

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
            
            # Convert command output object to CSV
            $csv=$result | ConvertTo-Csv -NoTypeInformation

            # Get CSV object
            $csvobj=$csv | ConvertFrom-Csv

            # Get only property names (headers)
            $headers=$csv[0].Replace('"','').Split(",")



            #region Process switch parameters
            <#
            ===================================================================
                                  Process switch parameters
            ===================================================================
            #>
            if ($Darktable){
                $tabledark="table-dark"

            }elseif ($Darkheader){
                $theaddark="class='thead-dark'"
            }

            if ($Striped){
                $tablestriped="table-striped"
            }

            if ($Hover){
                $tablehover="table-hover"
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
                foreach ($obj in $csvobj){
                    
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
                "<table class='table $tabledark $tablestriped $tablehover'>"
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
                foreach ($obj in $csvobj){
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
function GoTo-Location{

    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [ValidatePattern("^\/(([A-z0-9\-\%]+\/)*[A-z0-9\-\%]+$)?")]
        [Alias("URL","Path")]
        [string]$Location
    )

    '<script>window.location.href="'+$Location+'"</script>'
}



#.ExternalHelp en-us\PSWebGui-help.xml
function Write-CredentialForm {
    
    param(
        [Parameter(Mandatory=$false)][string]$FormTitle="Credential input",
        [Parameter(Mandatory=$false)][string]$Description="Enter your credential",
        [Parameter(Mandatory=$false)][ValidatePattern("^\/(([A-z0-9\-\%]+\/)*[A-z0-9\-\%]+$)?")][string]$Action,
        [Parameter(Mandatory=$false)][string]$UsernameLabel="Enter your username",
        [Parameter(Mandatory=$false)][string]$PasswordLabel="Enter your pasword",
        [Parameter(Mandatory=$false)][string]$SubmitLabel="Submit"
    )

    "
    <div class='container'>
        <h2 class='mt-3'>$FormTitle</h2>
        <p>$Description</p>

        <form method='post' action=$action>
            <div class='form-group'>
                <label for='usernameInput'>$UsernameLabel</label>
                <input type='text' class='from-control' id='usernameInput' name='userName' autofocus>
            </div>

            <div class='form-group'>
                <label for='passwordInput'>$PasswordLabel</label>
                <input type='password' class='from-control' id='passwordInput' name='Password'>
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
function Show-PSWebGUIExample{

$routes=@{

    "/showProcesses" = {
        $title="Processes"
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

    "/" = {
        $title="Index"
        "<div class='container-fluid'>
            <h1>My Simple Task Manager</h1>
            <a href='showProcesses'><h2>Show Running Processes</h2></a>
            <a href='/showServices'><h2>Show Running Services</h2></a>
            <a href='/showDate'><h2>Show current datetime</h2></a>
        </div>"
    }


}


Show-PSWebGUI -InputObject $routes -Icon "/panel.png" -Root "$PSScriptRoot\Assets"

return $routes

[System.GC]::Collect()

}


#region Function alias
Set-Alias -Name Start-PSGUI -Value Show-PSWebGUI
Set-Alias -Name Show-PSGUI -Value Show-PSWebGUI
Set-Alias -Name Start-GUI -Value Show-PSWebGUI
Set-Alias -Name Show-GUI -Value Show-PSWebGUI
Set-Alias -Name Show-WebGUI -Value Show-PSWebGUI
Set-Alias -Name Start-WebGUI -Value Show-PSWebGUI
Set-Alias -Name FH -Value Format-Html
Set-Alias -Name GTL -Value GoTo-Location
#endregion


Export-ModuleMember -Function * -Alias *
