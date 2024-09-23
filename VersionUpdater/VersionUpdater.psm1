function Update-CsprojVersion {
    param(
        [string]$ProjectFile,
        [string]$VersionString,
    )

    # Read the content of the project file
    $projectContent = Get-Content $ProjectFile -Raw

    # Regex to find and replace the <Version> tag
    $regex = "<Version>.*?</Version>"
    $replacement = "<Version>$VersionString</Version>"
    $newProjectContent = [regex]::Replace($projectContent, $regex, $replacement)

    # Trim trailing whitespace and newline characters
    $newProjectContent = $newProjectContent.TrimEnd()

    # Save the changes back to the project file
    Set-Content -Path $ProjectFile -Value $newProjectContent

    Write-Host "Project file '$ProjectFile' has been updated to version $VersionString."
}

Export-ModuleMember -Function Update-CsprojVersion