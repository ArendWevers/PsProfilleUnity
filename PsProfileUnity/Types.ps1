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
    IsNot = 1 # todo
    Contains = 2 # todo
    NotContains = 3 # todo
    StartsWith = 2 # todo
    EndsWith = 3 # todo
    GreaterThan = 4 # todo
    LessThan = 5 # todo
}

[Flags()]enum FilterMachineClasses {
    Desktop = 0 # todo
    Laptop = 1 # todo
    TerminalServer = 2 # todo
    MemberServer = 4 # todo
    DomainController = 8 # todo
    Unknown1 = 16 # todo
    Unknown2 = 32 # todo
}

[Flags()]enum FilterOperatingSystems {
    Windows8 = 1 # todo
    Windows8_1 = 2 # todo
    Windows2012 = 4 # todo
    Windows2012R2 = 8 # todo
    Windows10 = 16 # 107520  # 33792
    Windows10_IOT = 32 # 107520  # 33792
    Windows11 = 64 # 107520  # 73728
    Windows11_IOT = 128 # 107520  # 73728
    Unknown1 = 256 # todo
    Unknown2 = 512 # todo
    Unknown3 = 1024 # todo
    Windows2016 = 2048
    Windows2019 = 4096
    Unknown5 = 8192 # todo
    Windows2022 = 16384
    Unknown6 = 32768 # todo
    Unknown7 = 65536 # todo
    Windows2025 = 131072
}

[flags()]enum FilterSystemEvents {
    LogonLogoff = 1
    TriggerPoints = 2 # todo
}

[flags()]enum FilterConnnections {
    RDPSession = 1 # todo
    ICASession = 2 # todo
    PCoIPSession = 4 # todo
    ConsoleSession = 8 # todo
    VMwareBlast  = 16 # todo
    AmazonAppStream = 32 # todo
    AmazonWSP = 64 # todo
    DizzionFrame = 128 # todo
    Unknown1 = 256 # todo
    Unknown2 = 512 # todo
}

enum FilterRuleAggregate{
    And = 0
    Or = 1 # todo
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
