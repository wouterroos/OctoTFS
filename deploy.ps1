$ErrorActionPreference = "Stop"

$environment = $OctopusParameters["Octopus.Environment.Name"]
$version = $OctopusParameters["Octopus.Release.Number"]
$accessToken = $OctopusParameters["AccessToken"]

& "$PSScriptRoot\pack.ps1" -environment $environment -version $version
& "$PSScriptRoot\publish.ps1" -environment $environment -version $version -accessToken $accessToken