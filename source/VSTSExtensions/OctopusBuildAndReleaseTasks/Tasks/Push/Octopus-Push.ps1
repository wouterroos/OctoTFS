[CmdletBinding()]
param()

Trace-VstsEnteringInvocation $MyInvocation

try {

    . .\Octopus-VSTS.ps1

    $ConnectedServiceName = Get-VstsInput -Name ConnectedServiceName -Require
    $Package = Get-VstsInput -Name Package -Require
    $AdditionalArguments = Get-VstsInput -Name AdditionalArguments
    $Replace = Get-VstsInput -Name Replace -AsBool

    $connectedServiceDetails = Get-VstsEndpoint -Name "$ConnectedServiceName" -Require
    $credentialArgs = Get-OctoCredentialArgs($connectedServiceDetails)
    $octopusUrl = $connectedServiceDetails.Url

    # Call Octo.exe
    $octoPath = Get-OctoExePath
    $Arguments = "push --package=`"$Package`" --server=$octopusUrl $credentialArgs $AdditionalArguments"
    if ($Replace) {
        $Arguments = $Arguments + " --replace-existing"
    }

    Invoke-VstsTool -FileName $octoPath -Arguments $Arguments -RequireExitCodeZero

} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
