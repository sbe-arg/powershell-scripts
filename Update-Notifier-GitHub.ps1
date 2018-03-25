Set-Location $env:userprofile\Downloads\

# desktop
$Check_lv = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "GitHub Desktop"}
$Local_v = $Check_lv.DisplayVersion

if($Local_v -eq $null){
  Write-Host "Can't find GitHub Desktop on system. https://desktop.github.com/" -ForegroundColor Yellow
}
else{
  Write-Host "You are running the version $Local_v of GitHub Desktop." -ForegroundColor Yellow
}

# desktop (deprecated version)
$Check_lv_ = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "GitHub"}
$Local_v_ = $Check_lv_.DisplayVersion

if($Local_v_ -ne $null){
  Write-Host "There is a deprecated version of GitHub Desktop installed ($Local_v_). https://github-windows.s3.amazonaws.com/GitHubSetup.exe" -ForegroundColor Yellow
}
