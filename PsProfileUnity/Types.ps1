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

enum ShortcutType {
    ShellShortcut = 0
    WebLink = 1
    PinnedItem = 2
}

enum ShortcutAction {
    Create = 0
    Update = 1
    DeleteAll = 2
    DeleteAllProU = 3
}

enum ShortcutLocation {
    UserDesktop = 0
    UserFavorites = 1
    UserStartMenu = 2
    UserProgramsGroup = 3
    UserStartupGroup = 4
    UserSendTo = 5
    UserQuickLaunchBar = 6
    UserLinks = 7
    AllUsersDesktop = 9
    AllUsersStartMenu = 10
}

enum ShortcutWindowStyle {
    Normal = 0
    Maximized = 1
    Minimized = 2
}

enum ShortcutWindowPinnedLocation {
    StartMenu = 0
    Taskbar = 1
    QuickAccess = 2
}

Class Shortcut {
    [ShortcutAction]$Action
    [string]$Arguments
    [string]$Icon
    [int]$IconIndex
    [ShortcutLocation]$Location
    [string]$Name
    [bool]$Overwrite
    [ShortcutWindowPinnedLocation]$PinnedLocation
    [bool]$ProcessActionPostLogin
    [string]$StartIn
    [string]$Target
    [ShortcutType]$Type
    [ShortcutWindowStyle]$WindowStyle
    $Filter
    [string]$FilterId
    [string]$Description
    [bool]$Disabled
    [int]$Sequence

    Shortcut([ShortcutAction]$action, [string]$arguments, [string]$icon, [int]$iconIndex, [ShortcutLocation]$location, [string]$name, [bool]$overwrite, [ShortcutWindowPinnedLocation]$pinnedLocation, [bool]$processActionPostLogin, [string]$startIn, [string]$target, [ShortcutType]$type, [ShortcutWindowStyle]$windowStyle, $filter = $null, [string]$filterId, [string]$description, [bool]$disabled, [int]$sequence) {
        $this.Action = $action
        $this.Arguments = $arguments
        $this.Icon = $icon
        $this.IconIndex = $iconIndex
        $this.Location = $location
        $this.Name = $name
        $this.Overwrite = $overwrite
        $this.PinnedLocation = $pinnedLocation
        $this.ProcessActionPostLogin = $processActionPostLogin
        $this.StartIn = $startIn
        $this.Target = $target
        $this.Type = $type
        $this.WindowStyle = $windowStyle
        $this.Filter = $filter
        $this.FilterId = $filterId
        $this.Description = $description
        $this.Disabled = $disabled
        $this.Sequence = $sequence
    }
}
