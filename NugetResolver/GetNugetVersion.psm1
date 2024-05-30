function Get-NugetVersion {
    param (
        $ProjectFile,
        [string[]]$AssemblyNames
    )

    [xml]$projectXml = Get-Content "./$ProjectFile"

    $versions = @{}

    foreach ($assemblyName in $AssemblyNames) {
        $version = $projectXml.Project.ItemGroup.PackageReference | Where-Object { $_.Include -eq $assemblyName } | Select-Object -ExpandProperty Version

        $versions.Add($assemblyName, $version)
    }

    return $versions
}

Export-ModuleMember -Function Get-NugetVersion