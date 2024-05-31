function Update-ResourceNameEnum {
    param(
        [string]$ProjectFile
    )

    $codeAnalysisCommon = "Microsoft.CodeAnalysis.Common"
    $codeAnalysisCSharp = "Microsoft.CodeAnalysis.CSharp"
    $codeAnalysisWorkspaces = "Microsoft.CodeAnalysis.Workspaces.Common"

    $versions = Get-NugetVersion -ProjectFile $ProjectFile -AssemblyName $codeAnalysisCommon, $codeAnalysisCSharp, $codeAnalysisWorkspaces

    $codeAnalysisCommonPath = Get-NugetResourcePath -AssemblyName $codeAnalysisCommon -Version $versions[$codeAnalysisCommon]
    $codeAnalysisCSharpPath = Get-NugetResourcePath -AssemblyName $codeAnalysisCSharp -Version $versions[$codeAnalysisCSharp]
    $codeAnalysisWorkspacesPath = Get-NugetResourcePath -AssemblyName $codeAnalysisWorkspaces -Version $versions[$codeAnalysisWorkspaces]

    $codeAnalysisCommonPath = $codeAnalysisCommonPath -replace ".Common.dll", ".dll"
    $codeAnalysisWorkspacesPath = $codeAnalysisWorkspacesPath -replace ".Common.dll", ".dll"

    Add-Type -Path $codeAnalysisCommonPath
    Add-Type -Path $codeAnalysisCSharpPath
    Add-Type -Path $codeAnalysisWorkspacesPath

    $filePath = "./ResourceAccessor.cs"
    $fileContent = Get-Content -Path $filePath -Raw

    $tree = [Microsoft.CodeAnalysis.CSharp.CSharpSyntaxTree]::ParseText($fileContent)

    $root = $tree.GetRoot()

    $enumDeclaration = $root.DescendantNodes() | Where-Object {
        $_ -is [Microsoft.CodeAnalysis.CSharp.Syntax.EnumDeclarationSyntax] -and
        $_.Identifier.ValueText -eq "ResourceName"
    }

    $newMembersList = New-Object "System.Collections.Generic.List[Microsoft.CodeAnalysis.CSharp.Syntax.EnumMemberDeclarationSyntax]"

    $resourceDir = "./Resources"
    $resourceDir = (Get-Item -Path $resourceDir).FullName
    Get-ChildItem -Path $resourceDir -Include *.png, *.svg -Recurse | ForEach-Object {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($_.FullName)

        $dir = [System.IO.Path]::GetDirectoryName($_.FullName)

        if ($dir -ne $resourceDir) {
            $subDir = [System.IO.Path]::GetFileName($dir)
        
            $name = "${subDir}_$name"
        }

        $member = [Microsoft.CodeAnalysis.CSharp.SyntaxFactory]::EnumMemberDeclaration($name)
        $newMembersList.Add($member)
    }

    $separatedSyntaxList = [Microsoft.CodeAnalysis.CSharp.SyntaxFactory]::SeparatedList([System.Collections.Generic.IEnumerable[Microsoft.CodeAnalysis.CSharp.Syntax.EnumMemberDeclarationSyntax]]$newMembersList)

    $newEnumDeclaration = $enumDeclaration.WithMembers($separatedSyntaxList)

    $newRoot = [Microsoft.CodeAnalysis.SyntaxNodeExtensions]::ReplaceNode($root, $enumDeclaration, $newEnumDeclaration)

    $formattedRoot = [Microsoft.CodeAnalysis.SyntaxNodeExtensions]::NormalizeWhitespace($newRoot, "    ", "`n", $true);

    $newCode = $formattedRoot.ToFullString()

    $newCode = [System.Text.RegularExpressions.Regex]::Replace($newCode, "^(namespace\s.*)$", "`$1`n", [System.Text.RegularExpressions.RegexOptions]::Multiline)

    $newCode = [System.Text.RegularExpressions.Regex]::Replace($newCode, "\)(is\s\{)", ") `$1")

    Set-Content -Path $filePath -Value $newCode -Force -NoNewline

    Write-Host "ResourceName enum updated successfully in '$filePath'."
}

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


Export-ModuleMember -Function Update-ResourceNameEnum, Update-JSResourceNameEnum