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

function Set-AndroidEnvironment {
    param (
        [string]$AndroidSdkPath
    )

    # Set environment variables for Android SDK
    $env:ANDROID_SDK_ROOT = "$AndroidSdkPath/libexec/android-sdk"
    $env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
    Write-Host "ANDROID_SDK_ROOT set to $($env:ANDROID_SDK_ROOT)"

    # Add android emulator to PATH
    $env:PATH = "$($env:ANDROID_SDK_ROOT)/emulator:$($env:PATH)"

    # Check if running under WSL and set ADB server address
    $wslDistroName = $env:WSL_DISTRO_NAME
    if (-not [string]::IsNullOrEmpty($wslDistroName)) {
        $resolvConfLine = Get-Content /etc/resolv.conf | Select-Object -Last 1
        $adbServerAddress = $resolvConfLine.Split(' ')[1]
        $env:ANDROID_ADB_SERVER_ADDRESS = $adbServerAddress
        Write-Host "Running under WSL, ANDROID_ADB_SERVER_ADDRESS set to $adbServerAddress"
    }
}

function Initialize-Fastlane {
    param (
        [string] $FastlaneAppIdentifier,
        [string] $FastlaneAppName
    )

    # Set environment variables - App information
    $env:FASTLANE_APP_IDENTIFIER = $FastlaneAppIdentifier
    $env:FASTLANE_APP_NAME = $FastlaneAppName

    # Check the operating system and set additional variables if on macOS
    if ([Environment]::OSVersion.Platform -eq [System.PlatformID]::Unix) {
        # Additional check to confirm it's actually macOS since PlatformID.Unix can mean macOS or Linux
        if (Test-Path "/System/Library/CoreServices/SystemVersion.plist") {
            $env:FASTLANE_APPLE_ID = $env:FASTLANE_USER
        }
    }

    Write-Host "Fastlane configuration applied."
    Write-Host "FASTLANE_APP_IDENTIFIER: $($env:FASTLANE_APP_IDENTIFIER)"
    if ($env:FASTLANE_APPLE_ID) {
        Write-Host "FASTLANE_APPLE_ID: $($env:FASTLANE_APPLE_ID)"
    }
}

Export-ModuleMember -Function Save-EnvVariables, Restore-EnvVariables, Set-AndroidEnvironment, Initialize-Fastlane