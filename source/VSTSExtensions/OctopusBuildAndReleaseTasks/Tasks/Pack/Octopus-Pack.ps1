[CmdletBinding()]
param()

Write-Verbose "Entering script Octopus-Pack.ps1"

# Returns a path to the Octo.exe file
function Get-PathToOctoExe() {
	$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.ScriptBlock.File
	$targetPath = Join-Path -Path $PSScriptRoot -ChildPath "Octo.exe" 
	return $targetPath
}

# Call Octo.exe
$octoPath = Get-PathToOctoExe
Write-Output "Path to Octo.exe = $octoPath"
$Overwrite = [System.Convert]::ToBoolean($Overwrite)
$Arguments = "pack --id=`"$PackageId`" --format=$PackageFormat --version=$PackageVersion --outFolder=`"$OutputPath`" --basePath=`"$SourcePath`" --author=`"$NugetAuthor`" --title=`"$NugetTitle`" --description=`"$NugetDescription`" --releaseNotes=`"$NuGetReleaseNotes`" --releaseNotesFile=`"$NugetReleaseNotesFile`" --overwrite=$Overwrite" 
if ($Include) {
   ForEach ($IncludePath in $Include.replace("`r", "").split("`n")) {
   $Arguments = $Arguments + " --include=`"$IncludePath`""
   }
}

Invoke-VstsTool -FileName $octoPath -Arguments $Arguments

Write-Verbose "Completed Octopus-Pack.ps1"
