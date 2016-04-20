[CmdletBinding()]
param()

# Returns a path to the Octo.exe file
function Get-PathToOctoExe() {
	$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.ScriptBlock.File
	$targetPath = Join-Path -Path $PSScriptRoot -ChildPath "Octo.exe"
	return $targetPath
}

$connectedServiceDetails = Get-VstsEndpoint -Name "$ConnectedServiceName" -Require
$credentialArgs = Get-OctoCredentialArgs($connectedServiceDetails)
$octopusUrl = $connectedServiceDetails.Url

# Call Octo.exe
$octoPath = Get-OctoExePath
Write-Output "Path to Octo.exe = $octoPath"
$Arguments = "deploy-release --project=`"$Project`" --server=$octopusUrl $credentialArgs $AdditionalArguments"
Invoke-VstsTool -FileName $octoPath -Arguments $Arguments

Write-Verbose "Completed Octopus-Push.ps1"
