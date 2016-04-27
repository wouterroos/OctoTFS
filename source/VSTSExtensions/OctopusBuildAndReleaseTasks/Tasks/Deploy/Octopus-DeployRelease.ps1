[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation

try {

    . .\Octopus-VSTS.ps1

    $ConnectedServiceName = Get-VstsInput -Name ConnectedServiceName -Require
    $Project = Get-VstsInput -Name Project -Require
    $ReleaseNumber = Get-VstsInput -Name ReleaseNumber -Require
    $Environments = Get-VstsInput -Name Environments -Require
    $ShowProgress = Get-VstsInput -Name ShowProgress -AsBool

    $connectedServiceDetails = Get-VstsEndpoint -Name "$ConnectedServiceName" -Require
    $credentialArgs = Get-OctoCredentialArgs($connectedServiceDetails)
    $octopusUrl = $connectedServiceDetails.Url

    # Call Octo.exe
    $octoPath = Get-OctoExePath
    $Arguments = "deploy-release --project=`"$Project`" --releaseNumber=`"$ReleaseNumber`" --progress="$ShowProgress" --server=$octopusUrl $credentialArgs $AdditionalArguments"
    if ($Environments) {
        ForEach($Environment in $Environments.Split(',').Trim()) {
            $Arguments = $Arguments + " --deployto=`"$Environment`""
        }
    }

    Invoke-VstsTool -FileName $octoPath -Arguments $Arguments

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}

