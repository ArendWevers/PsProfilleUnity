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

Function Invoke-Api {
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

Function Update-Filter {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $InputObject
    )

    Invoke-Api -Path "Filter" -Method Post -Body ($InputObject | ConvertTo-Json) -ContentType "application/json"
}

Function Remove-Filter {
    param (
        [parameter(Mandatory = $true, ParameterSetName = "Id")]
        [string]$Id,
        [parameter(Mandatory = $true , ValueFromPipeline = $true, ParameterSetName = "InputObject")]
        $inputObject
    )
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "Id") {
            $path = "Filter/$Id"
        }
        elseif ($PSCmdlet.ParameterSetName -eq "InputObject") {
            $path = "Filter/$($inputObject.Id)"
        }
    
        Invoke-Api -Path $path -Method Delete
    }
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
        [FilterRuleAggregate]$RuleAggregate = "And"
    )

    $Filter = [pscustomobject][ordered]@{
        Name             = $Name
        Comments         = $Comments
        FilterRules      = $Rules
        MachineClasses   = $MachineClasses
        OperatingSystems = $OperatingSystems
        SystemEvents     = $SystemEvents
        Connections      = $Connections
        RuleAggregate    = $RuleAggregate
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
    
Function Add-ApplicationRestriction {
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


Function Get-Shortcuts {
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$Configuration
    )
    $Configuration.Shortcuts | ForEach-Object {
        [Shortcut]::new($_.Action, $_.Arguments, $_.Icon, $_.IconIndex, $_.Location, $_.Name, $_.Overwrite, $_.PinnedLocation, $_.ProcessActionPostLogin, $_.StartIn, $_.Target, $_.Type, $_.WindowStyle, $_.Filter, $_.FilterId, $_.Description, $_.Disabled, $_.Sequence)
    }
}

Function New-Shortcut {
    param (
        [parameter(Mandatory = $true)]
        [ShortcutType]$Type,
        [parameter(Mandatory = $true)]
        [ShortcutAction]$Action,
        [parameter(Mandatory = $true)]
        [string]$Target,
        [ShortcutLocation]$ShortcutLocation = [ShortcutLocation]::UserDesktop,
        [string]$Name,
        [ShortcutWindowStyle]$WindowStyle = [ShortcutWindowStyle]::Normal,
        [string]$Arguments = "",
        [string]$Icon = "", 
        [int]$IconIndex = 0,
        [ShortcutWindowPinnedLocation]$PinnedLocation = [ShortcutWindowPinnedLocation]::StartMenu,
        [bool]$Overwrite = $false,
        [bool]$ProcessActionPostLogin = $false,
        [string]$StartIn = "",
        [string]$Filter = $null,
        [string]$FilterId = $null,
        [string]$Description = "",
        [bool]$Disabled = $false,
        [int]$Sequence = 0
    )

    if ($Type -in ([ShortcutType]::ShellShortcut, [ShortcutType]::WebLink) -and -not $Name) {
        throw "Name is required for ShellShortcut and WebLink types."
    }
    if ($Type -eq [ShortcutType]::WebLink) {
        if ($Arguments) {
            throw "Arguments are not applicable for WebLink type."
        }
        if ($StartIn) {
            throw "StartIn is not applicable for WebLink type."
        }
    }
    if ($Type -eq [ShortcutType]::PinnedItem) {
        if ($Name) {
            throw "Name is not required for PinnedItem type."
        }
        if ($Arguments) {
            throw "Arguments are not applicable for PinnedItem type."
        }
        if ($StartIn) {
            throw "StartIn is not applicable for PinnedItem type."
        }
        if ($Icon) {
            throw "Icon is not applicable for PinnedItem type."
        }
        $ProcessActionPostLogin = $true # Pinned items are always processed post-login
    }

    $Shortcut = [Shortcut]::new($Action, $Arguments, $Icon, $IconIndex, $ShortcutLocation, $Name, $Overwrite, $PinnedLocation, $ProcessActionPostLogin, $StartIn, $Target, $Type, $WindowStyle, $Filter, $FilterId, $Description, $Disabled, $Sequence)
    return $Shortcut
}
    
Function Add-Shortcut {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$Configuration,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Shortcut]$Shortcut,
        [int]$Sequence = 0
    )

    if ($Shortcut.Sequence -le 0) {
        $Shortcut.Sequence = ($Configuration.Shortcuts | Measure-Object -Property Sequence -Maximum).Maximum + 1
    }
    
    $Configuration.Shortcuts += $Shortcut
}

Function Get-Portability  {
    Param(
        $Id
    )

    $path = "portability"
    if ($PSBoundParameters.ContainsKey("Id")) {
        $path = "$path/$id"
        $Result = Invoke-Api -Path $path
        $Result.tag
        
        # [Portability]::new(
        #     $Result.tag.Name,
        #     $Result.tag.Comments,
        #     $Result.tag.RegistryRules,
        #     $Result.tag.FilesystemRules,
        #     $Result.tag.Id,
        #     $Result.tag.Disabled,
        #     $Result.tag.DateCreated,
        #     $Result.tag.DateModified
        # ) # todo
    }
    else {
        (Invoke-Api -Path $path).tag.rows
    }
}

Function Update-Portability {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Portability
    )

    Invoke-Api -Path "portability" -Method Post -Body ($Portability | ConvertTo-Json -Depth 10) -ContentType "application/json"
}

Function Remove-Portability {
    param (
        [parameter(Mandatory = $true, ParameterSetName = "Id")]
        [string]$Id,
        [parameter(Mandatory = $true , ValueFromPipeline = $true, ParameterSetName = "InputObject")]
        $inputObject
    )
    
    process {
        if ($PSCmdlet.ParameterSetName -eq "Id") {
            $path = "Portability/$Id"
        }
        elseif ($PSCmdlet.ParameterSetName -eq "InputObject") {
            $path = "Portability/$($inputObject.Id)"
        }
    
        Invoke-Api -Path $path -Method Delete
    }
}

Function New-PortabilityRegistryRule {
    param (
        [Parameter(Mandatory = $true)]            
        [PortabilityOperation]$Operation,
        [Parameter(Mandatory = $true)]    
        [PortabilityScope]$Scope,
        [Parameter(Mandatory = $true)]
        [PortabilityHive]$Hive,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $Rule = [PortabilityRegistryRule]::new($Operation, $Scope, $Hive, $Path)
    return $Rule
}

Function New-PortabilityFilesystemRule {
    param (
        [Parameter(Mandatory = $true)]            
        [PortabilityOperation]$Operation,
        [Parameter(Mandatory = $true)]    
        [PortabilityFolder]$Folder,
        [string]$Path = ""
    )
    $Rule = [PortabilityFilesystemRule]::new($Operation, $Folder, $Path)
    return $Rule
}

Function New-portabilityRule {
    Param(
        [parameter(Mandatory = $true)]
        [string]$Name,
        [string]$Comments,
        [PortabilityRegistryRule[]]$RegistryRules,
        [PortabilityFilesystemRule[]]$FilesystemRules,
        [bool]$Disabled = $false
    )

    $Portability = [Portability]::new(
        $Name,
        $Comments,
        $RegistryRules,
        $FilesystemRules,
        "", # Blank ID for new portability rules
        $Disabled
    )
    return $Portability
}
