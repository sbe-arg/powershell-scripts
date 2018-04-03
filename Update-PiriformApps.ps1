<#
.SYNOPSIS
  Updater for Piriform apps.
.DESCRIPTION
  Use to update CCleaner, Recuva and Speccy, silently.
.PARAMETER Product
    Use to select product of your choice.
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
  Update-PiriformApps.ps1 -Product CCleaner
  Update-PiriformApps.ps1 -Product Recuva
  Update-PiriformApps.ps1 -Product Speccy
#>

Param(
  [parameter(Mandatory=$true)]
  [ValidateSet('Recuva','CCleaner','Speccy')]
  [string]$Product = "",

  [string]$Output_Folder = "C:/Temp/"
)


if($Product -eq "Recuva"){
  $iwr = Invoke-WebRequest -URI https://www.piriform.com/recuva/download/standard -UseBasicParsing
  $Version_rx = $iwr.links | Select-String -Pattern 'rcsetup(.*?).exe'
}
elseif($Product -eq "CCleaner"){
  $iwr = Invoke-WebRequest -URI https://www.piriform.com/ccleaner/download/standard -UseBasicParsing
  $Version_rx = $iwr.links | Select-String -Pattern 'ccsetup(.*?).exe'
}
elseif($Product -eq "Speccy"){
  $iwr = Invoke-WebRequest -URI https://www.piriform.com/speccy/download/standard -UseBasicParsing
  $Version_rx = $iwr.links | Select-String -Pattern 'spsetup(.*?).exe'
}

# find out latest version
$File_Name = $Version_rx.matches[1].Groups.Value[0]
$Available_v = $Version_rx.matches[1].Groups.Value[1]

$Check_lv = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "$Product"}
$Local_v = $Check_lv.DisplayVersion -replace "[\W+\.]",""

if($Local_v -lt "$Available_v" -or $Local_v -eq "$null"){
  Write-Warning "Version $Available_v of $Product ready to download."
  $DL_Url = "https://download.piriform.com/" + "$File_Name"
  $Output = "$Output_Folder" + "$File_Name"

  # download the file
  Invoke-WebRequest -Uri $DL_Url -UseBasicParsing -OutFile $Output

  # install it
  $args = "/S"
  Start-Process $Output $args
}
else{
  Write-Warning "You already have the latest version $($Check_lv.DisplayVersion) of $Product."
}
