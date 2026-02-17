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