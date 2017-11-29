#############################################################################################################################################
###~ Last Logon Notify for Orchestrator #####################################################################################################
#
#~ Brian Tancredi
#~ Created: 2017-11-29
#~ Modified: 2017-11-29
#
#~ Notes:
#~ Adjust $SamAccountName and $server to your environment.
#~ Tie alert $true to email action in orchestrator and notify admin if service account has been used.
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assigning Variables  ###################################################################################################################
#############################################################################################################################################

Import-Module ActiveDirectory

$SamAccountName = "Administrator" #~***Call for Initalized Name Field Here between quotes***
$server = "dc.com" #~search domain here

$properties = "LastLogon"#,"LastLogonTimeStamp"
$mostRecent = (Get-Date).AddYears(-300) #~ 300 yrs ago is starting point
$yesterday = (Get-Date).AddDays(-1)
$today = (Get-Date)
$DCs =  @(Get-ADDomainController -Filter * -Server $server| Select-Object HostName | ForEach-Object {$_.HostName})

#############################################################################################################################################
###~ Determine Last Logon  ##################################################################################################################
#############################################################################################################################################

Foreach($DC in $DCs){
    $ADUser = Get-ADUser -Identity $SamAccountName -Properties $Properties -Server $DC -ErrorAction Stop
    $lastLogon = $ADUser.$Properties
    
    #~ If last logon present determine which server reports most recent
    If (!([string]::IsNullOrEmpty($lastLogon))){
        $lastLogon_DateTime = [datetime]::FromFileTime($lastLogon)
         #Write-Host "Last Logon: $lastLogon_DateTime ($dc)"

        #~ Determine mostRecent between DCs
        If ((Get-Date $lastLogon_DateTime) -gt (Get-Date $mostRecent)){
            $mostRecent = (Get-Date $lastLogon_DateTime)
        }
    }
}
#Write-Host "Most Recent: $mostRecent" -ForegroundColor Yellow

#~ Determine if most recent was used in last 24 HRS
If((Get-Date $mostRecent) -gt (Get-Date $yesterday)){
    #Write-Host "Account used in last 24 Hours: $mostRecent" -ForegroundColor Red
    $alert = $true
}
Else{
    $alert = $false
}

#############################################################################################################################################
###~ END ####################################################################################################################################
#############################################################################################################################################