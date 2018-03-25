Set-Location $env:userprofile\Downloads\

$Check_lv = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Atom"}
$Local_v = $Check_lv.DisplayVersion

# set SSL/TLS cert type
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- Set the uri for the latest release
$URI = "https://api.github.com/repos/atom/atom/releases/latest"

# --- Query the API to get the url of the zip
$Response = Invoke-RestMethod -Method Get -Uri $URI
$Asset = $Response.Assets | Where-Object {$_.Name -eq "AtomSetup-x64.exe"}
$AssetUrl = $Asset.browser_download_url

$Available_v = $Response.tag_name -replace "v","" # tag from github
if($Local_v -ne $Null){
  Write-Host "Found version $Local_v of Atom. " -ForegroundColor Yellow
}
if($Available_v.split(".").count -gt "3"){
    Write-Host "New version available ($Available_v) but might not be stable. " -ForegroundColor Magenta -NoNewline
}
elseif($Local_v -lt $Available_v -or $Local_v -eq $null){
    # do a nice pop up interaction
    $a = new-object -comobject wscript.shell
    $q1 = $a.popup("Download version $Available_v of Atom now?",0,"Version available!",4)
    If ($q1 -eq 6) {
        $q2 = $a.popup("Start download...",0,"Atom version $Available_v",4)
        If ($q2 -eq 6){
            # --- Download the file to the current location
            $OutputPath = "$((Get-Location).Path)\$($Asset.name)"
            Invoke-RestMethod -Method Get -Uri $AssetUrl -OutFile $OutputPath
            $q3 = $a.popup("Open container folder? $((Get-Location).Path)",0,"Atom version $Available_v",4)
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
    Write-Host "You have the latest version." -ForegroundColor Green
}

Write-Host ""
