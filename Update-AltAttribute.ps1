# This is an example how to update a alt attribute for the images.
# Based on the configured mapping on sitecore side or on contenthub side, 
# you may need to change the code (Attributes)
# This code is for sake of education, it can easily be refactored to the more optimal code

# the function is in the Get-CHAccessToken.ps1
Import-Function Get-CHAccessToken

function Get-CHDamUri {
    $connection = $env:Sitecore_ConnectionStrings_DAM_dot_ContentHub.split(';')
    if (-not $connection) {
        throw "Contenthub connection string is not configured."
    }
    return ($connection | Where-Object { $_.contains('URI=') } | Select-Object -First 1).split('=')[1]
}

function Get-CHAltByEntityId {
    param (
        $entityId,
        $accessToken
    )

    $authHeaders = @{
        'Content-Type'  = 'application\json'
        'Authorization' = "Bearer $accessToken"
    }
    
    $URL = "$(Get-CHDamUri)/api/entities/$entityId/"
    try {
        $depResponse = Invoke-WebRequest -Headers $authHeaders -Uri $URL -UseBasicParsing -ErrorAction Ignore
        $contents = ($depResponse.Content | ConvertFrom-Json)
        
        return $contents.properties.'[YOUR ALT ATTRIBUTE ON Contenthub]'
    }
    catch {
        # Add Logging if ncecessary
        # In the case the image does not exists and you will get 404
    }

    return $null
}

function Get-CHAltByDamId {
    param (
        $damId,
        $accessToken
    )

    $authHeaders = @{
        'Content-Type'  = 'application\json'
        'Authorization' = "Bearer $accessToken"
    }
    
    $URL = "$(Get-CHDamUri)/api/entities/query?query=identifier=='$damId'"
    try {
        $depResponse = Invoke-WebRequest -Headers $authHeaders -Uri $URL -UseBasicParsing -ErrorAction Ignore
        $contents = ($depResponse.Content | ConvertFrom-Json)
        if ($contents.items.Length) {
            return $contents.items[0].properties.'[YOUR ALT ATTRIBUTE ON Contenthub]'
        }
    }
    catch {
        # Add Logging if ncecessary
        # In the case the image does not exists and you will get 404
    }
    
    return $null
}

function Update-CHImageFieldAlt {
    param (
        $imageField,
        $accessToken
    )
    [Sitecore.Data.Fields.ImageField]$field = $imageField
    # reading alt attribute
    $sId = $field.GetAttribute("stylelabs-content-id")
    $damId = $field.GetAttribute("dam-id")        
    $alt = $field.GetAttribute("alt")
    if (-not $sId -and -not $damId) {
        # Log Error the item is invalid
        continue
    }
    
    $newAlt = $null
    if ($damId) {
        $newAlt = Get-CHAltByDamId -damId $damId -accessToken $accessToken
    }
    elseif ($sid) {
        $newAlt = Get-CHAltByEntityId -entityId $sId -accessToken $accessToken
    }

    if (-not $newAlt) {
        # Log Error if necessary
        continue
    }

    if ($newAlt -eq $alt) {
        # No change is necessary
        continue
    }
    $imageField.Item.Editing.BeginEdit() | Out-Null
    $field.SetAttribute("alt", $newAlt)
    $imageField.Item.Editing.EndEdit() | Out-Null
}

# Example:
#$item = get-item -path "master:" -id "{65606EA5-B5A3-4835-B6C4-D9754C8AE6F4}" -language "en"
#$accessToken = Get-CHAccessToken

#Update-CHImageFieldAlt  -imageField $item.Fields["image"] -accessToken $accessToken
