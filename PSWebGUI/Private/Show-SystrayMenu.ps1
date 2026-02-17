# Internal function. Do not export
function Show-SystrayMenu{
    Add-Type -AssemblyName System.Windows.Forms
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
    [void][System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration')
    [Windows.Forms.Application]::EnableVisualStyles()

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
    # Windows Poweshell 5.1 icon
    elseif (Test-Path -Path "$PSHOME\powershell.exe"){
        $systray_icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSHOME\powershell.exe")
    }
    # Poweshell 7
    elseif (Test-Path -Path "$PSHOME\pwsh.exe"){
        $systray_icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSHOME\pwsh.exe")
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
    $Menu_ShowGUI = New-Object System.Windows.Forms.ToolStripMenuItem
    $Menu_ShowGUI.Text = "Show $title"
    $Menu_ShowGUI.Visible = $false

    # Menu item to show the Powershell console creation
    $Menu_ShowConsole = New-Object System.Windows.Forms.ToolStripMenuItem
    $Menu_ShowConsole.Text = "Show PS console"

    # Menu item to hide the Powershell console creation
    $Menu_HideConsole = New-Object System.Windows.Forms.ToolStripMenuItem
    $Menu_HideConsole.Visible = $false
    $Menu_HideConsole.Text = "Hide PS console"

    # Menu item to exit creation
    $Menu_Exit = New-Object System.Windows.Forms.ToolStripMenuItem
    $Menu_Exit.Text = "Exit"
    $Menu_Exit.Image = [System.Drawing.SystemIcons]::Error

    $Menu_Divider = New-Object System.Windows.Forms.ToolStripSeparator

    # Context menu creation and menu items adition
    $contextmenu = New-Object System.Windows.Forms.ContextMenuStrip
    $contextmenu.Items.Add($Menu_ShowGUI)
    $contextmenu.Items.Add($Menu_ShowConsole)
    $contextmenu.Items.Add($Menu_HideConsole)
    $contextmenu.Items.Add($Menu_Divider)
    $contextmenu.Items.Add($Menu_Exit)

    $Systray_Menu.ContextMenuStrip=$contextmenu

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
        Invoke-WebRequest -Uri "http://localhost:$port/exit()" | Out-Null
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

    # Show GUI
    $Form.ShowDialog()

    # GC
    [System.GC]::Collect()

    # Run the windows form application
    $appContext = New-Object System.Windows.Forms.ApplicationContext
    [void][System.Windows.Forms.Application]::Run($appContext)
}