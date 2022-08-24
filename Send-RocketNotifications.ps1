#Read parametres from SCOM
param($AlertName,$AlertDescription,$Severity,$DisplayName,$ResolutionState)

$Send = $True

#Convert importance to text
If ($Severity -eq "2") {$SeverityText = "Critical"}
If ($Severity -eq "1") {$SeverityText = "Warning"}
If ($Severity -eq "0") {$SeverityText = "Informational"}

#Create the pretext with variables.
[string]$Pretext = "$ResolutionState "+"*"+"$SeverityText"+"*"+" Alert"

#Webhook link
$Weblink = "*you_webhook*"

#Create the message with the alert data.
$FallBack = "$Pretext "+"'"+"$AlertName "+"on $DisplayName"+"'"

#Filtering unwanted messages
if ($Pretext -Like "*Aknowledged*") { $Send = $False }
if ($AlertDescription -Like "*Available DNS servers threshold*") { $Send = $False }
if ($AlertDescription -Like "*DPM agents on some of the protected servers are not reachable because of communication error*") { $Send = $False }
if ($AlertName -Like "*Server pending restart detected*") { $AlertName = "Server pending restart detected" ; $AlertDescription = "OS on $DisplayName is pending restart"}

#Message color changing
if ($Pretext -Like "*Informational*") { $Color = '#AAAAAA' ; $IconEmoji = ":information_source:" }
if ($Pretext -Like "*Critical*") { $Color = '#FF0000' ; $IconEmoji = ":red_circle:" }
if ($Pretext -Like "*Warning*") { $Color = '#FFC300' ; $IconEmoji = ":warning:" }
if ($Pretext -Like "*Closed*") { $Color = '#DCDCDC' ; $IconEmoji = ":speech_balloon:" }

$AlertDescription = $AlertDescription.Replace("\n","`n")

#Sending a message with Cyrillic support
$array = @('{"alias":"Scom","text":"', $Pretext, '","attachments":[{"title": "', $AlertName,'","title_link": "*you_link*","text": "', $AlertDescription,'","color": "', $Color,'"}]}')
$array -join ' '

#Sending message
if ($Send)
	{
    Invoke-WebRequest -Uri $WebLink -Method POST -Body $array -ContentType "application/json;charset=utf-8"
	}
