function Initialize-Solution {
    param (
        [string]$SolutionName,
        [string]$SolutionPath
    )
    dotnet new sln -n $SolutionName -o $SolutionPath
}

function Add-ProjectsToSolution {
    param (
        [string]$SolutionPath,
        [string]$DirectoryPath,
        [string]$Filter
    )
    $projectFiles = Get-ChildItem -Path $DirectoryPath -Recurse | Where-Object { $_.Name -match $Filter }
    foreach ($projectFile in $projectFiles) {
        dotnet sln $solutionPath add $projectFile.FullName
    }
}

function New-Solution {
    param (
        [string]$DirectoryPath,
        [string]$Filter = ".*(\.csproj|\.vbproj)$"
    )

    if (-not (Test-Path $DirectoryPath)) {
        Write-Error "Directory does not exist."
        exit
    }

    $SolutionName = Split-Path -Leaf $DirectoryPath
    $SolutionPath = Join-Path $DirectoryPath "$SolutionName.sln"

    Initialize-Solution -SolutionName $SolutionName -SolutionPath $DirectoryPath
    Add-ProjectsToSolution -SolutionPath $SolutionPath -DirectoryPath $directoryPath -Filter $Filter
}

Export-ModuleMember -Function New-Solution