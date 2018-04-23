$documentName = "example.library.ssm"
$region = "ap-southeast-2"

$yml = Get-Content $env:USERPROFILE/desktop/$($documentName).yml | Out-String

try{
  New-SSMDocument -Name $documentName -Content $yml -DocumentFormat YAML -DocumentType Command -Region $region
}
catch{
  try{
    Write-Warning "$documentName already exists, updating..."
    Update-SSMDocument -Name $documentName -Content $yml -DocumentFormat YAML -DocumentVersion '$LATEST' -Region $region
  }
  catch{
    Write-Host "$($_.Exception.Message)" -ForegroundColor Red
  }
}

$doco = Get-SSMDocument -Name $documentName -DocumentFormat YAML -DocumentVersion '$LATEST' -Region $region
Update-SSMDocumentDefaultVersion -Name $documentName -DocumentVersion $doco.DocumentVersion -Region $region
