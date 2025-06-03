
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
    if (-not $script:ApiSession) {
        throw "You must connect to the API first using Connect-Api."
    }

    $Params = @{
        Method     = $Method
        Uri        = "{0}/api/{1}" -f $script:ApiUrl, $Path
        WebSession = $script:ApiSession
    }
    if ($PSBoundParameters.ContainsKey("Body")) { $Params["Body"] = $Body }
    if ($PSBoundParameters.ContainsKey("ContentType")) { $Params["ContentType"] = $ContentType }

    $Result = Invoke-RestMethod @Params
    if ($Result.Type -ne "success") {
        throw $Result.Message
    }
    else {
        $Result
    }

}

Function Get-Filter {
    Param(
        $Id
    )

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

    Invoke-Api -Path Filter -Method Post -Body ($Filter | ConvertTo-Json) -ContentType "application/json"
}

function Update-Filter {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject
    )

    Invoke-Api -Path "Filter" -Method Post -Body ($InputObject | ConvertTo-Json) -ContentType "application/json"
}

function Remove-Filter {
    param (
        [parameter(Mandatory = $true, ParameterSetName = "Id")]
        [string]$Id,
        [parameter(Mandatory = $true , ValueFromPipeline = $true, ParameterSetName = "InputObject")]
        $inputObject
    )
    
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

    $Filter = [pscustomobject][ordered]@{
        Name             = $Name
        Comments         = $Comments
        Rules            = $Rules
        MachineClasses   = $MachineClasses
        OperatingSystems = $OperatingSystems
        SystemEvents     = $SystemEvents
        Connections      = $Connections
        Aggregate        = $Aggregate
    }
    return $Filter
}


Function Get-Configuration {
    Param(
        $Id
    )

    $path = "Configuration"
    if ($PSBoundParameters.ContainsKey("Id")) {
        $path = "$path/$id"
        $Result = Invoke-Api -Path $path
        $Result.tag
    }
    else {
        (Invoke-Api -Path $path).tag.rows
    }
}

Function Update-Configuration {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Configuration
    )

    Invoke-Api -Path "Configuration" -Method Post -Body ($Configuration | ConvertTo-Json -Depth 10) -ContentType "application/json"
}

Function Get-ApplicationRestrictions {
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$Configuration
    )
    $Configuration.ApplicationRestrictions | ForEach-Object {
        [ApplicationRestriction]::new($_.Action, $_.Match, $_.Value, $_.HideApplication, $_.ProgramsAndFeaturesName, $_.FilterId, $_.Description, $_.Disabled, $_.Sequence)
    }
}

Function New-ApplicationRestriction {
    param (
        [parameter(Mandatory = $true)]
        [ApplicationRestrictionAction]$Action,
        [parameter(Mandatory = $true)]
        [ApplicationRestrictionMatchType]$Match,
        [parameter(Mandatory = $true)]
        [string]$Value,
        [bool]$HideApplication = $false,
        [string]$ProgramsAndFeaturesName = "",
        [string]$FilterId = "",
        [string]$Description = "",
        [bool]$Disabled = $false,
        [int]$Sequence = 0
    )

    $Restriction = [ApplicationRestriction]::new($Action, $Match, $Value, $HideApplication, $ProgramsAndFeaturesName, $FilterId, $Description, $Disabled, $Sequence)
    return $Restriction
}
    
function Add-ApplicationRestriction {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$Configuration,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ApplicationRestriction]$Restriction,
        [int]$Sequence = 0
    )

    if ($Restriction.Sequence -le 0) {
        $Restriction.Sequence = ($Configuration.ApplicationRestrictions | Measure-Object -Property Sequence -Maximum).Maximum + 1
    }
    
    $Configuration.ApplicationRestrictions += $Restriction
}
