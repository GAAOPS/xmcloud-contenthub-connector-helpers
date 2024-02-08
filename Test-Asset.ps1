function Test-GeneralLinkField {
    param (
        $field
    )

    [Sitecore.Data.Fields.LinkField]$field = $field
    $url = $field.getattribute("url")
    try {
        Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Ignore | Out-Null
        return $true
    }
    catch {
        # Add Logging if ncecessary
    }
    
    return $false
}

function Test-ImageField {
    param (
        $field
    )

    [Sitecore.Data.Fields.ImageField]$field = $field
    $url = $field.getattribute("src")
    try {
        Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Ignore | Out-Null
        return $true
    }
    catch {
        # Add Logging if ncecessary
    }
    
    return $false
}

# Examples:
#$item = get-item -path "master:" -id "{AE35A1A6-0569-488E-80E8-9353B708BDCF}" -language "en"

#Test-GeneralLinkField  -field $item.Fields["downloadlink"]

#$item = get-item -path "master:" -id "{6EC98578-4580-42C7-9DD3-1C49BC8A98AE}" -language "en"

#Test-ImageField  -field $item.Fields["image"]