Enum FilterRuleType {
    ADUserGroupMembership = 0
    ADUserPrimaryGroup = 1 # todo
    Username = 2
    IpAddress = 3
    Hostname = 4
    TSClientName = 11
    TSSessionName = 12
    RegisstryKeyValue = 26
    RegisstryKeyExists = 27
    File = 28
    Directory = 29
    RegistryValueExists = 30
    ServiceExists = 33
    ServiceRunning = 34
    MachineGroupMember = 35
    ProcessRunning = 36
    LDAPAttribute = 38
}

enum FilterRuleOperator {
    Is = 0
    IsNot = 1
    Contains = 2
    NotContains = 3
    StartsWith = 4
    EndsWith = 5
    Range = 6
}

[Flags()]enum FilterMachineClasses {
    Desktop = 16
    Laptop = 32
    TerminalServer = 2
    MemberServer = 4
    DomainController = 8
}

[Flags()]enum FilterOperatingSystems {
    Windows8 = 128
    Windows8_1 = 256
    Windows2012 = 64
    Windows2012R2 = 512
    Windows10 = 1024
    Windows10_IOT = 32768
    Windows11 = 8192
    Windows11_IOT = 65536
    Windows2016 = 2048
    Windows2019 = 4096
    Windows2022 = 16384
    Windows2025 = 131072
}

[flags()]enum FilterSystemEvents {
    LogonLogoff = 1
    TriggerPoints = 2
}

[flags()]enum FilterConnnections {
    RDPSession = 4
    ICASession = 8
    PCoIPSession = 16
    ConsoleSession = 32
    VMwareBlast = 64
    AmazonAppStream = 128
    AmazonWSP = 512
    DizzionFrame = 256
}

enum FilterRuleAggregate{
    And = 0
    Or = 1
}

class FilterRule {
    [FilterRuleType]$ConditionType
    [FilterRuleOperator]$MatchType
    [string]$Value

    FilterRule([FilterRuleType]$type, [FilterRuleOperator]$operator, [string]$value) {
        $this.ConditionType = $type
        $this.MatchType = $operator
        $this.Value = $value
    }
}

enum ApplicationRestrictionAction {
    Allow = 0
    Deny = 1
}

enum ApplicationRestrictionMatchType {
    Contains = 0
    Equals = 1
    Hash = 2
    StartsWith = 3
    EndsWith = 4
    Signed = 5
}

class ApplicationRestriction {
    [ApplicationRestrictionAction]$Action
    [ApplicationRestrictionMatchType]$Match
    [string]$Value
    [bool]$HideApplication
    [string]$ProgramsAndFeaturesName
    $Filter
    [string]$FilterId
    [string]$Description
    [bool]$Disabled
    [int]$Sequence

    ApplicationRestriction([ApplicationRestrictionAction]$action, [ApplicationRestrictionMatchType]$match, [string]$value, [bool]$hideApplication = $false, [string]$programsAndFeaturesName = "", [string]$filterId = "", [string]$description = "", [bool]$disabled = $false, [int]$sequence = 0) {
        $this.Action = $action
        $this.Match = $match
        $this.Value = $value
        $this.HideApplication = $hideApplication
        $this.ProgramsAndFeaturesName = $programsAndFeaturesName
        $this.FilterId = $filterId
        $this.Description = $description
        $this.Disabled = $disabled
        $this.Sequence = $sequence
    }
}
