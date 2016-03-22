param (
    [Parameter(Mandatory=$true)]
    [string]
    $accessToken,
    [switch]$production=$false
)

$ErrorActionPreference = "Stop"

Write-Output "Updating tfx-cli..."
& npm up -g tfx-cli

Write-Output "Looking for VSIX file to publish..."
$vsixFile = Get-ChildItem -Path .\build\Artifacts\*.vsix

if ($production) {
    Write-Output "Publishing $vsixFile to everyone (public extension)..."
    & tfx extension publish --vsix $vsixFile --token $accessToken
} else {
    Write-Output "Publishing $vsixFile as a private test extension..."
    & tfx extension publish --vsix $vsixFile --token $accessToken --shareWith "octopus-deploy"
}