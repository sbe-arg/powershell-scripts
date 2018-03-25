# set SSL/TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# check console rights
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$adminstatus = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# handy function to change console opacity
function Set-ConsoleOpacity
{
    param(
        [ValidateRange(10,100)]
        [int]$Opacity
    )

    # Check if pinvoke type already exists, if not import the relevant functions
    try {
        $Win32Type = [Win32.WindowLayer]
    } catch {
        $Win32Type = Add-Type -MemberDefinition @'
            [DllImport("user32.dll")]
            public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

            [DllImport("user32.dll")]
            public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

            [DllImport("user32.dll")]
            public static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);
'@ -Name WindowLayer -Namespace Win32 -PassThru
    }

    # Calculate opacity value (0-255)
    $OpacityValue = [int]($Opacity * 2.56) - 1

    # Grab the host windows handle
    $ThisProcess = Get-Process -Id $PID
    $WindowHandle = $ThisProcess.MainWindowHandle

    # "Constants"
    $GwlExStyle  = -20;
    $WsExLayered = 0x80000;
    $LwaAlpha    = 0x2;

    if($Win32Type::GetWindowLong($WindowHandle,-20) -band $WsExLayered -ne $WsExLayered){
        # If Window isn't already marked "Layered", make it so
        [void]$Win32Type::SetWindowLong($WindowHandle,$GwlExStyle,$Win32Type::GetWindowLong($WindowHandle,$GwlExStyle) -bxor $WsExLayered)
    }

    # Set transparency
    [void]$Win32Type::SetLayeredWindowAttributes($WindowHandle,0,$OpacityValue,$LwaAlpha)
}

# set some console ui values
$host.ui.RawUI.WindowTitle = "Powershell - StartTime: $(Get-Date -Format h:mm:sss) - AdminMode: $adminstatus - Version: $($PSVersionTable.PSVersion)"
$host.ui.RawUI.windowsize.width = 170
$host.ui.RawUI.windowsize.height = 50
Set-ConsoleOpacity -Opacity 95

# do a nice pop up interaction as powershell is running, you will be surpriced how many times powershell runs without your knowledge
$a = new-object -comobject wscript.shell
$q1 = $a.popup("Console started.",0,"Powershell.",0)

# import must have modules
$PowerShellGet_modules = @(
  "Posh-Git",
  "CloudRemoting",
  "AWSPowershell"
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
# this ones are my forks
[hashtable]$PsGet_modules = @{
  "Posh-Santiago" = "https://github.com/sbe-arg/Posh-Santiago/archive/master.zip"
  "Posh-AwsEasy" = "https://github.com/sbe-arg/Posh-AwsEasy/archive/master.zip"
}
foreach($module in $PsGet_modules.keys){
  Write-Host "Importing module $module" -ForegroundColor Yellow
  try{
    Import-Module $module -ErrorAction Stop
  }
  catch{
    try{
      psget\Install-Module -ModuleUrl ($PsGet_modules.Values | where {$_ -match $module}) -Update
      Import-Module $module
    }
    catch{
      (new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/psget/psget/master/GetPsGet.ps1") | iex
    }
  }
}

Get-Module | select Name,Version

# reminder
Write-Host "Don't forget to use Powershell-Core, 'pwsh'..."

# inet works?
if((Test-Connection 8.8.8.8 -Quiet -Count 1) -eq $True){
  cd $env:userprofile\Downloads\
  # do some checks
  iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-Powershell-Core.ps1 -UseBasicParsing -OutFile .\Update-Notifier-Powershell-Core.ps1
  .\Update-Notifier-Powershell-Core
  iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-Atom.ps1 -UseBasicParsing -OutFile .\Update-Notifier-Atom.ps1
  .\Update-Notifier-Atom
  iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-GitHub.ps1 -UseBasicParsing -OutFile .\Update-Notifier-GitHub.ps1
  .\Update-Notifier-GitHub
  iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-Git-SCM.ps1 -UseBasicParsing -OutFile .\Update-Notifier-Git-SCM.ps1
  .\Update-Notifier-Git-SCM
}
else{
  Write-Warning "No internet connection?... can't ping 8.8.8.8"
}

# ps.net?
if((test-path "C:\Program Files\PowerShell\$env:powershell_netcore_version\pwsh.exe") -eq $True){
  # session aliases that I don't want permanent
  Set-Alias -Name pwsh -Value "C:\Program Files\PowerShell\$env:powershell_netcore_version\pwsh.exe"
}

# set location to your safe place
$location = Set-Location -Path C:\Dev -PassThru
Write-Host "Setting console location to $($location.Path)..." -ForegroundColor Yellow
