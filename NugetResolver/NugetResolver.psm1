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

function Get-NugetResourcePath {
    param(
        [string]$AssemblyName,
        [string]$Version,
        [string]$Framework
    )

    if (-not $Framework) {
        $Framework = "netstandard2.0"
    }

    $assemblyNameLowerCase = $AssemblyName.ToLower()

    $userHome = if ($PSVersionTable.Platform -eq "Win32NT") { $Env:USERPROFILE } else { $Env:HOME }

    $assemblyPath = Join-Path $userHome ".nuget/packages/${assemblyNameLowerCase}/${Version}/lib/${Framework}/${assemblyName}.dll"

    return $assemblyPath
}


Export-ModuleMember -Function Get-NugetVersion, Get-NugetResourcePath