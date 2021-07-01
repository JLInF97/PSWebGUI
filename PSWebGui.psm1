Function Show-PSWebGUI
{
    <#
        .SYNOPSIS
        Displays a styled graphical user interface (GUI) for PowerShell from passed HTML format.

        .DESCRIPTION
        Starts a simple web server, listening on localhost, to display content in HTML format with integrated Bootstrap style.
        By default, it shows up a very simple web browser in a WPF window to display the content passed by parameter.

        The content can be a string, an HTML page, cmdlets, functions or complex powershell scripts.
        The server can execute and display local HTML or PS1 files. Custom CSS and Javascript are also compatible.

        POST and GET method are available and can be accesses by $_POST and $_GET variables, just like within PHP.

        .PARAMETER InputObject
        Specifies the object to display in the GUI.
        
        The way to define custom routes with associated HTML and PowerShell content is through a hash table and scriptblocks whitin it.
        The hash table is made up of keys and their associated values. Keys are custom defined localhost relative paths, and must always start with "/"; values are strings, HTML and PowerShell scripts enclosed within a scriptblock.

        This is an example of a GUI structure passed as an input object:
        
        $routes=@{

            "/"={
                "<div>
                    <h1>Menú</h1>
                    <a href='showProcesses'><h2>Show Running Processes</h2></a>
                    <a href='/showServices'><h2>Show Running Services</h2></a>
                </div>"
            }

            "/showProcesses" = { Get-Process | Select-Object name, cpu | Format-Html }

            "/showServices" = {
                <div>
                    <h1>Services</h1>
                    Get-Service | Format-Html
                </div>
            }

        }


        .PARAMETER Port
        Specifies TCP port number to listen to.
        Default 80.

        .PARAMETER Title
        Specifies the window title and the HTML page title.

        Reassign $title variable within script blocks (custom routes) to change the page title on each path.

        .PARAMETER Icon
        Specifies the path for the icon used on the window and on the HTML page.
        This path can be absolute or relative to the document root. If the path is not within the document root, it will only be displayed on window.

        .PARAMETER CssUri
        Specifies the CSS URI to use in addition to bootstrap. It can be a local file or an Internet URL.
        It can not be relative path, must be absolute.

        .PARAMETER NoWindow
        Set this parameter to not display a web browser in a WPF window. The content can only be viewed within a third-party web browser.

        .PARAMETER DocumentRoot
        Specifies the root path for the files that the server will access. Do not put final slash.
        Default $PWD

        .INPUTS
        System.String
        System.Object  

        .OUTPUTS
        System.String
        Debug and Verbose modes write request and response information to the console.

        .EXAMPLE
        PS> Show-PSWebGUI -InputObject "Hello Wordl!"

        .EXAMPLE
        PS> Show-PSWebGUI -InputObject $routes -Title "My custom GUI"

        .EXAMPLE
        PS> Show-PSWebGUI -InputObject $routes -Title "My custom GUI" -Port 8080 -CssUri "C:\myresources\style.css" -Icon "C:\myresources\style.css"

        .EXAMPLE
        PS> Show-PSWebGUI -InputObject $routes -CssUri "C:\myresources\style.css" -DocumentRoot "C:\myresources" -Icon "/style.css"

        .LINK


    #>

    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)][Alias("Routes","Input")]$InputObject,
    [Parameter(Mandatory=$false)][int]$Port=80,
    [Parameter(Mandatory=$false)][string]$Title="PoweShell Web GUI",
    [Parameter(Mandatory=$false)][string]$Icon,
    [Parameter(Mandatory=$false)][string]$CssUri,
    [Parameter(Mandatory=$false)][Alias("WebGui","Silent","Hidden")][switch]$NoWindow,
    [Parameter(Mandatory=$false)][Alias("Root")][string]$DocumentRoot=$PWD.path

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
            #$SimpleServer.Close()
            $SimpleServer.Stop()
            break

        }

    

        #region Handly URLs
        <#
        ===================================================================
                                HANDLY URLS
        ===================================================================
        #>

        # Ensure $InputObject is not null
        if($null -ne $InputObject) {

            # Defining some meta tags
            $charset='<meta charset="utf-8">'
            $httpequiv='<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">'
            $style="<style>"+$bootstrap+$css+"</style>"
            $viewport='<meta name="viewport" content="width=device-width, initial-scale=1">'
            $faviconlink="<link rel='shortcut icon' href='$favicon'>"

            # Make html head template
            $htmlhead="<!Doctype html>`n<html>`n<head>`n$charset`n$httpequiv`n$viewport`n$faviconlink`n<title>$title</title>`n$style`n</head>`n<body>`n"

            
            # If $inputobject is just a string
            if($InputObject -is [string]){
                
                Write-Verbose "A [string] object was returned."
                $result="$htmlhead $InputObject`n</body>`n</html>"

                # Convert the result to bytes from UTF8 encoded text
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($Result)

                # Let the browser know how many bytes we are going to be sending
                $context.Response.ContentLength64 = $buffer.Length


            # If $InputObject is a full object with routes
            } else {
                
                #region Method processing

                # POST processing
                if ($Context.Request.HasEntityBody){
                    
                    $request = $Context.Request
                    $length = $request.contentlength64
                    $buffer = new-object "byte[]" $length

                    [void]$request.inputstream.read($buffer, 0, $length)
                    $body = [system.text.encoding]::ascii.getstring($buffer)
                    
                    # Split post data
                    $_POST = @{}
                    $body.split('&') | ForEach-Object {
                        $part = $_.split('=')
                        $_POST.add($part[0], $part[1])
                    }


                # GET processing
                }else{

                    $_GET = $Context.Request.QueryString
                }

                #endregion

                
                #region URL content processing

                # $localpath is the relative URL (/home, /user/support)
                $localpath=$Context.Request.Url.LocalPath


                # If $localpath is not defined in $InputObject, means its a filesystem path
                if ($InputObject[$LocalPath] -eq $null){
                    
                    # $localpath is a file
                    if (Test-Path "FileServer:$localpath" -PathType Leaf){
                        
                        # Add type for [System.Web.MimeMapping] method
                        Add-Type -AssemblyName "System.Web"

                        # Convert the file content to bytes from path
                        $buffer = Get-Content -Encoding Byte -Path "FileServer:$localpath" -ReadCount 0

                        # Let the browser know the MIME type of content
                        $Context.Response.ContentType = [System.Web.MimeMapping]::GetMimeMapping($localpath)


                    
                    # $localpath is neither a file nor a defined route, its not found
                    }else{
                        $result="$htmlhead <h1>404 Not found</h1></body></html>"
                        $Context.Response.StatusCode=404
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
                    $result+="`n</body>`n</html>"

                    # Convert the result to bytes from UTF8 encoded text
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($Result)

                    # Let the browser know how many bytes we are going to be sending
                    $context.Response.ContentLength64 = $buffer.Length
                }

                #endregion
                
            }
        }

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


#region Function alias
Set-Alias -Name Start-PSGUI -Value Show-PSWebGUI
Set-Alias -Name Show-PSGUI -Value Show-PSWebGUI
Set-Alias -Name Start-GUI -Value Show-PSWebGUI
Set-Alias -Name Show-GUI -Value Show-PSWebGUI
Set-Alias -Name Show-POSHGUI -Value Show-PSWebGUI
Set-Alias -Name Start-POSHGUI -Value Show-PSWebGUI
Set-Alias -Name Show-WebGUI -Value Show-PSWebGUI
Set-Alias -Name Start-WebGUI -Value Show-PSWebGUI
#endregion




function Format-Html {

<#
    .SYNOPSIS
    Format and style PowerShell commands in HTML and Bootstrap.

    .DESCRIPTION
    Converts the output of PowerShell commands, passed by pipeline, to HTML format and adds Bootstrap style classes.

    Depending on the set of parameters, the output can be converted to table format, card format, or raw. If no parameters are set, by default it is converted to table format.
        
    In essence, it is like "Format-Html -Fragment" PowerShell cmdlet but with Bootstrap styling built-in and another features.


    .PARAMETER InputObject
    Command or object to be converted, passed by pipeline.

    .PARAMETER Darktable
    Set this parameter to display a dark table.

    <table class="table table-dark">...</table>


    .PARAMETER Darkheader
    Set this parameter to display a table with dark header.

    <table class="table">
        <thead class="thead-dark">...</thead>
    </table>


    .PARAMETER Striped
    Set this parameter to display a striped table.

    <table class="table table-striped">...</table>


    .PARAMETER Hover
    Set this parameter to display a hoverable rows table.

    <table class="table table-hover">...</table>


    .PARAMETER Cards
    Specifies a number, between 1 and 6, to display the command output in Bootstrap card style. The number specified is the number of cards displayed per row.

    This parameter only displays the first two properties of the object passed. The first one will be dipslayed as the card title, the second will be th card text.
    (See the cards section of the Bootstrap v4.6 documentation for more info about card layout)

    .PARAMETER Raw
    Set this parameter to display output in HTML format but without style.

    .INPUTS
    System.String
    System.Object  

    .OUTPUTS
    System.String

    .EXAMPLE
    PS> Get-Service | Format-Html

    .EXAMPLE
    PS> Get-Process | Select-Object Cpu, Name | Format-Html -Darkheader -Striped -Hover

    .EXAMPLE
    PS> Get-Service | Select-Object Status, DisplayName | Format-Html -Cards 3

    .EXAMPLE
    PS> Get-Date | Format-Html -Raw

    .LINK


#>

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



function Show-PSWebGUIExample{

<#
    .SYNOPSIS
    Display an example GUI.

    .DESCRIPTION
    Displays a basic example GUI to show how this module runs.

    .INPUTS
    None  

    .OUTPUTS
    System.String

    .EXAMPLE
    PS> Show-PSWebGUIExample

    .LINK


#>

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

    "/showDate" = {"<a href='/'>Main Menu</a><tr/>$(Get-Date | Format-Html -Raw)"}

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


Export-ModuleMember -Function * -Alias *