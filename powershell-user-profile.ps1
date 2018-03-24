# set SSL/TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$adminstatus = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

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

$host.ui.RawUI.WindowTitle = "Powershell - StartTime: $(Get-Date -Format h:mm:sss) - AdminMode: $adminstatus - Version: $($PSVersionTable.PSVersion)"
$host.ui.RawUI.windowsize.width = 170
$host.ui.RawUI.windowsize.height = 50

Set-ConsoleOpacity -Opacity 95

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
iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-GitHub.ps1 -UseBasicParsing -OutFile .\Update-Notifier-GitHub.ps1
.\Update-Notifier-GitHub
iwr -Uri https://raw.githubusercontent.com/sbe-arg/powershell-scripts/master/Update-Notifier-Git-SCM.ps1 -UseBasicParsing -OutFile .\Update-Notifier-Git-SCM.ps1
.\Update-Notifier-Git-SCM

# session aliases that I don't want permanent
Set-Alias -Name pwsh -Value "C:\Program Files\PowerShell\$env:powershell_netcore_version\pwsh.exe"

$location = Set-Location -Path C:\Dev -PassThru
Write-Host "Setting console location to $($location.Path)..." -ForegroundColor Yellow
