[CmdletBinding()]
param()

# Returns a path to the Octo.exe file
function Get-PathToOctoExe() {
    $PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.ScriptBlock.File
    $targetPath = Join-Path -Path $PSScriptRoot -ChildPath "Octo.exe"
    return $targetPath
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

## Execution starts here

Trace-VstsEnteringInvocation $MyInvocation

try {

    $ConnectedServiceName = Get-VstsInput -Name ConnectedServiceName -Require
    $Package = Get-VstsInput -Name Package -Require
    $AdditionalArguments = Get-VstsInput -Name AdditionalArguments

    $connectedServiceDetails = Get-VstsEndpoint -Name "$ConnectedServiceName" -Require
    $credentialArgs = Get-OctoCredentialArgs($connectedServiceDetails)
    $octopusUrl = $connectedServiceDetails.Url

    # Call Octo.exe
    $octoPath = Get-PathToOctoExe
    Write-Output "Path to Octo.exe = $octoPath"
    $Arguments = "push --package=`"$Package`" --server=$octopusUrl $credentialArgs --replace-existing=$Replace $AdditionalArguments"
    Invoke-VstsTool -FileName $octoPath -Arguments $Arguments

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
