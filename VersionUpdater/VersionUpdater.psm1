function Update-Version {
    param(
        [string]$ProjectFile,
        [string]$JsonFilePath
    )

    # Load and parse the JSON file
    $jsonContent = Get-Content $JsonFilePath -Raw | ConvertFrom-Json
    $version = $jsonContent.version
    $versionString = "$($version.major).$($version.minor).$($version.patch)"

    # Read the content of the project file
    $projectContent = Get-Content $ProjectFile -Raw

    # Regex to find and replace the <Version> tag
    $regex = "<Version>.*?</Version>"
    $replacement = "<Version>$versionString</Version>"
    $newProjectContent = [regex]::Replace($projectContent, $regex, $replacement)

    # Trim trailing whitespace and newline characters
    $newProjectContent = $newProjectContent.TrimEnd()

    # Save the changes back to the project file
    Set-Content -Path $ProjectFile -Value $newProjectContent

    Write-Host "Project file '$ProjectFile' has been updated to version $versionString."
}

Export-ModuleMember -Function Update-Version