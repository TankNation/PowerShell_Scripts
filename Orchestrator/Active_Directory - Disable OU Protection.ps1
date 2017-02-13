#############################################################################################################################################
###~ Active Directory - Disable OU Protection ###############################################################################################
#
#~ Brian Tancredi
#~ Created: 2017-02-13
#~ Modified: 2017-02-13
#
#~ References:
#
#############################################################################################################################################
 
#############################################################################################################################################
###~ Assigning Variables  ###################################################################################################################
#############################################################################################################################################

Import-Module ActiveDirectory

$named_OU = #Input Distingushed Name from Initalize Data
$target_OU = Get-ADOrganizationalUnit -Identity $named_OU -Properties ProtectedFromAccidentalDeletion #| where {$_.ProtectedFromAccidentalDeletion -eq $true}

#~ Publish for display in outgoing Email
$email_1 = $target_OU | Select-Object @{Name="OU Name";Expression={$_.Name}},@{Name="OU DN";Expression={$_.DistinguishedName}},@{Name="OU Protected";Expression={$_.ProtectedFromAccidentalDeletion}} | FL | Out-String

#############################################################################################################################################
###~ Disable ProtectFromAccidentalDeletion on targeted OU ###################################################################################
#############################################################################################################################################

If ($target_OU.ProtectedFromAccidentalDeletion -eq $true){
    $target_OU | Set-ADObject -ProtectedFromAccidentalDeletion $false
    $fail = 0
}
Else{
    $fail = 1
}#~ Publish $fail for Email Link flow

#~ Gather attributes following apply
$target_New = Get-ADOrganizationalUnit -Identity $named_OU -Properties ProtectedFromAccidentalDeletion #| where {$_.ProtectedFromAccidentalDeletion -eq $false}

#~ Publish for display in outgoing Email
$email_2 =  $target_New | Select-Object @{Name="OU Name";Expression={$_.Name}},@{Name="OU DN";Expression={$_.DistinguishedName}},@{Name="OU Protected";Expression={$_.ProtectedFromAccidentalDeletion}} | FL | Out-String

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################