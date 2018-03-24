Set-Location $env:userprofile\Downloads\

$Check_lv = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "Powershell*"}
$Local_v = $Check_lv.DisplayVersion

# set SSL/TLS cert type
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- Set the uri for the latest release
$URI = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"

# --- Query the API to get the url of the zip
$Response = Invoke-RestMethod -Method Get -Uri $URI
$Asset = $Response.Assets | Where-Object {$_.Name -like "*-win-x64.msi"}
$AssetUrl = $Asset.browser_download_url

$Available_v = $Response.tag_name -replace "v","" # tag from github
if($Available_v.split(".").count -gt "3"){
    Write-Warning "Version number on $($Response.assets_url) does not match X.X.X"
    break
}
$Available_v_match = $Available_v + ".0" # match what is installed on windows

if($Local_v -lt $Available_v -or $Local_v -eq $null){
    # do a nice pop up interaction
    $a = new-object -comobject wscript.shell
    $q1 = $a.popup("Download version $Available_v of Powershell-Core now?",0,"New version available!",4)
    If ($q1 -eq 6) {
        $q2 = $a.popup("Start download...",0,"Powershell-Core version $Available_v",4)
        If ($q2 -eq 6){
            # --- Download the file to the current location
            $OutputPath = "$((Get-Location).Path)\$($Asset.name)"
            Invoke-RestMethod -Method Get -Uri $AssetUrl -OutFile $OutputPath
            $q3 = $a.popup("Open container folder? $((Get-Location).Path)",0,"Powershell-Core version $Available_v",4)
            If ($q3 -eq 6){
                ii .
            }
        }
    }

    #Button Types
    #Value Description
    #0 Show OK button.
    #1 Show OK and Cancel buttons.
    #2 Show Abort, Retry, and Ignore buttons.
    #3 Show Yes, No, and Cancel buttons.
    #4 Show Yes and No buttons.
    #5 Show Retry and Cancel buttons.
}
else{
    Write-Host "You are running the latest version of Powershell-Core ($Available_v)." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("powershell_netcore_version", $Available_v, "User")
}
