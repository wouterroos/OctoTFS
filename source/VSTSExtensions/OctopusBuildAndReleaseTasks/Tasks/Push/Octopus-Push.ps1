[CmdletBinding()]
param()

Write-Verbose "Entering script Octopus-Push.ps1"

# Returns a path to the Octo.exe file
function Get-OctoExePath() {
    return Join-Path $PSScriptRoot "Octo.exe"
}

# Returns the Octo.exe arguments for credentials
function Get-OctoCredentialArgs($serviceDetails) {
	$pwd = $serviceDetails.Auth.Parameters.Password
	if ($pwd.StartsWith("API-")) {
        return "--apiKey=$pwd"
    } else {
        $un = $serviceDetails.Auth.Parameters.Username
        return "--user=$un --pass=$pwd"
    }
}

$connectedServiceDetails = Get-VstsEndpoint -Name "$ConnectedServiceName" -Require
$credentialArgs = Get-OctoCredentialArgs($connectedServiceDetails)
$octopusUrl = $connectedServiceDetails.Url

# Call Octo.exe
$octoPath = Get-OctoExePath
Write-Output "Path to Octo.exe = $octoPath"
$Arguments = "push --package=`"$Package`" --server=$octopusUrl $credentialArgs --replace-existing=$Replace $AdditionalArguments"
Invoke-VstsTool -FileName $octoPath -Arguments $Arguments

Write-Verbose "Completed Octopus-Push.ps1"
