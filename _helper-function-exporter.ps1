$functions = gci .\Functions\*-*.ps1 -recurse | sort basename

Write-Output "Name"
foreach($function in $functions){
  "$($function.basename)"
}

"`n" # space?

Write-Output "Exported commands"
foreach($function in $functions){
  "'$($function.basename)'"
}
