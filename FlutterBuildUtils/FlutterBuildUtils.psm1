# Ensure script exits if any command fails
$ErrorActionPreference = "Stop"

function Set-Mode {
    param (
        [ValidateSet($null, $true, $false)]
        [object] $Debug = $null
    )

    if ($Debug -eq $true) {
        $env:FASTLANE_DEBUG = "true"
    }
    elseif ($Debug -eq $false) {
        $env:FASTLANE_DEBUG = "false"
    }

    if (-not $env:FASTLANE_DEBUG) {
        Write-Host "DEBUG_FASTLANE environment variable is not set. Please pass the -Debug flag to the function or set the environment variable."
        return
    }

    $mode = $env:FASTLANE_DEBUG -eq "true" ? "debug" : "release"

    return $mode
}

function Rename-FlutterApp {
    param (
        [string]$IOS = $false
    )

    $identifierArray = $env:FASTLANE_APP_IDENTIFIER.Split(".")
    $newName = $identifierArray[$identifierArray.Length - 1]

    # Rename in pubspec.yaml regex (^name: .*)
    $pubspecFile = Resolve-Path -Path "./pubspec.yaml"
    $content = Get-Content -Path $pubspecFile
    $content = $content -replace "^name: .*", "name: $newName"
    Set-Content -Path $pubspecFile -Value $content

    if ($IOS -eq $true) {
        return
    }

    # Rename in AndroidManifest.xml regex (android:label=".*")
    $androidManifestFile = Resolve-Path -Path "./android/app/src/main/AndroidManifest.xml"
    $content = Get-Content -Path $androidManifestFile
    $content = $content -replace 'android:label=".*"', "android:label=`"$newName`""
    Set-Content -Path $androidManifestFile -Value $content
}

function Initialize-IOSProjectSetup {
    param (
        [ValidateSet($null, $true, $false)]
        [object] $Debug = $null
    )

    Write-Host "Setting up iOS project"

    Rename-FlutterApp -IOS $true

    $mode = Set-Mode -Debug $Debug
    Write-Host "Fetching certificates and provisioning profiles in $mode mode"

    # Change directory to ios - to run fastlane commands
    $initialDirectory = Get-Location
    Set-Location -Path "ios"
    
    # Create certificates, provisioning profiles if they don't exist - else fetch them
    & fastlane ios create_certificate
    & fastlane ios create_provisioning_profile
    # Edit the Xcode project file to use the correct provisioning profile and certificate
    & fastlane ios setup_project

    Set-Location -Path $initialDirectory
}

function Rename-MainActivity {
    $srcDir = (Resolve-Path -Path "android/app/src/main/kotlin").ToString()
    $mainActivityFile = (Get-ChildItem -Path $srcDir -Recurse -Filter "MainActivity.kt").FullName

    $identifierArray = $env:FASTLANE_APP_IDENTIFIER.Split(".")

    # Get the directory where the old package name differs from the new name (to be removed after copying MainActivity.kt to the new directory)
    $oldDir = $mainActivityFile.Substring($srcDir.Length).Split("/") | Select-Object -SkipLast 1 -Skip 1 | Where-Object { $_ -notin $identifierArray } | Select-Object -First 1
    
    if (-not $oldDir) {
        Write-Host "The package name is already the same as the app name"
        return
    }
    
    # Get the path of the old directory
    $oldDirPath = $mainActivityFile.Substring(0, $mainActivityFile.IndexOf($oldDir) + $oldDir.Length)

    # Create new directory structure
    foreach ($dir in $identifierArray) {
        $srcDir = (Join-Path -Path $srcDir -ChildPath $dir)
        if (-not (Test-Path $srcDir)) {
            New-Item -ItemType Directory -Path $srcDir | Out-Null
        }
    }

    # Copy MainActivity.kt to the new directory
    $newMainActivityFile = (Join-Path -Path $srcDir -ChildPath "MainActivity.kt")
    Copy-Item -Path $mainActivityFile -Destination $newMainActivityFile

    # Rename the package name in the new MainActivity.kt file
    $content = Get-Content -Path $newMainActivityFile
    $content = $content -replace "^package .*", "package $env:FASTLANE_APP_IDENTIFIER"
    Set-Content -Path $newMainActivityFile -Value $content

    Remove-Item -Path $oldDirPath -Recurse

    return $appName
}

function Initialize-AndroidProjectSetup {
    Write-Host "Fetching keystore file and setting up Android project"

    Rename-MainActivity
    Rename-FlutterApp

    $fastlaneAppIdentifier = $env:FASTLANE_APP_IDENTIFIER

    # Check if ../../flutter_secrets exists
    if (-not (Test-Path "../flutter_secrets")) {
        Write-Host "The flutter_secrets directory does not exist. Please clone the secrets repository."
        return
    }

    # Check if the keystore file exists
    $keystoreFile = (Resolve-Path -Path "../flutter_secrets") | Join-Path -ChildPath "$fastlaneAppIdentifier.keystore"
    if (-not (Test-Path $keystoreFile)) {
        # Generate the keystore file
        $keystorePassword = $env:KEYSTORE_PASSWORD
        
        $command = "& keytool -genkey -v -keystore $keystoreFile -alias $fastlaneAppIdentifier -keyalg RSA -keysize 2048 -validity 36500 -storepass $keystorePassword -keypass $keystorePassword -dname `"CN=$fastlaneAppIdentifier, O=$($env:ORGANIZATION_NAME), C=CH`""
        Invoke-Expression -Command $command

        Write-Host "Keystore file generated at $keystoreFile - You need to commit the flutter_secrets repository."
    }
    else {
        Write-Host "Keystore file already exists at $keystoreFile"
    }
}

Export-ModuleMember -Function Initialize-IOSProjectSetup, Initialize-AndroidProjectSetup