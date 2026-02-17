function Hide-PSConsole
{
    $global:console_display=0
    $consolePtr = [Console.Window]::GetConsoleWindow()
    [void][Console.Window]::ShowWindow($consolePtr, 0)
}