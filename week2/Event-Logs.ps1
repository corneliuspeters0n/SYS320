function eventLog ($days){

$loginouts = Get-EventLog system -Source Microsoft-Windows-Winlogon -after (Get-Date).AddDays(-$days)

$loginoutstable = @() 
for ($i = 0; $i -lt $loginouts.Count; $i++){

$event = ""

if ($loginouts[$i].InstanceId -eq 7001) {$event = "Logon"}
if ($loginouts[$i].InstanceId -eq 7002) {$event = "Logoff"}

$user = $loginouts[$i].ReplacementStrings[1]
$objSID = New-Object System.Security.Principal.SecurityIdentifier($user)
$newuser = $objSID.Translate([System.Security.Principal.NTAccount])

$loginoutstable += [pscustomobject] @{"Time" = $loginouts[$i].TimeGenerated; `
                                     "Id" = $loginouts[$i].EventID; `
                                     "Event" = $event;`
                                     "User" = $newuser.Value;
                                     }
}
return $loginoutstable
}

function eventStartShut ($days){

$StartStop = Get-EventLog system  -after (Get-Date).AddDays(-$days) | Where-Object {($_.EventId -eq 6006) -or ($_.EventID -eq 6005)}

$StartStoptable = @() 
for ($i = 0; $i -lt $StartStop.Count; $i++){

$event = ""

if ($StartStop[$i].EventID -eq 6005) {$event = "StartUp"}
if ($StartStop[$i].EventID -eq 6006) {$event = "ShutDown"}


$StartStoptable += [pscustomobject] @{"Time" = $StartStop[$i].TimeGenerated; `
                                     "Id" = $StartStop[$i].EventID; `
                                     "Event" = $event;`
                                     "User" = "SYSTEM";
                                     }
}
return $StartStoptable
}
eventLog 30
eventStartShut 30