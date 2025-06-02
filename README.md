# Voorbeelden

### Maak verbinding
```powershell
Connect-Api -Server dc01 -Credentials $Creds`
```

### Filters
#### Lijst
```powershell
Get-Filter
```

#### Een in detail
```powershell
Get-Filter -Id 5bab8d8102b66c03b0ef8e5e
```

#### Maak een filter regel
```powershell
New-FilterRule -FilterType ADUserGroupMembership -FilterOperator Is -FilterValue 'TRAINING\Print Operators'
```

#### Maak een nieuw Filter
```powershell
New-Filter -Name "Beschrijvende naam" -Comments "Extra uitleg van wat of waarom" -Rules (Array van 0-n FilterRules)
```

Machine Classe, OS, en Connectie type is te specificeren
```powershell
New-Filter -MachineClasses Desktop, MemberServer, TerminalServer -OperatingSystems Windows10, Windows11, Windows2019, Windows2022 -Connections RDPSession, ConsoleSession
```

### Application Restrictions
```powershell
#Haal de configuratie op
$Config = Get-PUConfiguration -Id "683984059744981b603d19cd"

#Zie welke applicatie restricties er zijn
$Config | Get-PUApplicationRestrictions

#Maak een nieuwe restrictie aan, en voeg deze toe aan de configuratie
$AppRest = New-PUApplicationRestriction -Action Allow -Match Contains -Value 'Teams.exe'
$Config | Add-PUApplicationRestriction -Restriction $AppRest

#Zie dat de restrictie is toegevoegd
$Config | Get-PUApplicationRestrictions

#Update de configuratie
Update-PUConfiguration -Configuration $Config
```
