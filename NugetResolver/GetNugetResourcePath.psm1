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

Export-ModuleMember -Function Get-NugetResourcePath