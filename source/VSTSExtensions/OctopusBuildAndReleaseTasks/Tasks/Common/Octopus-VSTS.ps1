# Returns a path to the Octo.exe file
function Get-OctoExePath() {
    return Join-Path $PSScriptRoot "Octo.exe"
}

# Returns the Octo.exe arguments for credentials
function Get-OctoCredentialArgs($serviceDetails) {
	$pwd = $serviceDetails.Authorization.Parameters.Password
	if ($pwd.StartsWith("API-")) {
        return "--apiKey=$pwd"
    } else {
        $un = $serviceDetails.Authorization.Parameters.Username
        return "--user=$un --pass=$pwd"
    }
}
