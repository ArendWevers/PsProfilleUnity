
Function Connect-Api {
    Param(
        [parameter(Mandatory = $true)]
        $Server,
        [int]$Port = 8000,
        [parameter(ParameterSetName = "Credentials", Mandatory = $true)]
        [System.Management.Automation.PSCredential]$Credentials,
        [parameter(ParameterSetName = "UsernamePassword", Mandatory = $true)]
        [string]$Username,
        [parameter(ParameterSetName = "UsernamePassword", Mandatory = $true)]
        [string]$Password
    )

    [System.UriBuilder]$uriBuilder = New-Object System.UriBuilder
    $uriBuilder.Scheme = "https"
    $uriBuilder.Host = $Server
    $uriBuilder.Port = $Port
    $ServerURL = $uriBuilder.ToString()

    if ($PSCmdlet.ParameterSetName -eq "Credentials") {
        $Body = "username={0}&password={1}" -f $Credentials.UserName, $Credentials.GetNetworkCredential().Password
    }
    elseif ($PSCmdlet.ParameterSetName -eq "UsernamePassword") {
        $Body = "username={0}&password={1}" -f $Username, $Password
    }

    $script:ApiUrl = $ServerURL
    Invoke-RestMethod -Uri "$($ServerURL)/authenticate" -Body $Body -Method Post -SessionVariable session
    $script:ApiSession = $session
}

function Invoke-Api {
    Param(
        [parameter(Mandatory = $true)]    
        [string]$Path,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method = "Get",
        $Body,
        $ContentType
    )
    $Params = @{
        Method     = $Method
        Uri        = "{0}/api/{1}" -f $script:ApiUrl, $Path
        WebSession = $script:ApiSession
    }
    if ($PSBoundParameters.ContainsKey("Body")) { $Params["Body"] = $Body }
    if ($PSBoundParameters.ContainsKey("ContentType")) { $Params["ContentType"] = $ContentType }

    Invoke-RestMethod @Params
}

Function Get-Filter {
    Param(
        $Id
    )
    if (-not $script:ApiSession) {
        throw "You must connect to the API first using Connect-Api."
    }

    $path = "Filter"
    if ($PSBoundParameters.ContainsKey("Id")) {
        $path = "$path/$id"
        (Invoke-Api -Path $path).tag
    }
    else {
        (Invoke-Api -Path $path).tag.rows
    }
}

Function Add-Filter {
    Param(
        $Filter
    )
    if (-not $script:ApiSession) {
        throw "You must connect to the API first using Connect-Api."
    }

    Invoke-Api -Path Filter -Method Post -Body ($Filter | ConvertTo-Json) -ContentType "application/json"
}

function Update-Filter {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject
    )
    if (-not $script:ApiSession) {
        throw "You must connect to the API first using Connect-Api."
    }

}

function Remove-Filter {
    param (
        [parameter(Mandatory = $true, ParameterSetName = "Id")]
        [string]$Id,
        [parameter(Mandatory = $true , ValueFromPipeline = $true, ParameterSetName = "InputObject")]
        $inputObject
    )
    if (-not $script:ApiSession) {
        throw "You must connect to the API first using Connect-Api."
    }
    
    if ($PSCmdlet.ParameterSetName -eq "Id") {
        $path = "Filter/$Id"
    }
    elseif ($PSCmdlet.ParameterSetName -eq "InputObject") {
        $path = "Filter/$($inputObject.Id)"
    }
    
    Invoke-Api -Path $path -Method Delete
}

Function New-FilterRule {
    param (
        [Parameter(Mandatory = $true)]            
        [FilterRuleType]$FilterType,
        [Parameter(Mandatory = $true)]    
        [FilterRuleOperator]$FilterOperator,
        [Parameter(Mandatory = $true)]
        [string]$FilterValue
    )

    $Rule = [FilterRule]::new($FilterType, $FilterOperator, $FilterValue)
    return $Rule
}

Function New-Filter {
    Param(
        [string]$Name,
        [string]$Comments,
        [FilterRule[]]$Rules,
        [FilterMachineClasses]$MachineClasses = 62,
        [FilterOperatingSystems]$OperatingSystems = 262080,
        [FilterSystemEvents]$SystemEvents = 3,
        [FilterConnnections]$Connections = 1020,
        [FilterRuleAggregate]$Aggregate = "And"
    )
}
