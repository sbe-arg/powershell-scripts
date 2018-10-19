# set SSL/TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# check console rights
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$adminstatus = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# set some console ui values
$host.ui.RawUI.WindowTitle = "Powershell - StartTime: $(Get-Date -Format h:mm:sss) - AdminMode: $adminstatus - Version: $($PSVersionTable.PSVersion)"

# do a nice pop up interaction as powershell is running, you will be surpriced how many times powershell runs without your knowledge
$a = new-object -comobject wscript.shell
$q1 = $a.popup("Console started.",0,"Powershell.",0)

$psgallery = Get-PSRepository -Name PSGallery
if($psgallery.InstallationPolicy -ne 'Trusted'){
    Write-Warning "PSGallery: Untrusted!. 'Set-PSRepository -Name PSGallery -InstallationPolicy Trusted'"
}
else{
    Write-Output "PSGallery: Trusted!."
}

# import PSGallery modules
$PowerShellGet_modules = @(
      "Posh-Git",
      "CloudRemoting",
      "AWSPowershell",
      "Posh-AwsEasy",
      "Posh-Santiago"
)
foreach($module in $PowerShellGet_modules){
      Write-Host "Importing module $module" -ForegroundColor Yellow
      try{
            Import-Module $module -ErrorAction Stop
      }
      catch{
            PowerShellGet\Install-Module $module -Scope CurrentUser
            Import-Module $module
      }
}

Get-Module | select Name,Version

# reminder
Write-Host "Don't forget to use Powershell-Core, 'pwsh'..."

# inet works?
if((Test-Connection 9.9.9.9 -Quiet -Count 1) -eq $True){
      cd $env:userprofile\Downloads\
      # do some checks
      iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-Powershell-Core.ps1 -UseBasicParsing -OutFile .\Update-Notifier-Powershell-Core.ps1
      .\Update-Notifier-Powershell-Core
      iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-Git-SCM.ps1 -UseBasicParsing -OutFile .\Update-Notifier-Git-SCM.ps1
      .\Update-Notifier-Git-SCM
      # this one is different
      iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-GitHub.ps1 -UseBasicParsing -OutFile .\Update-Notifier-GitHub.ps1
      .\Update-Notifier-GitHub
}
else{
    Write-Warning "No internet connection?... can't ping 9.9.9.9"
}

# ps.net?
try{
    $pwsh = Get-ChildItem "C:\Program Files\PowerShell\" -Recurse | where {$_.FullName -match "pwsh.exe"}
    if($pwsh -ne $Null){
      # session aliases that I don't want permanent
      Set-Alias -Name pwsh -Value $pwsh.FullName
    }
}
catch{
    Write-Warning "PowerShell Core missing on this system..."
}

# set location to your safe place
$location = Set-Location -Path $env:userprofile\Documents\Dev -PassThru
Write-Host "Setting console location to $($location.Path)..." -ForegroundColor Yellow

# I personally don`t like devenv so I call it vs
Set-Alias -Name vs -Value "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.exe"