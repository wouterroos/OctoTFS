[CmdletBinding()]
param()

Write-Verbose "Entering script Octopus-Push.ps1"

#Import Octopus Common functions
$OctopusCommonPS = Join-Path -Path ((Get-Item $PSScriptRoot).Parent.Parent) -ChildPath "Common\Octopus-VSTS.ps1"
. $OctopusCommonPs

$connectedServiceDetails = Get-VstsEndpoint -Name "$ConnectedServiceName" -Require
$credentialArgs = Get-OctoCredentialArgs($connectedServiceDetails)
$octopusUrl = $connectedServiceDetails.Url

# Call Octo.exe
$octoPath = Get-OctoExePath
Write-Output "Path to Octo.exe = $octoPath"
$Arguments = "push --package=`"$Package`" --server=$octopusUrl $credentialArgs --replace-existing=$Replace $AdditionalArguments"
Invoke-VstsTool -FileName $octoPath -Arguments $Arguments

Write-Verbose "Completed Octopus-Push.ps1"
