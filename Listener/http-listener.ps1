# Create a listener on port
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8080/') 
$listener.AuthenticationSchemes = "Anonymous" # use Anonymous or Basic for base64 username:password
$listener.Start()
write-warning "Listener started on $($listener.Prefixes)"

# lock directory to prevent code injection
New-PSDrive -Name PowerShellSite -PSProvider FileSystem -Root $PWD.Path -ErrorAction SilentlyContinue

# start loop
while ($true) {
    $context = $listener.GetContext()
    # Start time counter
    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    # Setup a place to deliver a response
    $response = $context.Response
    # Capture the details about the request
    $request = $context.Request
    # Capture /*/*
    $requestvars = ([String]$request.RawUrl).split("/")

    # handle non GET's
    if($request.HttpMethod -ne "GET"){
        # read the body
        $body = $request.InputStream
        $payload = New-Object System.IO.StreamReader($body) 
        $contentPL = $payload.ReadToEnd()
        if($contentPL -ne $Null){
            Write-Output "Payload received:"
            $body = $contentPL | ConvertFrom-Json
            # body requirements
            if($body.title -eq $null -or $body.message -eq $null){
                # pass null to respond a bad request
                $body = $null
            }
            else{
                # show payload
                $body
            }
        }

        # if u decide to use auth u need this for receiving payloads
        if($context.User.Identity.IsAuthenticated){
            $identity = $context.User.Identity
            # debug show passwords BAD
            $identity.Name
            $identity.Password
            ‎# TODO loop into users and allow
            ‎# TODO encrypt users passwords
        }
    }

    if ($request.RawUrl -eq '/end') {
        # stop the server
        write-warning "Listener stopped by request /end"
        break
    }
    else {
        # required for root url://site:port
        if ($request.RawUrl -eq "/") {
            if($request.HttpMethod -ne "GET"){
                $message = "404. Not allowed to $($request.HttpMethod) here. Try /help."
                $Response.statuscode = 404
                $response.ContentType = 'text/plain'
            }
            else{
                $message = "200. Welcome to this simple API. Try /help."
                $Response.statuscode = 200
                $response.ContentType = 'text/plain'
            }
        }
        elseif ($requestvars.Count -gt "2" -and $requestvars[1] -ne $Null) {
            if($request.HttpMethod -ne "GET"){
                $message = "404. Not allowed to $($request.HttpMethod) here. Try /help."
            }
            else{
                $message = "404. Nothing here. Try /help."
            }
            $Response.statuscode = 404
            $response.ContentType = 'text/plain'
        }
        elseif ($requestvars[1] -eq "help") {
            if($request.HttpMethod -eq "GET"){
                $actions = (
                    'ECHO: /echo?key=value'
                )
                $message = $actions | ConvertTo-Json
                $Response.statuscode = 200
                $response.ContentType = 'application/json'
                write-output "Response OK valid for HELP."
            }
            else{
                $message = "404. Not allowed to $($request.HttpMethod) here. Try /help."
                $Response.statuscode = 404
                $response.ContentType = 'text/plain'
            }
        }
        elseif ($requestvars[1] -match "echo?") {
            $var_key = [string]$request.QueryString
            $var_value = [string]$request.RawUrl -split "="
            # responses
            if($var_key -ne $Null -and $var_value[1] -ne $Null -and $body -ne $null){
                if($request.HttpMethod -ne "GET"){
                    $action = .\response-echo.ps1 -key $var_key -value $var_value[1] -type $request.HttpMethod -body $body
                }
                else{
                    $action = .\response-echo.ps1 -key $var_key -value $var_value[1]
                }
                $message = $action | ConvertTo-Json
                $Response.statuscode = 200
                $response.ContentType = 'application/json'
                write-output "Response OK valid for ECHO."
            }
            else{
                $message = "400. Bad Request. Try /help."
                $Response.statuscode = 400
                $response.ContentType = 'text/plain'
                write-warning "Bad request on $($request.RawUrl)."
            }
        }
        else {
            # If no matching subdirectory/route is found generate a 404 message
            $message = "404. This is not the page you're looking for. Try /help."
            $Response.statuscode = 404
            $response.ContentType = 'text/plain'
            write-warning "Invalid url attempt on $($request.RawUrl)."
        }
    }
    write-warning "$($request.HttpMethod) attempt on $($request.RawUrl)"

    # process output...
    # Convert the message response to UTF8 bytes
    [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
    # Set length of response
    $response.ContentLength64 = $buffer.length
    # Write response out and close request
    $output = $response.OutputStream
    $output.Write($buffer, 0, $buffer.length)
    $output.Close()
    Write-output "TimeTaken $($StopWatch.Elapsed.Milliseconds) ms."
    $StopWatch.Stop()
    # Loop starts again...
}
# Terminate the listener
$listener.Stop()