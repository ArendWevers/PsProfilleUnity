Enum FilterRuleType {
    ADUserGroupMembership = 0
    ADUserPrimaryGroup = 1 # todo
    RegisstryKeyValue = 26
    RegisstryKeyExists = 27
    File = 28
    Directory = 29
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
}

[Flags()]enum FilterOperatingSystems {
    Windows8 = 0 # todo
    Windows8_1 = 1 # todo
    Windows2012 = 2 # todo
    Windows2012R2 = 3 # todo
    Windows10 = 8 # 107520  # 33792
    Windows10_IOT = 16 # 107520  # 33792
    Windows11 = 32 # 107520  # 73728
    Windows11_IOT = 64 # 107520  # 73728
    Windows2016 = 2048
    Windows2019 = 4096
    Windows2022 = 16384
    Windows2025 = 131072
}

[flags()]enum FilterSystemEvents {
    LogonLogoff = 0 # todo
    TriggerPoints = 1 # todo
}

[flags()]enum FilterConnnections {
    RDPSession # todo
    ICASession # todo
    PCoIPSession # todo
    ConsoleSession # todo
    VMwareBlast # todo
    AmazonAppStream # todo
    AmazonWSP # todo
    DizzionFrame # todo
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
