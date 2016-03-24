param (
    [Parameter(Mandatory=$true,HelpMessage="Test or Production")]
    [ValidateSet("Test", "Production")]
    [string]
    $environment,
    [Parameter(Mandatory=$true,HelpMessage="The three number version for this release")]
    [string]
    $version
)

$ErrorActionPreference = "Stop"

$extensionsDirectoryPath = "$PSScriptRoot\source\VSTSExtensions"
$buildDirectoryPath = "$PSScriptRoot\build"
$buildArtifactsPath = "$buildDirectoryPath\Artifacts"
$buildTempPath = "$buildDirectoryPath\Temp"

function UpdateTfxCli() {
    Write-Host "Updating tfx-cli..."
    & npm up -g tfx-cli
}

function Prepare() {
    if (Test-Path $buildDirectoryPath) {
        $buildDirectory = Get-Item "$buildDirectoryPath"
        Write-Host "Cleaning $buildDirectory..."
        Remove-Item $buildDirectory -Force -Recurse
    }
    
    New-Item -Type Directory -Path $buildTempPath | Out-Null
    
    Copy-Item $extensionsDirectoryPath -Destination $buildTempPath -Recurse
}

function UpdateExtensionManifestOverrideFile($extensionBuildTempPath, $environment, $version) {
    Write-Host "Finding environment-specific manifest overrides..."
    $overridesSourceFilePath = "$extensionBuildTempPath\extension-manifest.$environment.json"
    $overridesSourceFile = Get-ChildItem -Path $overridesSourceFilePath
    if ($overridesSourceFile -eq $null) {
        Write-Error "Could not find the extension-manifest override file: $overridesSourceFilePath"
        return $null
    }

    Write-Host "Using $overridesSourceFile for overriding the standard extension-manifest.json, updating version to $version..."
    $overridesFilePath = "$extensionBuildTempPath\extension-manifest.$environment.$version.json"
    ((Get-Content $overridesSourceFile) -replace "0.0.0", $version) | Out-File $overridesFilePath -Encoding ASCII # tfx-cli doesn't support UTF8 with BOM
    Get-Content $overridesFilePath | Write-Host
    return Get-Item $overridesFilePath
}

function UpdateTaskManifests($extensionBuildTempPath, $version) {
    $taskManifestFiles = Get-ChildItem "$extensionBuildTempPath" -Include "task.json" -Recurse
    foreach ($taskManifestFile in $taskManifestFiles) {
        Write-Host "Updating version to $version in $taskManifestFile..."
        $task = ConvertFrom-JSON -InputObject (Get-Content $taskManifestFile -Raw)
        $netVersion = [System.Version]::Parse($version)
        $task.version.Major = $netVersion.Major
        $task.version.Minor = $netVersion.Minor
        $task.version.Patch = $netVersion.Build
        ConvertTo-JSON $task | Out-File $taskManifestFile -Encoding UTF8
    }
}

function Pack($extensionName) {
    Write-Host "Packing $extensionName..."
    $extensionBuildTempPath = Get-ChildItem $buildTempPath -Include $extensionName -Recurse
    Write-Host "Found extension working directory $extensionBuildTempPath"
    
    $overridesFile = UpdateExtensionManifestOverrideFile $extensionBuildTempPath $environment $version
    UpdateTaskManifests $extensionBuildTempPath $version
    
    & tfx extension create --root $extensionBuildTempPath --manifest-globs extension-manifest.json --overridesFile $overridesFile --outputPath "$buildArtifactsPath\$environment" --no-prompt --json | Write-Host
}

UpdateTfxCli
Prepare
Pack "OctopusBuildAndReleaseTasks"