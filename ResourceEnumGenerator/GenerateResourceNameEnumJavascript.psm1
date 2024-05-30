function Update-JSResourceNameEnum {
    param (
        [string]$ResourceFilesPath,
        [string]$OutputPath
    )

    $resourceFiles = Get-ChildItem -Path $ResourceFilesPath -Include *.svg -Recurse

    $enumString = "const ResourceName = Object.freeze({`n"

    foreach ($file in $resourceFiles) {
        $name = [IO.Path]::GetFileNameWithoutExtension($file.FullName)
        $enumString += "    ${name}: ""$name"",`n"
    }

    $enumString += "});`n`n"

    $enumString += "export default ResourceName;`n"

    $outputFileName = "resource_name.js"
    $outputFilePath = Join-Path -Path $OutputPath -ChildPath $outputFileName

    $enumString | Out-File -FilePath $outputFilePath
}

Export-ModuleMember -Function Update-JSResourceNameEnum