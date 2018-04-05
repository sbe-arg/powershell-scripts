# Only requirement is the clixml password files in an S3 bucket, then put this in your userdata

$bucket = "my-s3-bucket-name"
$prefix = "prefix/where/my/clixmls/located"
# Get-Credential –Credential GalleryUser | Export-Clixml .\GalleryUserCredFile.clixml -Verbose
# Get-Credential –Credential GalleryAdmin | Export-Clixml .\GalleryAdminCredFile.clixml -Verbose


# get latest version from git.com
$FileUrl = "https://github.com/PowerShell/PSPrivateGallery/archive/master.zip"
$SaveAs = "PSPrivateGallery-master"
$Location = "$env:TEMP"
$fileextension = [System.IO.Path]::GetExtension("$FileUrl")
$output = $Location + "\" + $SaveAs + $fileextension
Write-Verbose "File saved in $output"
Invoke-WebRequest -Uri $FileUrl -OutFile $output -Verbose

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
Copy-S3Object -BucketName $bucket/$prefix -Key GalleryUserCredFile.clixml -LocalFile “$Dir\PSPrivateGallery\Configuration\GalleryUserCredFile.clixml”
Copy-S3Object -BucketName $bucket/$prefix -Key GalleryAdminCredFile.clixml -LocalFile “$Dir\PSPrivateGallery\Configuration\GalleryAdminCredFile.clixml”

# deploy config:
# .\PSPrivateGallery.ps1"
# populate local instance:
# .\PSPrivateGalleryPublish.ps1"
