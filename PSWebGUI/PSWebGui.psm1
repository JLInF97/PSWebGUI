# Load assembly to show/hide the powershell console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

$global:console_display=1

#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private)){
    Try{
        . $import.fullname
    }
    Catch{
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}


#region Function alias
Set-Alias -Name Start-PSGUI -Value Show-PSWebGUI
Set-Alias -Name Show-PSGUI -Value Show-PSWebGUI
Set-Alias -Name Show-WebGUI -Value Show-PSWebGUI
Set-Alias -Name Start-WebGUI -Value Show-PSWebGUI
Set-Alias -Name FH -Value Format-Html
Set-Alias -Name SGL -Value Set-GuiLocation
#endregion