param(
    [string]$key,
    [string]$value,
    [string]$type = 'GET',
    [string[]]$body
)

if($type -eq 'GET'){
    $values = @{ function="echo"; type=$type; key=$key; value=$value}
    $values | ConvertTo-Json
}
if($type -eq 'POST'){
    $values = @{ function="echo"; type=$type; key=$key; value=$value; body=@($body)}
    $values | ConvertTo-Json
}