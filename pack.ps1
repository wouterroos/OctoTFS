$ErrorActionPreference = "Stop"

Write-Output "Updating tfx-cli..."
& npm up -g tfx-cli

Write-Output "Clean..."
Remove-Item .\build -Force -Recurse

Write-Output "Packing..."
& tfx extension create --root .\source\VSTSExtensions\OctopusBuildTasks --manifest-globs extension-manifest.json --outputPath .\build\Artifacts