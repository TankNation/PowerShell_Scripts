#############################################################################################################################################
###~ Get Inactive AD Users That Have Not Logged In Since $daysInactive ######################################################################
#
#~ Brian Tancredi
#~ Created: 2014-08-26
#~ Modified: 2016-12-08
#
#~ References:
#~ https://gallery.technet.microsoft.com/scriptcenter/Get-Inactive-Computer-in-54feafde
#
###########################################################################################################################################

#############################################################################################################################################
###~ Assign Variables and Functions #########################################################################################################
#############################################################################################################################################

Import-Module ActiveDirectory

#~ Assign Variables
$csvEnabled = "$env:HOMEPATH\Desktop\Inactive_Users_Enabled.csv"
$csvAll = "$env:HOMEPATH\Desktop\Inactive_Users_All.csv"
Write-Host "`nEnter Days Inactive to Search: " -ForegroundColor White -BackgroundColor Black -NoNewline
$daysInactive = Read-Host
$time = (Get-Date).Adddays(-($daysInactive))
  
function getDomain{
    Write-Host "`nGathering List of Inactive AD Users" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "`nEnter Fully Qualified Domain Name: " -ForegroundColor White -BackgroundColor Black -NoNewline
    $domain = Read-Host
}

function getInactiveEnabled{
    Get-ADUser -Filter {LastLogonTimeStamp -lt $time -and enabled -eq $true} -Properties LastLogonTimeStamp | 
    Select-Object @{Name="First Name"; Expression={$_.GivenName}},@{Name="Last Name"; Expression={$_.Surname}},@{Name="Full Name"; Expression={$_.Name}},@{Name="UserName"; Expression={$_.SamAccountName}},Enabled,@{Name="Last Login"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd')}} | 
    Export-Csv $csvEnabled -notypeinformation
} 

function getInactiveAll{
    Get-ADUser -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp | 
    Select-Object @{Name="First Name"; Expression={$_.GivenName}},@{Name="Last Name"; Expression={$_.Surname}},@{Name="Full Name"; Expression={$_.Name}},@{Name="UserName"; Expression={$_.SamAccountName}},Enabled,@{Name="Last Login"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd')}} | 
    Export-Csv $csvAll -notypeinformation
}

#############################################################################################################################################
###~ Search for Inactive Users and Create CSV ###############################################################################################
#############################################################################################################################################

#~ Get Search Domain
#getDomain

#~ Get AD Users with lastLogonTimestamp less than our time and set to enable 
getInactiveEnabled

#~ Get All AD Users with lastLogonTimestamp less than our time
getInactiveAll

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
