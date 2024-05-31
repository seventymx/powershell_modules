function Add-GrpcWeb {
    param (
        [string]$ProtoFilesPath,
        [string]$OutputPath
    )

    $ProtoFilesPath = Resolve-Path $ProtoFilesPath
    $OutputPath = Resolve-Path $OutputPath

    if (-not (Test-Path -Path $OutputPath -PathType Container)) {
        New-Item -ItemType Directory -Path $OutputPath
    }
    else {
        Get-ChildItem -Path $OutputPath -Recurse | Remove-Item -Force
    }

    $OutputPath = Resolve-Path $OutputPath

    $protoFiles = Get-ChildItem -Path $ProtoFilesPath -Filter *.proto

    foreach ($protoFile in $protoFiles) {
        $protocCommand = "protoc --proto_path=$ProtoFilesPath --js_out=import_style=commonjs:$OutputPath --grpc-web_out=import_style=commonjs,mode=grpcwebtext:$OutputPath $($protoFile.FullName)"

        Invoke-Expression $protocCommand
    }

    Write-Host "gRPC-Web client code generation completed."
}

Export-ModuleMember -Function Add-GrpcWeb