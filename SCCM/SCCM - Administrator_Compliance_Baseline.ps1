#############################################################################################################################################
###~ Administrator Compliance Check - SCCM Baseline Script ##################################################################################
#
#~ Brian Tancredi
#~ Created: 2017-01-09
#~ Modified: 2017-01-27
#
#~ References:
#~ https://kareembehery.wordpress.com/2016/04/04/dcm-in-sccm-2012-members-in-local-admin-group-compliance/
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assigning Variables and Functions ######################################################################################################
#############################################################################################################################################

$adminusers = $true
$local_Group = "Administrators"
$ok_Admins = @(
"administrator",
"Domain\Domain Admins"
)#~ Acceptable Administrators
$local_Admins = net localgroup $local_Group | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4
#$useraffinity = gwmi -Namespace root\ccm\policy\machine -Class ccm_useraffinity

function NonCompliant_No_Admin{
    $present = 0
    foreach ($admin in $ok_Admins){
        If ($local_Admins -contains $admin){$present = $present + 1}}
    If ($present -eq 0){$Script:adminusers = $false}
}#~ Function checks the Administrator Group contains an approved member

function NonCompliant_Extra_Admin{
    $extra = 0
    foreach ($admin in $local_Admins){
        If (!($ok_Admins -contains $admin)){$extra = $extra + 1}}
    If ($extra -ge 1){$Script:adminusers = $false}
}#~ Function compares the Administrator Group to array of compliant Administrators

function Compliance{
    Write-Host $adminusers
}#~ Function displays Workstation Compliance

#############################################################################################################################################
###~ Run Checks against approved local Administrator list and current local Administrators to determine compliance ##########################
#############################################################################################################################################

#foreach ($useraff in $useraffinity){$ok_Admins += $useraff.ConsoleUser}

#~ Checking that the Administrator Group contains an approved member
NonCompliant_No_Admin
#~ Comparing the Administrator Group against compliant Administrators
NonCompliant_Extra_Admin
#~ Display workstation compliance
Compliance

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
