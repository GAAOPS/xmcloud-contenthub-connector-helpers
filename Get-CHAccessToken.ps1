# Return Access Token for Contenthub based on the connection string in xmcloud
function Get-CHAccessToken {
    $connection = $env:Sitecore_ConnectionStrings_DAM_dot_ContentHub.split(';')
    if (-not $connection) {
        throw "Contenthub connection string is not configured."
    }
    $clientID = ($connection | Where-Object { $_.contains('ClientId=') } | Select-Object -First 1).split('=')[1]
    $clientSecret = ($connection | Where-Object { $_.contains('ClientSecret=') } | Select-Object -First 1).split('=')[1]
    $userName = ($connection | Where-Object { $_.contains('UserName=') } | Select-Object -First 1).split('=')[1]
    $password = ($connection | Where-Object { $_.contains('Password=') } | Select-Object -First 1).split('=')[1]
    $uri = ($connection | Where-Object { $_.contains('URI=') } | Select-Object -First 1).split('=')[1]

    $body = @{
        grant_type = 'password'
        client_id        = $clientID
        client_secret    = $clientSecret
        username         = $userName
        password         = $password
    }
    $contentType = 'application/x-www-form-urlencoded' 
    $accessTokenRequest = Invoke-WebRequest -Method Post -Uri "$uri/oauth/token" -body $body -ContentType $contentType -UseBasicParsing
    $token = ($accessTokenRequest.Content | ConvertFrom-Json).access_token

    return $token
}