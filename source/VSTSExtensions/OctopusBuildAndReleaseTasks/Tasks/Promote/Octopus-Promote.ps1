﻿[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation

try {

    . .\Octopus-VSTS.ps1

    $ConnectedServiceName = Get-VstsInput -Name ConnectedServiceName -Require
    $Project = Get-VstsInput -Name Project -Require
    $From = Get-VstsInput -Name From -Require
    $To = Get-VstsInput -Name To -Require
    $ShowProgress = Get-VstsInput -Name ShowProgress -AsBool
    $AdditionalArguments = Get-VstsInput -Name AdditionalArguments

    $connectedServiceDetails = Get-VstsEndpoint -Name "$ConnectedServiceName" -Require
    $credentialArgs = Get-OctoCredentialArgs($connectedServiceDetails)
    $octopusUrl = $connectedServiceDetails.Url

    # Call Octo.exe
    $octoPath = Get-OctoExePath
    $Arguments = "promote-release --project=`"$Project`" --from=`"$From`" --server=$octopusUrl $credentialArgs $AdditionalArguments"
    
    if ($ShowProgress) {
       $Arguments += " --progress"
    }
    
    if ($To) {
        ForEach($Environment in $To.Split(',').Trim()) {
            $Arguments = $Arguments + " --to=`"$Environment`""
        }
    }
    Invoke-VstsTool -FileName $octoPath -Arguments $Arguments -RequireExitCodeZero

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
