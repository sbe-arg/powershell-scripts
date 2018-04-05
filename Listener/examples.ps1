# using hash is easier formatting but uggly to json
function Convert-HashToString {
param(
    [Parameter(Mandatory = $true)]
    [System.Collections.Hashtable]$Hash
)
    $nomorehash = $hash.GetEnumerator() | select name,value
    $stringed = New-Object PSObject
    foreach ($h in $nomorehash){
        Write-Warning "Converting hash key: $($h.name) value: $($h.value) to string."
        Add-Member -InputObject $stringed -MemberType NoteProperty -Name $h.Name -Value $h.Value -ErrorAction SilentlyContinue -Force
    }
    return $stringed
}
[hashtable]$body = @{ "title"="some"; "message"="wow"; "value1"="1" ; "value2"="2" }
$stringbody = Convert-HashToString -Hash $body



#$stringbody = get-service # debug try something else and try to inject code

$jsonbody = $stringbody | ConvertTo-Json

Invoke-RestMethod -UseBasicParsing -Uri "http://localhost:8080/echo?do=stuff" -ContentType application/json -Body $jsonbody -Method Post