function Save-EnvVariables {
    param (
        [string]$FilePath
    )

    # Get all environment variables
    $envVars = Get-ChildItem env: | ForEach-Object {
        @{ Name = $_.Name; Value = $_.Value }
    }

    # Convert to JSON and save to file
    $envVars | ConvertTo-Json -Depth 5 | Set-Content -Path $FilePath
    Write-Host "Environment variables have been saved to $(Resolve-Path $FilePath)"
}

function Restore-EnvVariables {
    param (
        [string]$FilePath
    )

    # Check if the file exists
    if (Test-Path $FilePath) {
        $FilePath = Resolve-Path $FilePath

        # Read from file and convert from JSON
        $envVars = Get-Content -Path $FilePath | ConvertFrom-Json

        # Set each environment variable
        foreach ($var in $envVars) {
            [Environment]::SetEnvironmentVariable($var.Name, $var.Value, [EnvironmentVariableTarget]::Process)
        }

        Write-Host "Environment variables have been restored from $FilePath"
    }
    else {
        Write-Error "File $FilePath does not exist."
    }
}

Export-ModuleMember -Function Save-EnvVariables, Restore-EnvVariables