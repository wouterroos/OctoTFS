[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation

try {

    . .\Octopus-VSTS.ps1

    $connectedServiceDetails = Get-VstsEndpoint -Name "$ConnectedServiceName" -Require
    $credentialArgs = Get-OctoCredentialArgs($connectedServiceDetails)
    $octopusUrl = $connectedServiceDetails.Url

    # Call Octo.exe
    $octoPath = Get-OctoExePath
    Write-Output "Path to Octo.exe = $octoPath"
    $Arguments = "deploy-release --project=`"$Project`" --server=$octopusUrl $credentialArgs $AdditionalArguments"
    Invoke-VstsTool -FileName $octoPath -Arguments $Arguments

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

