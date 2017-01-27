#############################################################################################################################################
###~ Administrator Compliance Remediation - ETS #############################################################################################
#
#~ Brian Tancredi
#~ Created: 2017-01-27
#~ Modified: 2017-01-27
#
#~ References:
#~ https://kareembehery.wordpress.com/2016/04/04/dcm-in-sccm-2012-members-in-local-admin-group-compliance/
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assigning Variables and Functions ######################################################################################################
#############################################################################################################################################
 
$local_Group = "Administrators"
$computer = $env:computername
$ok_Admins = @(
"administrator",
"Domain\Domain Admins")#~ Acceptable Administrators
$local_Admins = net localgroup $local_Group | where {$_ -AND $_ -notmatch "command completed successfully"} | select -skip 4 #~ Current Administrators

function NonCompliant_No_Admin{
    foreach ($admin in $ok_Admins){
        If (!($local_Admins -contains $admin)){
            $adsi_admin = ($admin -replace "\\", '/')
            Try{
#                Write-Host "Adding $adsi_admin" -ForegroundColor Green
                ([ADSI]"WinNT://$computer/$local_Group,group").psbase.Invoke("Add",([ADSI]"WinNT://$adsi_Admin").path)
            }
            Catch{
#                Write-Host "Error Adding $adsi_admin" -ForegroundColor Red
           }
        }
    }
}#~ Function Adds the "ok_Admins" to the Administrator Group

function NonCompliant_Extra_Admin{
    foreach ($admin in $local_Admins){
        If (!($ok_Admins -contains $admin)){
            $adsi_extra = ($admin -replace "\\", '/')
            Try{
#                Write-Host "Deleting $adsi_extra" -ForegroundColor Yellow
                ([ADSI]"WinNT://$computer/$local_Group,group").psbase.Invoke("Remove",([ADSI]"WinNT://$adsi_extra").path)
            }
            Catch{
#                Write-Host "Error Removing $adsi_admin" -ForegroundColor Red
            }
        }
    }
}#~ Function compares the Administrator Group to array of compliant Administrators and Removes Extra users

#############################################################################################################################################
###~ Run Checks against approved local Administrator list and current local Administrators to determine compliance ##########################
#############################################################################################################################################

#~ Checking that the Administrator Group contains approved members (if not add them)
NonCompliant_No_Admin
#~ Comparing the Administrator Group against compliant Administrators (if extra remove them)
NonCompliant_Extra_Admin

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################


