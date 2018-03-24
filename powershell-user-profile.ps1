# set SSL/TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$adminstatus = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$host.ui.RawUI.WindowTitle = "Powershell - StartTime: $(Get-Date -Format h:mm:sss) - AdminMode: $adminstatus - Version: $($PSVersionTable.PSVersion)"

$git = Import-Module posh-git -PassThru | select Name,Version
if($git -eq $null){PowerShellGet\Install-Module posh-git -Scope CurrentUser ; Import-Module posh-git -PassThru | select Name,Version}
Write-Host "Importing module $($git.Name) $($git.Version)..." -ForegroundColor Yellow

# do a nice pop up interaction
$a = new-object -comobject wscript.shell
$q1 = $a.popup("Don't forget to use Powershell-Core, 'pwsh'.",0,"Reminder!",0)

#Button Types
#Value Description
#0 Show OK button.
#1 Show OK and Cancel buttons.
#2 Show Abort, Retry, and Ignore buttons.
#3 Show Yes, No, and Cancel buttons.
#4 Show Yes and No buttons.
#5 Show Retry and Cancel buttons.

cd $env:userprofile\Downloads\
# do some checks
iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-Powershell-Core.ps1 -UseBasicParsing -OutFile .\Update-Notifier-Powershell-Core.ps1
.\Update-Notifier-Powershell-Core
iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-Atom.ps1 -UseBasicParsing -OutFile .\Update-Notifier-Atom.ps1
.\Update-Notifier-Atom

# session aliases that I don't want permanent
Set-Alias -Name pwsh -Value "C:\Program Files\PowerShell\$env:powershell_netcore_version\pwsh.exe"

$location = Set-Location -Path C:\Dev -PassThru
Write-Host "Setting console location to $($location.Path)..." -ForegroundColor Yellow
