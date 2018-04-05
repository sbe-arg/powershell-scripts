# get latest version from git.com
Get-FileFromWeb -FileUrl https://github.com/PowerShell/PSPrivateGallery/archive/master.zip -SaveAs PSPrivateGallery-master -Location $env:TEMP -Verbose

# location to deploy this
$Dir = "C:\PSGallery"
if($false -eq (Test-Path $Dir)){
    New-Item $Dir -type directory -Verbose
}

# unzip to Dir
Expand-Archive –Path “$env:TEMP\PSPrivateGallery-master.zip” –DestinationPath "$Dir" –Force -Verbose # Requires PSv5 $PSVersionTable.PSVersion.Major

# rename for being nice
Rename-Item –Path "$Dir\PSPrivateGallery-master" –NewName "$Dir\PSPrivateGallery" -Verbose

# unlock files on directory
dir –Path “$Dir\PSPrivateGallery” –Recurse | Unblock-File -Verbose

# copy modules to the right loactions
Copy-Item –Path “$Dir\PSPrivateGallery\Modules\*” –Destination “C:\Program Files\WindowsPowerShell\Modules” –Recurse -Verbose

# set credentials
Cd “$Dir\PSPrivateGallery\Configuration”
# Get-Credential –Credential GalleryUser | Export-Clixml .\GalleryUserCredFile.clixml -Verbose
# Get-Credential –Credential GalleryAdmin | Export-Clixml .\GalleryAdminCredFile.clixml -Verbose

# update config data to your needs
# atom .\PSPrivateGalleryEnvironment.psd1
# atom .\PSPrivateGalleryPublishEnvironment.psd1

# deploy config:
write-warning "to deploy configs run: .\PSPrivateGallery.ps1"
# populate local instance:
write-warning "to start instance run: .\PSPrivateGalleryPublish.ps1"


# register a server to use to use the new gallery
write-warning "Register a server to use to use new gallery:"
write-warning 'Register-PSRepository –Name PSPrivateGallery –SourceLocation “http://your.gallery.urlhere/api/v2” –InstallationPolicy Trusted –PackageManagementProvider NuGet'

# add firewall rule for port X
write-host "Add firewall rule for port X on host"
write-host 'New-NetFirewallRule -Name PSGallery -DisplayName "PSGallery" -Description "Allow access to the PSGallery" -Protocol TCP -RemoteAddress Any -LocalPort 8080 -Action Allow -enabled True'

# example
write-host "Search in Gallery example:"
write-host "Find-Module –Name PSScriptAnalyzer"
