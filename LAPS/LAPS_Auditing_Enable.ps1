######################################################################################
###~ LAPS - Enable Audting of Password Reads #########################################
#~ Brian Tancredi
#~ Created: 2016-12-26
#~ Modified: 2016-12-16
#
######################################################################################
 
######################################################################################
###~ Assigning Variables and Enabling Password Auditing on $ou's  ####################
######################################################################################
Import-Module AdmPwd.PS
 
$ouTop = @(
"OU=TopLevel1,DC=domain,DC=name,DC=here",
"OU=TopLevel2,DC=domain,DC=name,DC=here",
"OU=TopLevel3,DC=domain,DC=name,DC=here",
"OU=TopLevel4,DC=domain,DC=name,DC=here",
"OU=TopLevel5,DC=domain,DC=name,DC=here")
 
Foreach ($ou in $ouTop){Set-AdmPwdAuditing -OrgUnit $ou -AuditedPrincipals:Everyone}

######################################################################################
#~ END ###############################################################################
######################################################################################
