<#
.SYNOPSIS
  Updater for VirtualBox app.
.DESCRIPTION
  Use to update VirtualBox, silently.
.PARAMETER Output_Folder
    Use to specify the output folder for the download.
.INPUTS
  NONE
.OUTPUTS
  Installers stored in C:/Temp by default unless overriten.
.NOTES
  Version:        1.0
  Author:         Santiago Bernhardt
  Creation Date:  January 2017
  Purpose/Change: Release
.EXAMPLE
  Update-VirtualBox.ps1
#>

Param(
    [string]$Output_Folder = "C:/Temp/"
)

$Product = "VirtualBox"
$iwr = Invoke-WebRequest -URI https://www.virtualbox.org/wiki/Downloads -UseBasicParsing
$Version_rx = $iwr.links | Select-String -Pattern 'VirtualBox-(.*?).exe'

# find out latest version
$File_Name = $Version_rx.matches[0].Groups.Value[0]
$Available_v = $Version_rx.matches[0].Groups.Value[1] -replace "\-.*$",""

$Check_lv = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*$Product*"}
$Local_v = $Check_lv.DisplayVersion

if($Local_v -lt $Available_v -or $Local_v -eq "$null"){
  Write-Warning "Version $Available_v of $Product ready to download."
  $DL_Url = "http://download.virtualbox.org/virtualbox/" + "$Available_v/" + "$File_Name"
  $Output = "$Output_Folder" + "$File_Name"

  # download the file
  Invoke-WebRequest -Uri $DL_Url -UseBasicParsing -OutFile $Output

  # install it
  $args = "--silent"
  Start-Process $Output $args
}
else{
  Write-Warning "You already have the latest version $($Check_lv.DisplayVersion) of $Product."
}
