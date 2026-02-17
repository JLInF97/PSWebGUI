function Show-PSConsole
{
    $global:console_display=1
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [void][Console.Window]::ShowWindow($consolePtr, 4)
}