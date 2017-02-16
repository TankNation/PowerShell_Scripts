﻿#############################################################################################################################################
###~ Domain Users Compliance Check #########################################################################################################
#
#~ Brian Tancredi
#~ Created: 2017-02-16
#~ Modified: 2017-02-16
#
#~ References:
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assigning Variables and Functions ######################################################################################################
#############################################################################################################################################

$compliance = $true
$local_Groups = @(
    "Administrators",
    "Users"
)
$domain_Groups = @(
    "Domain1\Domain Users",
    "Domain2\Domain Users",
    "Domain3\Domain Users"
)

function compliance_Check{
    $present = 0
    foreach ($local_Group in $local_Groups){
        $member_List = net localgroup $local_Group | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4
        foreach ($domain_Group in $domain_Groups){
            If ($member_List -contains $domain_Group){$present = $present +1}
        }
    }
    If ($present -ge 1){$Script:compliance = $false}
}#~ Function checks $local_Groups for presence of $domain_Groups

function compliance_Report{
    Write-Host $compliance
}#~ Function displays Workstation Compliance

#############################################################################################################################################
###~ Run Checks against $local_Groups #######################################################################################################
#############################################################################################################################################

#~ Checking $local_Groups for presence of $domain_Groups
compliance_Check
#~ Display workstation compliance (True = Compliant / False = Non-Compliant)
compliance_Report

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################